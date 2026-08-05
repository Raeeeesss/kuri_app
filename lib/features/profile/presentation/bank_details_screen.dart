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

class BankDetailsScreen extends ConsumerWidget {
  const BankDetailsScreen({super.key});

  void _showAddBankModal(BuildContext context, WidgetRef ref) {
    final loc = ref.read(appLocalizationsProvider);
    final profile = ref.read(userProfileProvider);
    final bankNameController = TextEditingController(text: profile.bankName);
    final accountController = TextEditingController(text: profile.bankAccount);
    final ifscController = TextEditingController(text: profile.bankIfsc);
    final upiController = TextEditingController(text: profile.upiId);

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
                    loc.tr('Add / Update Bank Account Details'),
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.tr('Link your bank account to receive prize payouts directly into your bank'),
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: loc.tr('Bank Name'),
                    hintText: 'e.g. Federal Bank / SBI',
                    controller: bankNameController,
                    prefixIcon: const Icon(Icons.account_balance_rounded, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: loc.tr('Account Number'),
                    hintText: 'Enter bank account number',
                    controller: accountController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.pin_outlined, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: loc.tr('IFSC Code'),
                    hintText: 'e.g. FDRL0001234',
                    controller: ifscController,
                    prefixIcon: const Icon(Icons.code_rounded, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: loc.tr('UPI ID'),
                    hintText: 'e.g. mobile@upi',
                    controller: upiController,
                    prefixIcon: const Icon(Icons.qr_code_rounded, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: loc.tr('Save Details'),
                    onPressed: () async {
                      await ref.read(userProfileProvider.notifier).updateBankDetails(
                            bankName: bankNameController.text.trim(),
                            bankAccount: accountController.text.trim(),
                            bankIfsc: ifscController.text.trim(),
                            upiId: upiController.text.trim(),
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.tr('Bank details updated successfully!')),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
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
          loc.tr('Bank & UPI Details'),
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
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  profile.bankName.isNotEmpty ? profile.bankName : 'No Bank Account Linked',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: profile.isBankAdded
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            profile.isBankAdded ? 'VERIFIED' : 'NOT ADDED',
                            style: TextStyle(
                              color: profile.isBankAdded ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 16),
                    _buildRow('Account Number', profile.bankAccount.isNotEmpty ? profile.bankAccount : 'Not Added'),
                    const SizedBox(height: 12),
                    _buildRow('IFSC Code', profile.bankIfsc.isNotEmpty ? profile.bankIfsc : 'Not Added'),
                    const SizedBox(height: 12),
                    _buildRow('UPI ID', profile.upiId.isNotEmpty ? profile.upiId : 'Not Added'),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms),

              const SizedBox(height: 24),

              CustomButton(
                text: profile.isBankAdded ? 'Edit Bank Details' : '+ Add Bank Account',
                onPressed: () => _showAddBankModal(context, ref),
              ).animate().fadeIn(duration: 350.ms, delay: 100.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
        Text(value, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}
