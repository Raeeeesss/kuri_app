import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'update_model.dart';
import 'update_service.dart';

enum UpdateStatus {
  initial,
  checking,
  available,
  notAvailable,
  downloading,
  downloaded,
  error,
}

class UpdateState {
  final UpdateStatus status;
  final UpdateModel? updateInfo;
  final DownloadProgressInfo? progressInfo;
  final File? downloadedApk;
  final String? errorMessage;
  final DateTime? lastChecked;
  final bool isManualCheck;

  const UpdateState({
    this.status = UpdateStatus.initial,
    this.updateInfo,
    this.progressInfo,
    this.downloadedApk,
    this.errorMessage,
    this.lastChecked,
    this.isManualCheck = false,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    UpdateModel? updateInfo,
    DownloadProgressInfo? progressInfo,
    File? downloadedApk,
    String? errorMessage,
    DateTime? lastChecked,
    bool? isManualCheck,
  }) {
    return UpdateState(
      status: status ?? this.status,
      updateInfo: updateInfo ?? this.updateInfo,
      progressInfo: progressInfo ?? this.progressInfo,
      downloadedApk: downloadedApk ?? this.downloadedApk,
      errorMessage: errorMessage ?? this.errorMessage,
      lastChecked: lastChecked ?? this.lastChecked,
      isManualCheck: isManualCheck ?? this.isManualCheck,
    );
  }

  String get formattedLastChecked {
    if (lastChecked == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(lastChecked!);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${lastChecked!.year}-${lastChecked!.month.toString().padLeft(2, '0')}-${lastChecked!.day.toString().padLeft(2, '0')}';
  }
}

class UpdateNotifier extends StateNotifier<UpdateState> {
  final UpdateService _service;
  CancelToken? _cancelToken;

  UpdateNotifier({UpdateService? service})
      : _service = service ?? UpdateService(),
        super(const UpdateState());

  /// Checks for app updates via GitHub Releases API
  Future<void> checkForUpdates({bool isManual = false}) async {
    // Avoid duplicate checks if already checking or downloading
    if (state.status == UpdateStatus.checking || state.status == UpdateStatus.downloading) {
      return;
    }

    state = state.copyWith(
      status: UpdateStatus.checking,
      errorMessage: null,
      isManualCheck: isManual,
    );

    try {
      final updateInfo = await _service.checkUpdate();
      final now = DateTime.now();

      if (updateInfo.isUpdateAvailable) {
        state = state.copyWith(
          status: UpdateStatus.available,
          updateInfo: updateInfo,
          lastChecked: now,
        );
      } else {
        state = state.copyWith(
          status: UpdateStatus.notAvailable,
          updateInfo: updateInfo,
          lastChecked: now,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        lastChecked: DateTime.now(),
      );
    }
  }

  /// Downloads the APK from GitHub assets and opens package installer
  Future<void> startDownloadAndInstall() async {
    final info = state.updateInfo;
    if (info == null || info.apkDownloadUrl.isEmpty) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Invalid update download URL.',
      );
      return;
    }

    _cancelToken = CancelToken();
    state = state.copyWith(
      status: UpdateStatus.downloading,
      errorMessage: null,
    );

    try {
      final file = await _service.downloadApk(
        downloadUrl: info.apkDownloadUrl,
        cancelToken: _cancelToken!,
        onProgress: (progress) {
          state = state.copyWith(progressInfo: progress);
        },
      );

      state = state.copyWith(
        status: UpdateStatus.downloaded,
        downloadedApk: file,
      );

      // Open Android package installer automatically
      await _service.installApk(file);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        state = state.copyWith(
          status: UpdateStatus.available,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          status: UpdateStatus.error,
          errorMessage: 'Download interrupted: ${e.message ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Cancels an in-progress APK download
  void cancelDownload() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('User cancelled download.');
    }
    state = state.copyWith(
      status: UpdateStatus.available,
      progressInfo: null,
    );
  }

  /// Retries installation if download has already completed
  Future<void> retryInstall() async {
    if (state.downloadedApk != null) {
      try {
        await _service.installApk(state.downloadedApk!);
      } catch (e) {
        state = state.copyWith(
          status: UpdateStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        );
      }
    } else {
      await startDownloadAndInstall();
    }
  }

  void resetStatus() {
    state = state.copyWith(
      status: state.updateInfo != null && state.updateInfo!.isUpdateAvailable
          ? UpdateStatus.available
          : UpdateStatus.initial,
      errorMessage: null,
    );
  }
}

final updateProvider = StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  return UpdateNotifier();
});
