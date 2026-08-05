import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/kuri_card.dart';
import '../../../core/widgets/notification_icon_button.dart';
import '../../kuri/providers/available_chitties_provider.dart';
import '../../kuri/providers/kuri_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(appLocalizationsProvider);
    final homeState = ref.watch(homeDashboardProvider);
    final selectedPeriod = ref.watch(homePeriodFilterProvider);
    final availableItems = ref.watch(availableChittiesProvider);
    final userKuris = ref.watch(kuriListProvider).koris;
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Greeting & Notification Bell
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.tr('Good Morning,'),
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          homeState.userName,
                          style: AppTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    const NotificationIconButton(),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

                const SizedBox(height: 24),

                // Hero Green Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Frequency / Period Filter Chips (All | Monthly | Weekly | Yearly)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHomePeriodChip(ref, 'All', HomePeriodFilter.all, selectedPeriod),
                              _buildHomePeriodChip(ref, 'Monthly', HomePeriodFilter.monthly, selectedPeriod),
                              _buildHomePeriodChip(ref, 'Weekly', HomePeriodFilter.weekly, selectedPeriod),
                              _buildHomePeriodChip(ref, 'Yearly', HomePeriodFilter.yearly, selectedPeriod),
                            ],
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              loc.tr('Total Due Amount'),
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${homeState.activeKuris.length} ${loc.tr('Active Kuries')}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currencyFormatter.format(homeState.nextDueAmount),
                        style: AppTypography.headlineLarge.copyWith(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${loc.tr('Next Due')}: ${DateFormat('dd MMM yyyy').format(homeState.nextDueDate)}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Pay Now or Passbook Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            if (homeState.hasDueSoonKuri) {
                              context.push('/payment');
                            } else {
                              context.go('/payments');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                homeState.hasDueSoonKuri ? Icons.payment_rounded : Icons.receipt_long_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    homeState.hasDueSoonKuri ? loc.tr('Pay Chitty Due Now') : loc.tr('View Passbook & Ledger'),
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1)),

                const SizedBox(height: 28),

                // Your Active Kuries Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.tr('Your Active Kuries'),
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/my-kuris'),
                      child: Text(
                        loc.tr('View All'),
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: 12),

                // Active Kuries List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: homeState.activeKuris.length,
                  itemBuilder: (context, index) {
                    final kuri = homeState.activeKuris[index];
                    return KuriCard(
                      kuri: kuri,
                      onTap: () => context.push('/kuri-details', extra: kuri),
                      onPayPressed: () => context.push('/payment', extra: kuri),
                    ).animate().fadeIn(duration: 350.ms, delay: Duration(milliseconds: 250 + (index * 80)));
                  },
                ),

                const SizedBox(height: 28),

                // Available Chitties Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Chitties to Join',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/available-chitties'),
                      child: Text(
                        'Explore All',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                const SizedBox(height: 12),

                // Available Chitties Horizontal Scroll
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: availableItems.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final item = availableItems[index];
                      final kuri = item.kuri;
                      final isJoined = item.isAlreadyJoined;
                      final matchingUserKuri = userKuris.firstWhere(
                        (k) => k.code == kuri.code,
                        orElse: () => kuri,
                      );

                      return Container(
                        width: 260,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isJoined ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
                            width: isJoined ? 1.5 : 1.0,
                          ),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    kuri.code,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isJoined ? AppColors.success.withValues(alpha: 0.15) : AppColors.accentLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isJoined ? loc.tr('Already Joined') : loc.tr('${kuri.availableSeats} Seats Left'),
                                    style: AppTypography.caption.copyWith(
                                      color: isJoined ? AppColors.success : const Color(0xFFB45309),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              kuri.getTitle(loc.isMalayalam),
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.tr('Monthly Amount'),
                                      style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                                    ),
                                    Text(
                                      currencyFormatter.format(kuri.monthlyAmount),
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    if (isJoined) {
                                      context.push('/kuri-details', extra: matchingUserKuri);
                                    } else {
                                      context.push('/apply-kuri', extra: kuri);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isJoined ? AppColors.surface : AppColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                      border: isJoined ? Border.all(color: AppColors.primary, width: 1.2) : null,
                                    ),
                                    child: Text(
                                      isJoined ? loc.tr('My Kuris') : loc.tr('Apply Now'),
                                      style: AppTypography.caption.copyWith(
                                        color: isJoined ? AppColors.primary : Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomePeriodChip(WidgetRef ref, String label, HomePeriodFilter filter, HomePeriodFilter selected) {
    final loc = ref.watch(appLocalizationsProvider);
    final isSelected = filter == selected;
    return GestureDetector(
      onTap: () => ref.read(homePeriodFilterProvider.notifier).state = filter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          loc.tr(label),
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.9),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
