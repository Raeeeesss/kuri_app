import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/kuri_model.dart';
import 'widgets/kuri_details_header_card.dart';

class KuriDetailsScreen extends ConsumerWidget {
  final KuriModel? kuri;

  const KuriDetailsScreen({
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 22),
          onPressed: () => context.canPop() ? context.pop() : context.go('/my-kuris'),
        ),
        title: Text(
          loc.tr('Kuri Details'),
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined, color: AppColors.primary, size: 26),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.tr('Downloading Chitty Passbook PDF...')),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KuriDetailsHeaderCard(kuri: activeKuri).animate().fadeIn(duration: 350.ms).slideY(begin: -0.05, end: 0),

                    const SizedBox(height: 24),

                    // Section 2: Installment History
                    Text(
                      loc.tr('Installment History'),
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ).animate().fadeIn(duration: 350.ms, delay: 100.ms),

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
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
                          itemBuilder: (context, index) {
                            final installmentNo = activeKuri.completedInstallments - index;
                            final dateStr = DateFormat('dd MMM yyyy').format(
                              DateTime.now().subtract(Duration(days: index * 30 + 10)),
                            );
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                              title: Text(
                                loc.tr('${installmentNo}th Installment'),
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              subtitle: Text(
                                '${loc.tr('Paid on')} $dateStr • UPI',
                                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormatter.format(activeKuri.monthlyAmount),
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      loc.tr('PAID'),
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ).animate().fadeIn(duration: 350.ms, delay: 150.ms),

                    const SizedBox(height: 24),

                    // Section 3: Auction & Dividend Info
                    Text(
                      loc.tr('Auction & Dividend'),
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ).animate().fadeIn(duration: 350.ms, delay: 200.ms),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.softShadow,
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        children: [
                          _buildAuctionRow(loc, 'Next Auction Date', '20 November 2024'),
                          const Divider(color: AppColors.border, height: 24),
                          _buildAuctionRow(loc, 'Average Dividend Earned', '₹45,000'),
                          const Divider(color: AppColors.border, height: 24),
                          _buildAuctionRow(loc, 'Total Members Won', loc.tr('12 Members')),
                        ],
                      ),
                    ).animate().fadeIn(duration: 350.ms, delay: 250.ms),

                    const SizedBox(height: 24),

                    // Section 4: Organizer Contact & Contract
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.tr('Organizer Support'),
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  loc.tr('Call +91 98470 12345 for help'),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                        ],
                      ),
                    ).animate().fadeIn(duration: 350.ms, delay: 300.ms),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Fixed Payment Button or Completed Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: activeKuri.isCompleted
                  ? Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.success, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified_rounded, color: AppColors.success, size: 22),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              loc.tr('Chitty Completed & Fully Paid'),
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  : CustomButton(
                      text: '${loc.tr('Pay Next Installment')} (${currencyFormatter.format(activeKuri.netPayableAmount)})',
                      icon: Icons.payment_rounded,
                      onPressed: () => context.push('/payment', extra: activeKuri),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuctionRow(AppLocalizations loc, String label, String value) {
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
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
