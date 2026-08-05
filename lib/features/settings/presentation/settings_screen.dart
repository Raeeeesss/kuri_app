import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(appLocalizationsProvider);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 22),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
        ),
        title: Text(
          loc.tr('Settings'),
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // General Preferences
              Text(
                loc.tr('General Preferences'),
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ).animate().fadeIn(duration: 350.ms),

              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.softShadow,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.language_rounded, color: AppColors.primary, size: 22),
                        ),
                        title: Text(
                          loc.tr('App Language'),
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        subtitle: Text(
                          'Malayalam / English',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                settings.language,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
                          ],
                        ),
                        onTap: () {
                          _showLanguageBottomSheet(context, ref, settings.language);
                        },
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        secondary: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.dark_mode_outlined, color: AppColors.primary, size: 22),
                        ),
                        title: Text(
                          loc.tr('Dark Mode'),
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        subtitle: Text(
                          loc.tr('Adjust interface color theme'),
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        value: settings.isDarkMode,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) {
                          notifier.toggleDarkMode(val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'Dark Theme Activated' : 'Light Theme Activated'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 350.ms, delay: 100.ms),

              const SizedBox(height: 28),

              // Security & Privacy
              Text(
                loc.tr('Security & Privacy'),
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ).animate().fadeIn(duration: 350.ms, delay: 150.ms),

              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.softShadow,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        secondary: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 22),
                        ),
                        title: Text(
                          loc.tr('Biometric & PIN Lock'),
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        subtitle: Text(
                          loc.tr('Secure app startup authentication'),
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        value: settings.isBiometricEnabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) {
                          notifier.toggleBiometric(val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val
                                  ? 'Biometric & PIN Lock Enabled! Prompting Face ID/Fingerprint for logged-in user.'
                                  : 'Biometric Lock Disabled'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        secondary: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 22),
                        ),
                        title: Text(
                          loc.tr('SMS & Push Notifications'),
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        subtitle: Text(
                          loc.tr('Get installment due reminders & alerts'),
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        value: settings.isNotificationsEnabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) {
                          notifier.toggleNotifications(val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'Notifications Enabled' : 'Notifications Muted'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary, size: 22),
                        ),
                        title: Text(
                          loc.tr('Privacy Policy'),
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
                        onTap: () {},
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 22),
                        ),
                        title: Text(
                          loc.tr('Terms & Conditions'),
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 350.ms, delay: 200.ms),

              const SizedBox(height: 36),

              // App Version Information
              Center(
                child: Column(
                  children: [
                    Text(
                      'Kerala Kuri v1.0.0 (Build 101)',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Regulated & Licensed Chitty Fund',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms, delay: 250.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, WidgetRef ref, String currentLang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Language / ഭാഷ തിരഞ്ഞെടുക്കുക',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('English (English)', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: currentLang == 'English' ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage('English');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('App Language set to English'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('മലയാളം (Malayalam)', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: currentLang == 'Malayalam' ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage('Malayalam');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('ആപ്പ് ഭാഷ മലയാളത്തിലേക്ക് മാറ്റി (Language set to Malayalam)'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
