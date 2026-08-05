import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/profile_provider.dart';

class AccountDetailsScreen extends ConsumerWidget {
  const AccountDetailsScreen({super.key});

  void _showAddEditModal(BuildContext context, WidgetRef ref) {
    final loc = ref.read(appLocalizationsProvider);
    final profile = ref.read(userProfileProvider);
    final emailController = TextEditingController(text: profile.email);
    final aadhaarController = TextEditingController(text: profile.aadhaar);
    final panController = TextEditingController(text: profile.pan);
    final nomineeController = TextEditingController(text: profile.nominee);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    loc.tr('Add / Edit Verification Details'),
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.tr('Enter your verification information to complete KYC verification'),
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: loc.tr('Email Address'),
                    hintText: 'e.g. name@example.com',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: loc.tr('Aadhaar Card'),
                    hintText: 'Enter 12-digit Aadhaar number',
                    controller: aadhaarController,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: loc.tr('PAN Card'),
                    hintText: 'Enter 10-character PAN number',
                    controller: panController,
                    prefixIcon: const Icon(Icons.credit_card_outlined, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: loc.tr('Nominee Name'),
                    hintText: 'Enter legal nominee full name',
                    controller: nomineeController,
                    prefixIcon: const Icon(Icons.people_outline, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: loc.tr('Save Details'),
                    onPressed: () async {
                      await ref.read(userProfileProvider.notifier).updateKycDetails(
                            email: emailController.text.trim(),
                            aadhaar: aadhaarController.text.trim(),
                            pan: panController.text.trim(),
                            nominee: nomineeController.text.trim(),
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.tr('Details updated successfully!')),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(appLocalizationsProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 22),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
        ),
        title: Text(
          loc.tr('Account Details'),
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            profile.initials,
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name.isNotEmpty ? profile.name : 'Valued Member',
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                loc.tr('Member ID: ${profile.memberId}'),
                                style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _showAddEditModal(context, ref),
                          icon: const Icon(Icons.edit_note_rounded, size: 18),
                          label: Text(loc.tr('Edit')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 18),
                    _buildFieldRow(
                      context,
                      loc,
                      label: 'Mobile Number',
                      value: profile.phone.isNotEmpty ? profile.phone : 'Not Available',
                      icon: Icons.phone_outlined,
                      isVerified: profile.phone.isNotEmpty,
                    ),
                    const SizedBox(height: 16),
                    _buildFieldRow(
                      context,
                      loc,
                      label: 'Email Address',
                      value: profile.email.isNotEmpty ? profile.email : 'Not Added',
                      icon: Icons.email_outlined,
                      isVerified: profile.isEmailVerified,
                      onAddTap: () => _showAddEditModal(context, ref),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldRow(
                      context,
                      loc,
                      label: 'Aadhaar Card',
                      value: profile.aadhaar.isNotEmpty ? 'XXXX XXXX ${profile.aadhaar.substring(profile.aadhaar.length - 4)}' : 'Not Added',
                      icon: Icons.badge_outlined,
                      isVerified: profile.isAadhaarAdded,
                      onAddTap: () => _showAddEditModal(context, ref),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldRow(
                      context,
                      loc,
                      label: 'PAN Card',
                      value: profile.pan.isNotEmpty ? profile.pan.toUpperCase() : 'Not Added',
                      icon: Icons.credit_card_outlined,
                      isVerified: profile.isPanAdded,
                      onAddTap: () => _showAddEditModal(context, ref),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldRow(
                      context,
                      loc,
                      label: 'Nominee Name',
                      value: profile.nominee.isNotEmpty ? profile.nominee : 'Not Added',
                      icon: Icons.people_outline,
                      isVerified: profile.isNomineeAdded,
                      onAddTap: () => _showAddEditModal(context, ref),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms),
              const SizedBox(height: 24),
              CustomButton(
                text: profile.isKycVerified ? loc.tr('Update Verification Details') : loc.tr('+ Add Verification Details'),
                onPressed: () => _showAddEditModal(context, ref),
              ).animate().fadeIn(duration: 350.ms, delay: 100.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldRow(
    BuildContext context,
    AppLocalizations loc, {
    required String label,
    required String value,
    required IconData icon,
    required bool isVerified,
    VoidCallback? onAddTap,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.tr(label), style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11)),
              const SizedBox(height: 2),
              Text(
                loc.tr(value),
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isVerified ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (isVerified)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  loc.tr('Verified'),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          )
        else
          TextButton(
            onPressed: onAddTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              loc.tr('+ Add'),
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
