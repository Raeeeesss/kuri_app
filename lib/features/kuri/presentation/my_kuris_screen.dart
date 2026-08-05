import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/kuri_card.dart';
import '../../../core/widgets/notification_icon_button.dart';
import '../providers/kuri_provider.dart';

class MyKurisScreen extends ConsumerWidget {
  const MyKurisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(appLocalizationsProvider);
    final state = ref.watch(kuriListProvider);
    final notifier = ref.read(kuriListProvider.notifier);
    final filteredKuris = state.filteredKuris;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.tr('My Kuris'),
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                  const NotificationIconButton(),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms),

            // Segmented Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: loc.tr('All (${state.koris.length})'),
                      isSelected: state.selectedFilter == KuriFilter.all,
                      onTap: () => notifier.setFilter(KuriFilter.all),
                    ),
                    _buildFilterChip(
                      label: loc.tr('Active (${state.koris.where((k) => !k.isCompleted).length})'),
                      isSelected: state.selectedFilter == KuriFilter.active,
                      onTap: () => notifier.setFilter(KuriFilter.active),
                    ),
                    _buildFilterChip(
                      label: loc.tr('Completed (${state.koris.where((k) => k.isCompleted).length})'),
                      isSelected: state.selectedFilter == KuriFilter.completed,
                      onTap: () => notifier.setFilter(KuriFilter.completed),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 350.ms, delay: 100.ms),

            const SizedBox(height: 16),

            // List of Kuris
            Expanded(
              child: filteredKuris.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No schemes found',
                            style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      itemCount: filteredKuris.length,
                      itemBuilder: (context, index) {
                        final kuri = filteredKuris[index];
                        return KuriCard(
                          kuri: kuri,
                          onTap: () => context.push('/kuri-details', extra: kuri),
                          onPayPressed: () => context.push('/payment', extra: kuri),
                        ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 60));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
