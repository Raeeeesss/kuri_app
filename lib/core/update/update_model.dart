class UpdateModel {
  final String currentVersion;
  final String currentBuildNumber;
  final String latestVersion;
  final String releaseTitle;
  final String releaseNotes;
  final DateTime? releaseDate;
  final String apkDownloadUrl;
  final int apkSize;
  final bool isUpdateAvailable;

  const UpdateModel({
    required this.currentVersion,
    required this.currentBuildNumber,
    required this.latestVersion,
    required this.releaseTitle,
    required this.releaseNotes,
    required this.releaseDate,
    required this.apkDownloadUrl,
    required this.apkSize,
    required this.isUpdateAvailable,
  });

  String get formattedReleaseDate {
    if (releaseDate == null) return 'Unknown Date';
    final year = releaseDate!.year;
    final month = releaseDate!.month.toString().padLeft(2, '0');
    final day = releaseDate!.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String get formattedApkSize {
    if (apkSize <= 0) return 'Unknown Size';
    final mb = apkSize / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}
