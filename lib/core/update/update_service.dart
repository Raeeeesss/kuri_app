import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';
import 'github_update_repository.dart';
import 'update_logger.dart';
import 'update_model.dart';

class DownloadProgressInfo {
  final int count;
  final int total;
  final double speedBytesPerSec;
  final Duration? remainingTime;

  const DownloadProgressInfo({
    required this.count,
    required this.total,
    required this.speedBytesPerSec,
    required this.remainingTime,
  });

  double get progressPercentage {
    if (total <= 0) return 0.0;
    return (count / total).clamp(0.0, 1.0);
  }

  String get formattedDownloadedSize {
    final mb = count / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String get formattedTotalSize {
    if (total <= 0) return 'Unknown MB';
    final mb = total / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String get formattedSpeed {
    if (speedBytesPerSec <= 0) return '0 KB/s';
    if (speedBytesPerSec >= 1024 * 1024) {
      final mb = speedBytesPerSec / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB/s';
    }
    final kb = speedBytesPerSec / 1024;
    return '${kb.toStringAsFixed(0)} KB/s';
  }

  String get formattedRemainingTime {
    if (remainingTime == null || remainingTime!.inSeconds <= 0) {
      return 'Calculating...';
    }
    final mins = remainingTime!.inMinutes;
    final secs = remainingTime!.inSeconds % 60;
    if (mins > 0) return '${mins}m ${secs}s left';
    return '${secs}s left';
  }
}

class UpdateService {
  final GithubUpdateRepository _repository;
  final Dio _dio;

  UpdateService({GithubUpdateRepository? repository, Dio? dio})
      : _repository = repository ?? GithubUpdateRepository(),
        _dio = dio ?? Dio();

  /// Gets current installed version details via package_info_plus
  Future<PackageInfo> getPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }

  /// Compares versions using pub_semver semantic versioning
  bool _isNewerVersion(String currentVersionStr, String latestVersionStr) {
    try {
      final cleanCurrent = _cleanVersionString(currentVersionStr);
      final cleanLatest = _cleanVersionString(latestVersionStr);

      UpdateLogger.info('Comparing SemVer: Current="$cleanCurrent" vs Latest="$cleanLatest"');

      final currentSemver = Version.parse(cleanCurrent);
      final latestSemver = Version.parse(cleanLatest);

      final isNewer = latestSemver > currentSemver;
      UpdateLogger.info('SemVer comparison result: latestSemver ($latestSemver) > currentSemver ($currentSemver) = $isNewer');
      return isNewer;
    } catch (e) {
      UpdateLogger.warning('SemVer parse failed ($e). Falling back to string comparison.');
      return latestVersionStr.trim() != currentVersionStr.trim();
    }
  }

  String _cleanVersionString(String version) {
    var v = version.trim();
    if (v.startsWith('v') || v.startsWith('V')) {
      v = v.substring(1);
    }
    // Remove build metadata e.g. 1.0.0+1 -> 1.0.0
    if (v.contains('+')) {
      v = v.split('+').first;
    }
    // Handle short versions e.g. "1.0" -> "1.0.0"
    final parts = v.split('.');
    if (parts.length == 1) return '${parts[0]}.0.0';
    if (parts.length == 2) return '${parts[0]}.${parts[1]}.0';
    return v;
  }

  /// Checks GitHub for available updates
  Future<UpdateModel> checkUpdate() async {
    final pkgInfo = await getPackageInfo();
    final releaseData = await _repository.fetchLatestRelease();

    final currentVersionStr = pkgInfo.version;
    final currentBuildStr = pkgInfo.buildNumber;
    final latestVersionStr = releaseData.tagName;

    final isAvailable = _isNewerVersion(currentVersionStr, latestVersionStr);

    UpdateLogger.logHeader('UPDATE SERVICE CHECK RESULT');
    UpdateLogger.info('Current Installed App Version: $currentVersionStr (Build $currentBuildStr)');
    UpdateLogger.info('Latest GitHub Release Tag: $latestVersionStr');
    UpdateLogger.info('Is Update Available: $isAvailable');
    UpdateLogger.logFooter();

    return UpdateModel(
      currentVersion: currentVersionStr,
      currentBuildNumber: currentBuildStr,
      latestVersion: latestVersionStr,
      releaseTitle: releaseData.title,
      releaseNotes: releaseData.body,
      releaseDate: releaseData.publishedAt,
      apkDownloadUrl: releaseData.apkDownloadUrl,
      apkSize: releaseData.apkSize,
      isUpdateAvailable: isAvailable,
    );
  }

  /// Downloads the APK from GitHub assets with progress updates and cancel support
  Future<File> downloadApk({
    required String downloadUrl,
    required CancelToken cancelToken,
    required void Function(DownloadProgressInfo progress) onProgress,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = 'kuri_app_update_${DateTime.now().millisecondsSinceEpoch}.apk';
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);

    UpdateLogger.info('Starting APK download to: $filePath');

    // Clean old downloaded APK files in temporary directory
    try {
      final files = tempDir.listSync();
      for (final f in files) {
        if (f.path.contains('kuri_app_update_') && f.path.endsWith('.apk')) {
          f.deleteSync();
        }
      }
    } catch (_) {}

    final startTime = DateTime.now();
    int lastReceived = 0;
    DateTime lastTime = startTime;
    double currentSpeed = 0.0;

    await _dio.download(
      downloadUrl,
      filePath,
      cancelToken: cancelToken,
      onReceiveProgress: (count, total) {
        final now = DateTime.now();
        final timeDiffSec = now.difference(lastTime).inMilliseconds / 1000.0;

        if (timeDiffSec >= 0.3) {
          final bytesDiff = count - lastReceived;
          currentSpeed = bytesDiff / timeDiffSec;
          lastReceived = count;
          lastTime = now;
        }

        Duration? remainingTime;
        if (currentSpeed > 0 && total > count) {
          final remainingBytes = total - count;
          final secs = (remainingBytes / currentSpeed).round();
          remainingTime = Duration(seconds: secs);
        }

        onProgress(
          DownloadProgressInfo(
            count: count,
            total: total,
            speedBytesPerSec: currentSpeed,
            remainingTime: remainingTime,
          ),
        );
      },
    );

    // APK Validation: Verify file exists and file size > 0
    if (!await file.exists() || await file.length() == 0) {
      if (await file.exists()) {
        await file.delete();
      }
      UpdateLogger.error('Downloaded APK file is invalid or corrupted (0 bytes). Deleted.');
      throw Exception('Downloaded APK is invalid or corrupted (0 bytes).');
    }

    UpdateLogger.info('APK downloaded successfully. File size: ${await file.length()} bytes');
    return file;
  }

  /// Triggers Android package installer automatically
  Future<void> installApk(File apkFile) async {
    if (!await apkFile.exists() || await apkFile.length() == 0) {
      UpdateLogger.error('APK file does not exist or is 0 bytes before installation.');
      throw Exception('APK file does not exist or is corrupted.');
    }

    UpdateLogger.info('Opening APK package installer for: ${apkFile.path}');
    final uri = Uri.file(apkFile.path);

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched) {
      UpdateLogger.error('Failed to open Android package installer via url_launcher.');
      throw Exception('Unable to open the downloaded APK.');
    }
  }
}
