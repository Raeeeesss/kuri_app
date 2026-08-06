import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';
import 'github_update_repository.dart';
import 'update_logger.dart';
import 'update_model.dart';

// ---------------------------------------------------------------------------
// MethodChannel used to call the native Android FileProvider installer.
// Declared at top-level so it is available before UpdateService is constructed.
// ---------------------------------------------------------------------------
const MethodChannel _installerChannel = MethodChannel('kuri_app/updater');

// ---------------------------------------------------------------------------
// DownloadProgressInfo – unchanged from original
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// UpdateService
// ---------------------------------------------------------------------------
class UpdateService {
  final GithubUpdateRepository _repository;
  final Dio _dio;

  UpdateService({GithubUpdateRepository? repository, Dio? dio})
      : _repository = repository ?? GithubUpdateRepository(),
        _dio = dio ?? Dio();

  /// Gets current installed version details via package_info_plus.
  Future<PackageInfo> getPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }

  // ── Version helpers ──────────────────────────────────────────────────────

  /// Strips `v`/`V` prefix and `+build` suffix, normalises to X.Y.Z.
  String _cleanVersionString(String version) {
    var v = version.trim();

    // Strip leading 'v' or 'V'
    if (v.startsWith('v') || v.startsWith('V')) {
      v = v.substring(1);
    }

    // Strip build metadata (everything after '+')
    if (v.contains('+')) {
      v = v.split('+').first;
    }

    // Strip pre-release labels (e.g. "1.0.0-beta") – treat as equal to base
    if (v.contains('-')) {
      v = v.split('-').first;
    }

    // Pad missing patch/minor segments: "1" → "1.0.0", "1.0" → "1.0.0"
    final parts = v.split('.');
    return switch (parts.length) {
      1 => '${parts[0]}.0.0',
      2 => '${parts[0]}.${parts[1]}.0',
      _ => v,
    };
  }

  /// Extracts the integer build number from a version string containing `+`.
  /// Returns 0 if no build number is present.
  int _extractBuildNumber(String versionStr) {
    final v = versionStr.trim();
    if (v.contains('+')) {
      final buildPart = v.split('+').last;
      // Keep only digits in case there's extra text after '+'
      return int.tryParse(buildPart.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return 0;
  }

  /// Returns `true` only when the GitHub release is strictly newer than the
  /// installed version.
  ///
  /// Algorithm:
  ///   1. Compare the semantic X.Y.Z parts with pub_semver.
  ///   2. If the semantic versions are EQUAL, compare build numbers so that
  ///      1.0.3+3 → 1.0.3+4 triggers an update but 1.0.3+4 → 1.0.3+4 does not.
  ///   3. On ANY parse error the fallback is `false` (never assume an update).
  bool _isNewerVersion(
    String currentVersionStr,
    String latestVersionStr, {
    int currentBuild = 0,
    int latestBuild = 0,
  }) {
    try {
      final cleanCurrent = _cleanVersionString(currentVersionStr);
      final cleanLatest = _cleanVersionString(latestVersionStr);

      final currentSemver = Version.parse(cleanCurrent);
      final latestSemver = Version.parse(cleanLatest);

      if (latestSemver > currentSemver) return true;
      if (latestSemver == currentSemver) {
        // Same X.Y.Z → fall back to build number
        return latestBuild > currentBuild;
      }
      return false;
    } catch (e) {
      // Parsing failed – assume no update rather than showing a false positive.
      UpdateLogger.warning(
        'SemVer parse failed for '
        '"$currentVersionStr" vs "$latestVersionStr": $e  → assuming no update.',
      );
      return false;
    }
  }

  // ── Markdown stripper ────────────────────────────────────────────────────

  /// Converts a GitHub-flavoured Markdown string to clean plain text suitable
  /// for display in the release-notes box.
  String _stripMarkdown(String text) {
    var s = text;

    // Images before links (order matters)
    s = s.replaceAll(RegExp(r'!\[([^\]]*)\]\([^)]*\)'), '');

    // Links → keep link text
    s = s.replaceAll(RegExp(r'\[([^\]]*)\]\([^)]*\)'), r'$1');

    // Headings (## Heading → Heading)
    s = s.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');

    // Bold + italic (***text*** / **text** / *text* / ___/_/__)
    s = s.replaceAll(RegExp(r'\*{1,3}([^*]+)\*{1,3}'), r'$1');
    s = s.replaceAll(RegExp(r'_{1,3}([^_]+)_{1,3}'), r'$1');

    // Inline code
    s = s.replaceAll(RegExp(r'`([^`]*)`'), r'$1');

    // Blockquotes
    s = s.replaceAll(RegExp(r'^>\s*', multiLine: true), '');

    // Horizontal rules
    s = s.replaceAll(RegExp(r'^[-*_]{3,}\s*$', multiLine: true), '');

    // Unordered list markers (- / * / +) → bullet
    s = s.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '• ');

    // Ordered list markers (1. / 2.) – keep as-is (already readable)

    // Collapse 3+ consecutive blank lines to 2
    s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return s.trim();
  }

  // ── Core update check ────────────────────────────────────────────────────

  /// Fetches the latest GitHub release and compares it with the installed
  /// version. Emits the structured debug log block every time it runs.
  Future<UpdateModel> checkUpdate() async {
    final pkgInfo = await getPackageInfo();
    final releaseData = await _repository.fetchLatestRelease();

    final currentVersionStr = pkgInfo.version; // e.g. "1.0.3" (from pubspec)
    final currentBuildStr = pkgInfo.buildNumber; // e.g. "3"
    final latestVersionStr = releaseData.tagName; // e.g. "v1.0.4"

    final currentBuild = int.tryParse(currentBuildStr) ?? 0;
    final latestBuild = _extractBuildNumber(latestVersionStr);

    final cleanCurrent = _cleanVersionString(currentVersionStr);
    final cleanLatest = _cleanVersionString(latestVersionStr);

    final isAvailable = _isNewerVersion(
      currentVersionStr,
      latestVersionStr,
      currentBuild: currentBuild,
      latestBuild: latestBuild,
    );

    // ── Build the human-readable comparison line ──
    String comparisonStr;
    try {
      final cv = Version.parse(cleanCurrent);
      final lv = Version.parse(cleanLatest);
      if (lv > cv) {
        comparisonStr = '$cleanLatest > $cleanCurrent';
      } else if (lv == cv && latestBuild > currentBuild) {
        comparisonStr =
            '$cleanLatest+$latestBuild > $cleanCurrent+$currentBuild  (build number)';
      } else {
        comparisonStr = '$cleanLatest == $cleanCurrent  (no update)';
      }
    } catch (_) {
      comparisonStr = '$cleanLatest  vs  $cleanCurrent  (semver parse error)';
    }

    // ── Structured log block ──────────────────────────────────────────────
    UpdateLogger.logHeader('UPDATE CHECK');
    UpdateLogger.logRaw('');
    UpdateLogger.logRaw('  Installed Version : $cleanCurrent');
    UpdateLogger.logRaw('  Installed Build   : $currentBuildStr');
    UpdateLogger.logRaw('');
    UpdateLogger.logRaw('  GitHub Version    : $latestVersionStr');
    UpdateLogger.logRaw('  Normalized Version: $cleanLatest');
    UpdateLogger.logRaw('');
    UpdateLogger.logRaw('  Comparison        : $comparisonStr');
    UpdateLogger.logRaw('');
    UpdateLogger.logRaw(
        '  Update Available  : ${isAvailable ? "TRUE" : "FALSE"}');
    UpdateLogger.logRaw('');
    UpdateLogger.logRaw('  APK URL           : ${releaseData.apkDownloadUrl}');
    UpdateLogger.logRaw('');
    UpdateLogger.logFooter();

    final strippedNotes = _stripMarkdown(releaseData.body);

    return UpdateModel(
      currentVersion: currentVersionStr,
      currentBuildNumber: currentBuildStr,
      latestVersion: latestVersionStr,
      releaseTitle: releaseData.title,
      releaseNotes: strippedNotes.isNotEmpty
          ? strippedNotes
          : 'No release notes provided.',
      releaseDate: releaseData.publishedAt,
      apkDownloadUrl: releaseData.apkDownloadUrl,
      apkSize: releaseData.apkSize,
      isUpdateAvailable: isAvailable,
    );
  }

  // ── APK download ─────────────────────────────────────────────────────────

  /// Downloads the APK from GitHub assets with progress updates and cancel
  /// support. Unchanged from the original implementation.
  Future<File> downloadApk({
    required String downloadUrl,
    required CancelToken cancelToken,
    required void Function(DownloadProgressInfo progress) onProgress,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'kuri_app_update_${DateTime.now().millisecondsSinceEpoch}.apk';
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);

    UpdateLogger.info('Starting APK download to: $filePath');

    // Clean old downloaded APK files in the temporary directory
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

    // Validate the downloaded file
    if (!await file.exists() || await file.length() == 0) {
      if (await file.exists()) await file.delete();
      UpdateLogger.error(
          'Downloaded APK file is invalid or corrupted (0 bytes). Deleted.');
      throw Exception('Downloaded APK is invalid or corrupted (0 bytes).');
    }

    UpdateLogger.info(
        'APK downloaded successfully. File size: ${await file.length()} bytes');
    return file;
  }

  // ── APK installation ─────────────────────────────────────────────────────

  /// Triggers the Android system package installer via a native MethodChannel.
  ///
  /// The Kotlin side wraps the file path in a FileProvider `content://` URI
  /// and fires ACTION_VIEW with FLAG_GRANT_READ_URI_PERMISSION, which is the
  /// correct approach for Android 7+ (API 24+) and avoids FileUriExposedException.
  Future<void> installApk(File apkFile) async {
    if (!await apkFile.exists() || await apkFile.length() == 0) {
      UpdateLogger.error(
          'APK file does not exist or is 0 bytes before installation.');
      throw Exception('APK file does not exist or is corrupted.');
    }

    UpdateLogger.info(
        'Requesting APK install via native MethodChannel: ${apkFile.path}');

    try {
      await _installerChannel.invokeMethod<void>('installApk', apkFile.path);
      UpdateLogger.info('Native installer launched successfully.');
    } on PlatformException catch (e) {
      UpdateLogger.error(
          'MethodChannel installApk failed: [${e.code}] ${e.message}');
      throw Exception('Unable to open the APK installer: ${e.message}');
    }
  }
}
