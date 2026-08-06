import 'package:dio/dio.dart';
import 'update_logger.dart';

class GitHubReleaseData {
  final String tagName;
  final String title;
  final String body;
  final DateTime? publishedAt;
  final String apkDownloadUrl;
  final int apkSize;

  const GitHubReleaseData({
    required this.tagName,
    required this.title,
    required this.body,
    required this.publishedAt,
    required this.apkDownloadUrl,
    required this.apkSize,
  });
}

class GithubUpdateRepository {
  final Dio _dio;
  static const String _latestReleaseUrl =
      'https://api.github.com/repos/Raeeeesss/kuri_app/releases/latest';
  static const String _allowedDomain = 'github.com';

  GithubUpdateRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 12),
                headers: {
                  'Accept': 'application/vnd.github+json',
                  'User-Agent': 'kuri_app-updater',
                },
              ),
            );

  Future<GitHubReleaseData> fetchLatestRelease() async {
    UpdateLogger.logHeader('GITHUB UPDATE REPOSITORY FETCH');
    UpdateLogger.info('Requesting latest release from: $_latestReleaseUrl');

    try {
      final response = await _dio.get<Map<String, dynamic>>(_latestReleaseUrl);

      UpdateLogger.info('HTTP Status Code: ${response.statusCode}');

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('GitHub API returned unexpected status code ${response.statusCode}');
      }

      final data = response.data!;
      final tagName = (data['tag_name'] as String?)?.trim() ?? '';
      final title = (data['name'] as String?)?.trim() ?? tagName;
      final body = (data['body'] as String?)?.trim() ?? 'No release notes provided.';
      final publishedAtStr = data['published_at'] as String?;
      final publishedAt = publishedAtStr != null ? DateTime.tryParse(publishedAtStr) : null;

      UpdateLogger.info('Parsed Tag Name: "$tagName"');
      UpdateLogger.info('Parsed Title: "$title"');
      UpdateLogger.info('Published Date: ${publishedAt?.toIso8601String() ?? "Unknown"}');

      final assets = data['assets'] as List<dynamic>? ?? [];
      UpdateLogger.info('Scanning ${assets.length} release assets for APK file...');

      String? selectedApkUrl;
      int selectedApkSize = 0;
      String? selectedApkName;

      // Scan all release assets to find .apk files
      final apkAssets = <Map<String, dynamic>>[];
      for (final asset in assets) {
        if (asset is Map<String, dynamic>) {
          final downloadUrl = (asset['browser_download_url'] as String? ?? '').trim();
          final name = (asset['name'] as String? ?? '').trim();

          if (name.toLowerCase().endsWith('.apk') && downloadUrl.isNotEmpty) {
            final uri = Uri.tryParse(downloadUrl);
            if (uri != null && uri.scheme == 'https' && uri.host.endsWith(_allowedDomain)) {
              apkAssets.add(asset);
              UpdateLogger.info('Found valid APK asset: "$name" (${asset['size']} bytes)');
            } else {
              UpdateLogger.warning('Skipped APK asset with untrusted domain: $downloadUrl');
            }
          }
        }
      }

      if (apkAssets.isEmpty) {
        UpdateLogger.error('No valid .apk asset found in latest GitHub release.');
        throw Exception('No APK file attached to the latest GitHub release.');
      }

      // If multiple APKs exist, prefer 'app-release.apk'
      Map<String, dynamic> chosenAsset = apkAssets.first;
      for (final asset in apkAssets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name == 'app-release.apk') {
          chosenAsset = asset;
          break;
        }
      }

      selectedApkUrl = chosenAsset['browser_download_url'] as String;
      selectedApkSize = (chosenAsset['size'] as num?)?.toInt() ?? 0;
      selectedApkName = chosenAsset['name'] as String;

      UpdateLogger.info('Selected APK Asset: "$selectedApkName"');
      UpdateLogger.info('APK Download URL: $selectedApkUrl');
      UpdateLogger.info('APK Size: $selectedApkSize bytes');
      UpdateLogger.logFooter();

      return GitHubReleaseData(
        tagName: tagName,
        title: title,
        body: body,
        publishedAt: publishedAt,
        apkDownloadUrl: selectedApkUrl,
        apkSize: selectedApkSize,
      );
    } on DioException catch (e, st) {
      UpdateLogger.error('DioException during GitHub release fetch', e, st);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Network unreachable. Please check your internet connection.');
      } else if (e.response?.statusCode == 403 || e.response?.statusCode == 429) {
        throw Exception('GitHub API rate limit reached. Please try again later.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('GitHub repository or releases not found.');
      }
      throw Exception('GitHub API error: ${e.message ?? 'Unknown error'}');
    } catch (e, st) {
      UpdateLogger.error('Unexpected error fetching GitHub release', e, st);
      rethrow;
    }
  }
}
