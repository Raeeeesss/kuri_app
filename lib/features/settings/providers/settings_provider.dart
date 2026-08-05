import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/local_storage_service.dart';

class SettingsState {
  final String language;
  final bool isDarkMode;
  final bool isBiometricEnabled;
  final bool isNotificationsEnabled;

  const SettingsState({
    this.language = 'English',
    this.isDarkMode = false,
    this.isBiometricEnabled = true,
    this.isNotificationsEnabled = true,
  });

  bool get isMalayalam => language == 'Malayalam';

  SettingsState copyWith({
    String? language,
    bool? isDarkMode,
    bool? isBiometricEnabled,
    bool? isNotificationsEnabled,
  }) {
    return SettingsState(
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final saved = await LocalStorageService.loadSettings();
    state = SettingsState(
      language: saved['language'] as String,
      isDarkMode: saved['isDarkMode'] as bool,
      isBiometricEnabled: saved['isBiometricEnabled'] as bool,
      isNotificationsEnabled: saved['isNotificationsEnabled'] as bool,
    );
  }

  Future<void> _persistCurrent() async {
    await LocalStorageService.saveSettings(
      language: state.language,
      isDarkMode: state.isDarkMode,
      isBiometricEnabled: state.isBiometricEnabled,
      isNotificationsEnabled: state.isNotificationsEnabled,
    );
  }

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
    _persistCurrent();
  }

  void toggleDarkMode(bool val) {
    state = state.copyWith(isDarkMode: val);
    _persistCurrent();
  }

  void toggleBiometric(bool val) {
    state = state.copyWith(isBiometricEnabled: val);
    _persistCurrent();
  }

  void toggleNotifications(bool val) {
    state = state.copyWith(isNotificationsEnabled: val);
    _persistCurrent();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
