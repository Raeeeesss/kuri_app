import 'package:dio/dio.dart';

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
    try {
      final response = await _dio.get<Map<String, dynamic>>(_latestReleaseUrl);

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('GitHub API returned status code ${response.statusCode}');
      }

      final data = response.data!;
      final tagName = (data['tag_name'] as String?)?.trim() ?? '';
      final title = (data['name'] as String?)?.trim() ?? tagName;
      final body = (data['body'] as String?)?.trim() ?? 'No release notes provided.';
      final publishedAtStr = data['published_at'] as String?;
      final publishedAt = publishedAtStr != null ? DateTime.tryParse(publishedAtStr) : null;

      final assets = data['assets'] as List<dynamic>? ?? [];
      String? apkUrl;
      int apkSize = 0;

      // Scan all assets to find the .apk file (ignore .aab, source archives, etc.)
      for (final asset in assets) {
        if (asset is Map<String, dynamic>) {
          final downloadUrl = asset['browser_download_url'] as String? ?? '';
          final name = (asset['name'] as String? ?? '').toLowerCase();

          if (name.endsWith('.apk') && downloadUrl.isNotEmpty) {
            // Security: Enforce HTTPS & GitHub domain validation
            final uri = Uri.tryParse(downloadUrl);
            if (uri != null && uri.scheme == 'https' && uri.host.endsWith(_allowedDomain)) {
              apkUrl = downloadUrl;
              apkSize = (asset['size'] as num?)?.toInt() ?? 0;
              break;
            }
          }
        }
      }

      if (apkUrl == null || apkUrl.isEmpty) {
        throw Exception('No APK asset found in the latest GitHub release.');
      }

      return GitHubReleaseData(
        tagName: tagName,
        title: title,
        body: body,
        publishedAt: publishedAt,
        apkDownloadUrl: apkUrl,
        apkSize: apkSize,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Network unreachable. Please check your internet connection.');
      } else if (e.response?.statusCode == 403 || e.response?.statusCode == 429) {
        throw Exception('GitHub API rate limit exceeded. Please try again later.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('No GitHub releases found for Raeeeesss/kuri_app.');
      }
      throw Exception('GitHub API error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      throw Exception('Failed to fetch latest update info: $e');
    }
  }
}
