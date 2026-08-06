import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../features/kuri/models/kuri_model.dart';

class KuriCard extends ConsumerWidget {
  final KuriModel kuri;
  final VoidCallback? onTap;
  final VoidCallback? onPayPressed;

  const KuriCard({
    super.key,
    required this.kuri,
    this.onTap,
    this.onPayPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(appLocalizationsProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kuri.getTitle(),
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${loc.tr('Value:')} ${currencyFormatter.format(kuri.totalAmount)}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(loc),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Divider(color: AppColors.border, height: 1),
                ),

                // Middle Stats Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      loc.tr(kuri.isDueSoon ? 'Net Due Payable' : 'Monthly Amount'),
                      currencyFormatter.format(kuri.netPayableAmount),
                    ),
                    _buildStatItem(
                      loc.tr('Progress'),
                      '${kuri.completedInstallments}/${kuri.totalInstallments} ${kuri.frequency == 'Weekly' ? loc.tr('Weekly') : loc.tr('Monthly')}',
                    ),
                    _buildStatItem(
                      loc.tr(kuri.isCompleted ? 'Status' : 'Next Due'),
                      kuri.isCompleted ? loc.tr('Closed') : DateFormat('dd MMM yyyy').format(kuri.nextDueDate),
                    ),
                  ],
                ),

                if (kuri.isCompleted) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          loc.tr('Scheme Fully Paid & Completed'),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (kuri.isDueSoon) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onPayPressed ?? onTap,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColors.primarySurface,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flash_on, size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                loc.tr('Pay Chitty Due Now'),
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppLocalizations loc) {
    Color bg;
    Color fg;
    String text;

    if (kuri.isCompleted) {
      bg = AppColors.success.withValues(alpha: 0.15);
      fg = AppColors.success;
      text = loc.tr('Closed');
    } else if (kuri.status == 'DUE_SOON') {
      bg = AppColors.warning.withValues(alpha: 0.15);
      fg = const Color(0xFFD97706);
      text = loc.tr('Due');
    } else if (kuri.status == 'PAID') {
      bg = AppColors.success.withValues(alpha: 0.15);
      fg = AppColors.success;
      text = loc.tr('Paid');
    } else {
      bg = AppColors.primarySurface;
      fg = AppColors.primary;
      text = loc.tr('Active Kuries');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
