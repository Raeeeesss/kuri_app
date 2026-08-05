import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/notification_icon_button.dart';
import '../models/kuri_model.dart';
import '../providers/available_chitties_provider.dart';
import '../providers/kuri_provider.dart';

class AvailableChittiesScreen extends ConsumerWidget {
  const AvailableChittiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(appLocalizationsProvider);
    final activeFilter = ref.watch(chittyFilterProvider);
    final availableItems = ref.watch(availableChittiesProvider);
    final userKuris = ref.watch(kuriListProvider).koris;
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 22),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(
          loc.tr('Chitties Catalog'),
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: const [
          NotificationIconButton(),
          SizedBox(width: 8),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Options Chip Bar (All / New / Joined)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      ref: ref,
                      label: loc.tr('All Chitties'),
                      filter: AvailableChittyFilter.all,
                      isSelected: activeFilter == AvailableChittyFilter.all,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      ref: ref,
                      label: loc.tr('New Chitties'),
                      filter: AvailableChittyFilter.newOnly,
                      isSelected: activeFilter == AvailableChittyFilter.newOnly,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      ref: ref,
                      label: loc.tr('Already Joined'),
                      filter: AvailableChittyFilter.joined,
                      isSelected: activeFilter == AvailableChittyFilter.joined,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Chitties List
            Expanded(
              child: availableItems.isEmpty
                  ? Center(
                      child: Text(
                        loc.tr('No Chitties found for selected filter.'),
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: availableItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = availableItems[index];
                        final matchingUserKuri = userKuris.firstWhere(
                          (k) => k.code == item.kuri.code,
                          orElse: () => item.kuri,
                        );

                        return _buildAvailableCard(context, ref, loc, item, matchingUserKuri, currencyFormatter)
                            .animate()
                            .fadeIn(duration: 350.ms, delay: Duration(milliseconds: index * 60));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required WidgetRef ref,
    required String label,
    required AvailableChittyFilter filter,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        ref.read(chittyFilterProvider.notifier).state = filter;
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildAvailableCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
    AvailableChittyItem item,
    KuriModel matchingUserKuri,
    NumberFormat formatter,
  ) {
    final kuri = item.kuri;
    final isJoined = item.isAlreadyJoined;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isJoined ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
          width: isJoined ? 1.5 : 1.0,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  kuri.code,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isJoined ? AppColors.success.withValues(alpha: 0.15) : AppColors.accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isJoined ? Icons.check_circle_rounded : Icons.event_seat_rounded,
                      size: 14,
                      color: isJoined ? AppColors.success : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isJoined ? loc.tr('Already Joined') : loc.tr('${kuri.availableSeats} Seats Left'),
                      style: AppTypography.caption.copyWith(
                        color: isJoined ? AppColors.success : const Color(0xFFB45309),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            kuri.title,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.tr(kuri.description),
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(loc.tr('Total Value'), formatter.format(kuri.totalAmount)),
              _buildStat(loc.tr('Monthly Installment'), formatter.format(kuri.monthlyAmount)),
              _buildStat(loc.tr('Duration'), loc.tr('${kuri.totalInstallments} Months')),
            ],
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (isJoined) {
                  context.push('/kuri-details', extra: matchingUserKuri);
                } else {
                  context.push('/apply-kuri', extra: kuri);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isJoined ? AppColors.surface : AppColors.primary,
                foregroundColor: isJoined ? AppColors.primary : Colors.white,
                elevation: 0,
                side: isJoined ? const BorderSide(color: AppColors.primary, width: 1.5) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isJoined ? loc.tr('View My Chitty') : loc.tr('Apply & Join Kuri'),
                    style: AppTypography.titleMedium.copyWith(
                      color: isJoined ? AppColors.primary : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isJoined ? Icons.visibility_rounded : Icons.arrow_forward_rounded,
                    color: isJoined ? AppColors.primary : Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
