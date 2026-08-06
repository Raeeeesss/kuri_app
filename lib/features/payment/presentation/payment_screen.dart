import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/security_badge.dart';
import '../../kuri/models/kuri_model.dart';
import '../../kuri/providers/kuri_provider.dart';
import '../providers/passbook_provider.dart';
import '../providers/payment_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final KuriModel? kuri;

  const PaymentScreen({
    super.key,
    this.kuri,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final TextEditingController _upiController = TextEditingController(text: 'rajeshkumar@oksbi');
  final TextEditingController _cardNumberController = TextEditingController();

  @override
  void dispose() {
    _upiController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }

  void _handlePayment(KuriModel activeKuri) async {
    final paymentNotifier = ref.read(paymentProvider.notifier);
    final paymentState = ref.read(paymentProvider);

    final success = await paymentNotifier.processPayment(
      amount: activeKuri.netPayableAmount,
      kuriCode: activeKuri.code,
      installmentNumber: activeKuri.completedInstallments + 1,
    );

    if (!mounted) return;

    if (success) {
      ref.read(kuriListProvider.notifier).markInstallmentAsPaid(activeKuri.id);

      ref.read(passbookProvider.notifier).addPaidEntry(
            kuriTitle: activeKuri.title,
            kuriCode: activeKuri.code,
            installmentNumber: activeKuri.completedInstallments + 1,
            amount: activeKuri.netPayableAmount,
            paymentMethod: paymentState.selectedMethod.name.toUpperCase(),
            transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
          );

      context.go('/payment-success', extra: activeKuri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(appLocalizationsProvider);
    final activeKuri = widget.kuri ??
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

    final paymentState = ref.watch(paymentProvider);
    final paymentNotifier = ref.read(paymentProvider.notifier);
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 22),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(
          loc.tr('Chitty Payment'),
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: const [
          Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
          SizedBox(width: 16),
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
                    // Summary Breakdown Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22.0),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppColors.softShadow,
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                activeKuri.getTitle(),
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  activeKuri.code,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currencyFormatter.format(activeKuri.netPayableAmount),
                            style: AppTypography.headlineLarge.copyWith(
                              color: AppColors.primary,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.border, height: 1),
                          const SizedBox(height: 12),
                          _buildBreakdownRow(loc.tr('Monthly Base Amount'), currencyFormatter.format(activeKuri.monthlyAmount)),
                          const SizedBox(height: 6),
                          _buildBreakdownRow(loc.tr('Auction Dividend Discount'), '- ${currencyFormatter.format(activeKuri.dividendAmount)}', isDiscount: true),
                          const SizedBox(height: 6),
                          _buildBreakdownRow(loc.tr('Early Payment Bonus'), '- ${currencyFormatter.format(activeKuri.bonusAmount)}', isDiscount: true),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${loc.tr('Due Date:')} ${DateFormat('dd MMM yyyy').format(activeKuri.nextDueDate)}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: const Color(0xFFD97706),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.05, end: 0),

                    const SizedBox(height: 24),

                    // Payment Method Section Header
                    Text(
                      loc.tr('Select Payment Method'),
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ).animate().fadeIn(duration: 350.ms, delay: 100.ms),

                    const SizedBox(height: 14),

                    // Payment Method Options
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.softShadow,
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        children: [
                          _buildPaymentMethodOption(
                            context,
                            method: PaymentMethod.upi,
                            title: 'Google Pay / PhonePe / UPI',
                            subtitle: 'Instant 0-fee payment via any UPI app',
                            icon: Icons.account_balance_wallet,
                            selected: paymentState.selectedMethod == PaymentMethod.upi,
                            onTap: () => paymentNotifier.selectPaymentMethod(PaymentMethod.upi),
                          ),
                          if (paymentState.selectedMethod == PaymentMethod.upi)
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                              child: TextField(
                                controller: _upiController,
                                onChanged: (val) => paymentNotifier.setUpiId(val),
                                decoration: InputDecoration(
                                  labelText: 'VPA / UPI ID',
                                  hintText: 'e.g. mobile@upi',
                                  prefixIcon: const Icon(Icons.qr_code, color: AppColors.primary),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                          const Divider(color: AppColors.border, height: 1),
                          _buildPaymentMethodOption(
                            context,
                            method: PaymentMethod.netBanking,
                            title: 'Net Banking (SBI, HDFC, Federal)',
                            subtitle: 'All Indian banks supported',
                            icon: Icons.account_balance,
                            selected: paymentState.selectedMethod == PaymentMethod.netBanking,
                            onTap: () => paymentNotifier.selectPaymentMethod(PaymentMethod.netBanking),
                          ),
                          if (paymentState.selectedMethod == PaymentMethod.netBanking)
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                              child: DropdownButtonFormField<String>(
                                initialValue: paymentState.selectedBank,
                                decoration: const InputDecoration(
                                  labelText: 'Select Bank',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'State Bank of India', child: Text('State Bank of India (SBI)')),
                                  DropdownMenuItem(value: 'HDFC Bank', child: Text('HDFC Bank')),
                                  DropdownMenuItem(value: 'Federal Bank', child: Text('Federal Bank')),
                                  DropdownMenuItem(value: 'ICICI Bank', child: Text('ICICI Bank')),
                                  DropdownMenuItem(value: 'Axis Bank', child: Text('Axis Bank')),
                                ],
                                onChanged: (val) {
                                  if (val != null) paymentNotifier.selectBank(val);
                                },
                              ),
                            ),
                          const Divider(color: AppColors.border, height: 1),
                          _buildPaymentMethodOption(
                            context,
                            method: PaymentMethod.card,
                            title: 'Debit / Credit Card',
                            subtitle: 'Visa, MasterCard, RuPay',
                            icon: Icons.credit_card,
                            selected: paymentState.selectedMethod == PaymentMethod.card,
                            onTap: () => paymentNotifier.selectPaymentMethod(PaymentMethod.card),
                          ),
                          if (paymentState.selectedMethod == PaymentMethod.card)
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                              child: TextField(
                                controller: _cardNumberController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Card Number',
                                  hintText: '4532 XXXX XXXX 8912',
                                  prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 350.ms, delay: 150.ms),

                    const SizedBox(height: 24),

                    // Recent History Section
                    Text(
                      'Recent Payment History',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ).animate().fadeIn(duration: 350.ms, delay: 200.ms),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        children: [
                          _buildRecentPaymentRow(
                            '12th Installment (${activeKuri.code})',
                            currencyFormatter.format(activeKuri.netPayableAmount),
                            '10 Sep 2024',
                          ),
                          const Divider(color: AppColors.border, height: 20),
                          _buildRecentPaymentRow(
                            '11th Installment (${activeKuri.code})',
                            currencyFormatter.format(activeKuri.netPayableAmount),
                            '10 Aug 2024',
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 350.ms, delay: 250.ms),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Payment Button
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
              child: Column(
                children: [
                  CustomButton(
                    text: '${loc.tr('Proceed to Pay')} ${currencyFormatter.format(activeKuri.netPayableAmount)}',
                    isLoading: paymentState.isProcessing,
                    onPressed: () => _handlePayment(activeKuri),
                  ),
                  const SizedBox(height: 10),
                  const SecurityBadge(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: isDiscount ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(
    BuildContext context, {
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primarySurface : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPaymentRow(String title, String amount, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 2),
            const Text(
              'SUCCESS',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
