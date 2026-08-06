class KuriModel {
  final String id;
  final String titleEn;
  final String code;
  final double monthlyAmount;
  final double totalAmount;
  final int completedInstallments;
  final int totalInstallments;
  final DateTime nextDueDate;
  final String status; // 'DUE_SOON', 'PAID', 'ACTIVE', 'COMPLETED'
  final String frequency; // 'Monthly', 'Weekly'
  final int auctionMonth;
  final double dividendAmount;
  final double fineAmount;
  final double bonusAmount;
  final int availableSeats;
  final int totalSeats;
  final String description;

  const KuriModel({
    required this.id,
    required String title,
    String? titleEn,
    required this.code,
    required this.monthlyAmount,
    required this.totalAmount,
    required this.completedInstallments,
    required this.totalInstallments,
    required this.nextDueDate,
    required this.status,
    this.frequency = 'Monthly',
    this.auctionMonth = 12,
    this.dividendAmount = 1250.0,
    this.fineAmount = 0.0,
    this.bonusAmount = 250.0,
    this.availableSeats = 5,
    this.totalSeats = 50,
    this.description = 'Government-registered Kerala Kuri scheme with high dividend returns.',
  })  : titleEn = titleEn ?? title;

  String get title => titleEn;

  String getTitle() => titleEn;

  bool get isDueSoon => status == 'DUE_SOON' && !isCompleted;
  bool get isCompleted => status == 'COMPLETED' || completedInstallments >= totalInstallments;

  int get remainingInstallments => totalInstallments - completedInstallments;
  double get currentPaidBalance => completedInstallments * monthlyAmount;
  double get remainingBalance => totalAmount - currentPaidBalance;
  double get netPayableAmount => monthlyAmount + fineAmount - dividendAmount - bonusAmount;

  KuriModel copyWith({
    String? id,
    String? title,
    String? code,
    double? monthlyAmount,
    double? totalAmount,
    int? completedInstallments,
    int? totalInstallments,
    DateTime? nextDueDate,
    String? status,
    String? frequency,
    int? auctionMonth,
    double? dividendAmount,
    double? fineAmount,
    double? bonusAmount,
    int? availableSeats,
    int? totalSeats,
    String? description,
  }) {
    return KuriModel(
      id: id ?? this.id,
      title: title ?? this.title,
      code: code ?? this.code,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      completedInstallments: completedInstallments ?? this.completedInstallments,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      status: status ?? this.status,
      frequency: frequency ?? this.frequency,
      auctionMonth: auctionMonth ?? this.auctionMonth,
      dividendAmount: dividendAmount ?? this.dividendAmount,
      fineAmount: fineAmount ?? this.fineAmount,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      description: description ?? this.description,
    );
  }
}
