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

class KuriApplicationScreen extends ConsumerStatefulWidget {
  final KuriModel? kuri;

  const KuriApplicationScreen({super.key, this.kuri});

  @override
  ConsumerState<KuriApplicationScreen> createState() => _KuriApplicationScreenState();
}

class _KuriApplicationScreenState extends ConsumerState<KuriApplicationScreen> {
  int _selectedTickets = 1;
  bool _isSubmitting = false;

  void _submitApplication(KuriModel activeKuri, AppLocalizations loc) async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            Text(
              loc.tr('Application Submitted!'),
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '${loc.tr('Your application for')} ${activeKuri.getTitle()} (${loc.tr('$_selectedTickets Ticket')}) ${loc.tr('has been submitted for approval.')}',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: loc.tr('Go to My Kuris'),
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/my-kuris');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(appLocalizationsProvider);
    final activeKuri = widget.kuri ??
        KuriModel(
          id: '5',
          title: 'Kerala Diamond Savings Scheme',
          titleEn: 'Kerala Diamond Savings Scheme',
          code: 'KD-901',
          monthlyAmount: 20000.0,
          totalAmount: 600000.0,
          completedInstallments: 0,
          totalInstallments: 30,
          nextDueDate: DateTime.now().add(const Duration(days: 15)),
          status: 'ACTIVE',
          availableSeats: 8,
        );

    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 22),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(
          loc.tr('Kuri Application'),
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Box
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
                              Text(
                                activeKuri.code,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                loc.tr('${activeKuri.availableSeats} Seats Left'),
                                style: AppTypography.caption.copyWith(color: AppColors.warning),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            activeKuri.getTitle(),
                            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(loc.tr('Total Scheme Value:'), style: AppTypography.bodyMedium),
                              Text(
                                currencyFormatter.format(activeKuri.totalAmount),
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(loc.tr('Monthly Installment:'), style: AppTypography.bodyMedium),
                              Text(
                                currencyFormatter.format(activeKuri.monthlyAmount),
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 350.ms),

                    const SizedBox(height: 24),
                    Text(
                      loc.tr('Select Number of Tickets'),
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: List.generate(
                        3,
                        (index) {
                          final count = index + 1;
                          final isSelected = _selectedTickets == count;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: index == 2 ? 0 : 10),
                              child: InkWell(
                                onTap: () => setState(() => _selectedTickets = count),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.border,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        loc.tr('$count Ticket${count > 1 ? 's' : ''}'),
                                        style: AppTypography.titleMedium.copyWith(
                                          color: isSelected ? Colors.white : AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currencyFormatter.format(activeKuri.monthlyAmount * count),
                                        style: AppTypography.caption.copyWith(
                                          color: isSelected ? Colors.white70 : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      loc.tr('KYC & Verification'),
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              loc.tr('Your verified profile KYC details (Aadhaar & PAN) will be attached automatically.'),
                              style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: AppColors.softShadow,
              ),
              child: CustomButton(
                text: loc.tr('Submit Kuri Application'),
                isLoading: _isSubmitting,
                onPressed: () => _submitApplication(activeKuri, loc),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
