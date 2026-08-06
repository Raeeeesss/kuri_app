import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/providers/settings_provider.dart';

class AppLocalizations {
  final String language;

  AppLocalizations(this.language);

  String tr(String text) {
    return text;
  }
}

final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final settings = ref.watch(settingsProvider);
  return AppLocalizations(settings.language);
});

