import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/update/update_dialog.dart';
import '../../../core/update/update_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(appLocalizationsProvider);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final updateState = ref.watch(updateProvider);
    final packageInfoAsync = ref.watch(packageInfoProvider);
    final installedVersionText = packageInfoAsync.when(
      data: (info) => 'v${info.version} (Build ${info.buildNumber})',
      loading: () => updateState.updateInfo != null
          ? 'v${updateState.updateInfo!.currentVersion} (Build ${updateState.updateInfo!.currentBuildNumber})'
          : 'v1.0.3 (Build 3)',
      error: (_, _) => updateState.updateInfo != null
          ? 'v${updateState.updateInfo!.currentVersion} (Build ${updateState.updateInfo!.currentBuildNumber})'
          : 'v1.0.3 (Build 3)',
    );

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
                          'English',
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
                        onChanged: (val) async {
                          if (val) {
                            final res = await BiometricService.authenticate(
                              reason: 'Scan Face ID, Fingerprint, Pattern or PIN to enable security lock',
                            );
                            if (!res.isSuccess) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Mobile authentication failed or was cancelled. Lock not enabled.'),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                              return;
                            }
                          }
                          notifier.toggleBiometric(val);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val
                                  ? 'Biometric & PIN Lock Enabled via mobile device security!'
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

              const SizedBox(height: 28),

              // Software Update Section
              Text(
                loc.tr('Software Updates'),
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ).animate().fadeIn(duration: 350.ms, delay: 220.ms),

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
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.system_update_outlined, color: AppColors.primary, size: 22),
                        ),
                        title: Text(
                          loc.tr('Check for Updates'),
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        subtitle: Text(
                          updateState.status == UpdateStatus.checking
                              ? 'Checking GitHub Releases...'
                              : 'Last checked: ${updateState.formattedLastChecked}',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        trailing: updateState.status == UpdateStatus.checking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Check Now',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                        onTap: updateState.status == UpdateStatus.checking
                            ? null
                            : () async {
                                final updateNotifier = ref.read(updateProvider.notifier);
                                await updateNotifier.checkForUpdates(isManual: true);

                                final currentState = ref.read(updateProvider);
                                if (!context.mounted) return;

                                if (currentState.status == UpdateStatus.available && currentState.updateInfo != null) {
                                  UpdateDialog.show(context);
                                } else if (currentState.status == UpdateStatus.notAvailable) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("You're using the latest version."),
                                      backgroundColor: AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                } else if (currentState.status == UpdateStatus.error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(currentState.errorMessage ?? 'Failed to check for updates.'),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                }
                              },
                      ),
                      const Divider(color: AppColors.border, height: 1, indent: 20, endIndent: 20),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 22),
                        ),
                        title: Text(
                          loc.tr('App Information'),
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        subtitle: Text(
                          installedVersionText,
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
                        onTap: () => _showAppInfoDialog(context, ref, installedVersionText),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 350.ms, delay: 240.ms),

              const SizedBox(height: 36),

              // App Version Information
              Center(
                child: Column(
                  children: [
                    Text(
                      'Kerala Kuri $installedVersionText',
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

  void _showAppInfoDialog(BuildContext context, WidgetRef ref, String versionText) {
    final pkgAsync = ref.read(packageInfoProvider);
    final pkg = pkgAsync.asData?.value;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App Information',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Kerala Kuri Mobile App',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),
              _buildInfoRow('Application Name', pkg?.appName ?? 'kuri_app'),
              const SizedBox(height: 10),
              _buildInfoRow('Package ID', pkg?.packageName ?? 'com.example.kuri_app'),
              const SizedBox(height: 10),
              _buildInfoRow('Installed Version', pkg?.version ?? '1.0.3'),
              const SizedBox(height: 10),
              _buildInfoRow('Build Number', pkg?.buildNumber ?? '3'),
              const SizedBox(height: 10),
              _buildInfoRow('Update Channel', 'GitHub Releases'),
              const SizedBox(height: 10),
              _buildInfoRow('Repository', 'Raeeeesss/kuri_app'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ],
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
              'Select Language',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('English', style: TextStyle(fontWeight: FontWeight.bold)),
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
          ],
        ),
      ),
    );
  }
}
