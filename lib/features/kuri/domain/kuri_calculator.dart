class KuriCalculationResult {
  final double totalAmount;
  final double monthlyAmount;
  final int totalInstallments;
  final int completedInstallments;
  final int remainingInstallments;
  final double currentPaidBalance;
  final double remainingBalance;
  final double dividendAmount;
  final double lateFineAmount;
  final double earlyBonusAmount;
  final double netPayableAmount;

  const KuriCalculationResult({
    required this.totalAmount,
    required this.monthlyAmount,
    required this.totalInstallments,
    required this.completedInstallments,
    required this.remainingInstallments,
    required this.currentPaidBalance,
    required this.remainingBalance,
    required this.dividendAmount,
    required this.lateFineAmount,
    required this.earlyBonusAmount,
    required this.netPayableAmount,
  });
}

class KuriCalculator {
  /// Calculate Kerala Kuri financials for a given installment.
  static KuriCalculationResult calculate({
    required double totalAmount,
    required int totalInstallments,
    required int completedInstallments,
    required DateTime nextDueDate,
    double dividendDiscountRate = 0.10, // 10% average auction dividend
    double lateFineRate = 0.015, // 1.5% per month late penalty
    double earlyBonusRate = 0.02, // 2% early payment bonus discount
  }) {
    final monthlyAmount = totalAmount / totalInstallments;
    final remainingInstallments = totalInstallments - completedInstallments;
    final currentPaidBalance = completedInstallments * monthlyAmount;
    final remainingBalance = totalAmount - currentPaidBalance;

    final now = DateTime.now();
    final isLate = now.isAfter(nextDueDate);
    final daysLate = isLate ? now.difference(nextDueDate).inDays : 0;

    double lateFineAmount = 0.0;
    if (daysLate > 0) {
      lateFineAmount = monthlyAmount * (lateFineRate * (daysLate / 30.0).clamp(0.1, 3.0));
    }

    final isEarly = now.isBefore(nextDueDate.subtract(const Duration(days: 5)));
    double earlyBonusAmount = 0.0;
    if (isEarly && !isLate) {
      earlyBonusAmount = monthlyAmount * earlyBonusRate;
    }

    final dividendAmount = monthlyAmount * dividendDiscountRate;
    final netPayableAmount = (monthlyAmount + lateFineAmount - dividendAmount - earlyBonusAmount).clamp(0.0, double.infinity);

    return KuriCalculationResult(
      totalAmount: totalAmount,
      monthlyAmount: monthlyAmount,
      totalInstallments: totalInstallments,
      completedInstallments: completedInstallments,
      remainingInstallments: remainingInstallments,
      currentPaidBalance: currentPaidBalance,
      remainingBalance: remainingBalance,
      dividendAmount: dividendAmount,
      lateFineAmount: lateFineAmount,
      earlyBonusAmount: earlyBonusAmount,
      netPayableAmount: netPayableAmount,
    );
  }
}
