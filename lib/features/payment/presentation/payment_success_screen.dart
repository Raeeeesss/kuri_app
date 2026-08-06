import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../kuri/models/kuri_model.dart';

class PaymentSuccessScreen extends ConsumerWidget {
  final KuriModel? kuri;

  const PaymentSuccessScreen({
    super.key,
    this.kuri,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(appLocalizationsProvider);
    final activeKuri = kuri ??
        KuriModel(
          id: '1',
          title: 'Premium Gold - Oct 2024',
          titleEn: 'Premium Gold - Oct 2024',
          code: 'GK-102',
          monthlyAmount: 12500.0,
          totalAmount: 375000.0,
          completedInstallments: 12,
          totalInstallments: 30,
          nextDueDate: DateTime(2024, 10, 15),
          status: 'DUE_SOON',
          frequency: 'Monthly',
        );

    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final nowStr = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Success Circle Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 64,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

              const SizedBox(height: 24),

              Text(
                loc.tr('Payment Successful!'),
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

              const SizedBox(height: 8),

              Text(
                '${loc.tr('Paid Amount')}: ${currencyFormatter.format(activeKuri.netPayableAmount)}',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

              const SizedBox(height: 28),

              // Transaction Receipt Card
              Container(
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppColors.softShadow,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      currencyFormatter.format(activeKuri.netPayableAmount),
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 16),
                    _buildReceiptRow(loc, 'Transaction ID', 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}'),
                    const SizedBox(height: 12),
                    _buildReceiptRow(loc, 'Scheme Name', activeKuri.getTitle()),
                    const SizedBox(height: 12),
                    _buildReceiptRow(loc, 'Installment', '${activeKuri.completedInstallments}th Installment'),
                    const SizedBox(height: 12),
                    _buildReceiptRow(loc, 'Payment Mode', 'Google Pay / UPI'),
                    const SizedBox(height: 12),
                    _buildReceiptRow(loc, 'Date & Time', nowStr),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),

              const SizedBox(height: 32),

              // Action Buttons
              CustomButton(
                text: loc.tr('Download Receipt'),
                isOutlined: true,
                icon: Icons.download_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.tr('Receipt downloaded to downloads folder!')),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

              const SizedBox(height: 12),

              CustomButton(
                text: loc.tr('Back to Home'),
                onPressed: () => context.go('/home'),
              ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(AppLocalizations loc, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            loc.tr(label),
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          loc.tr(value),
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
