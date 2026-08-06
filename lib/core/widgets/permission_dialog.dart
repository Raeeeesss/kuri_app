import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../features/settings/providers/settings_provider.dart';

import '../services/biometric_service.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDialog extends ConsumerStatefulWidget {
  const PermissionDialog({super.key});

  static Future<void> checkAndShow(BuildContext context) async {
    final prompted = await LocalStorageService.hasPromptedPermissions();
    if (!prompted && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const PermissionDialog(),
      );
    }
  }

  @override
  ConsumerState<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends ConsumerState<PermissionDialog> {
  bool _notificationAllowed = true;
  bool _biometricAllowed = true;
  bool _isRequesting = false;

  void _onAccept() async {
    setState(() {
      _isRequesting = true;
    });

    // Request real OS Push Notification permission prompt
    if (_notificationAllowed) {
      await Permission.notification.request();
    }

    // Trigger real mobile biometric authentication scan (Face ID / Fingerprint / Pattern / PIN)
    if (_biometricAllowed) {
      await BiometricService.authenticate(
        reason: 'Verify mobile Face ID, Fingerprint, Pattern or PIN to enable biometric lock',
      );
    }

    // Save preferences
    await LocalStorageService.setPermissionsPrompted();
    final settingsNotifier = ref.read(settingsProvider.notifier);
    settingsNotifier.toggleNotifications(_notificationAllowed);
    settingsNotifier.toggleBiometric(_biometricAllowed);

    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _biometricAllowed && _notificationAllowed
              ? 'Permissions requested! Notifications & Mobile Biometrics enabled.'
              : 'Permission preferences updated.',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      elevation: 12,
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
                    Icons.security_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Permissions Required',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Customize your app security & alerts',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Notification Permission Option
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
              title: Text(
                'Push Notifications',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              subtitle: Text(
                'Receive instant updates on auction dates, dividends, & due reminders',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 12),
              ),
              value: _notificationAllowed,
              onChanged: (val) {
                setState(() => _notificationAllowed = val);
              },
            ),
            const SizedBox(height: 8),

            // Mobile Biometric Permission Option
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
              title: Text(
                'Mobile Biometric Authentication',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              subtitle: Text(
                'Use in-build mobile Face ID, Fingerprint, Pattern, or Device PIN to secure app startup',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 12),
              ),
              value: _biometricAllowed,
              onChanged: (val) {
                setState(() => _biometricAllowed = val);
              },
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isRequesting ? null : _onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isRequesting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Continue & Grant Access',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
