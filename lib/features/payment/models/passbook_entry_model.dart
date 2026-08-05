class PassbookEntry {
  final String id;
  final String kuriTitle;
  final String kuriCode;
  final int installmentNumber;
  final double amount;
  final DateTime date;
  final String paymentMethod;
  final String transactionId;
  final String status; // 'SUCCESS', 'DUE', 'PENDING'

  const PassbookEntry({
    required this.id,
    required this.kuriTitle,
    required this.kuriCode,
    required this.installmentNumber,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
  });

  bool get isPaid => status == 'SUCCESS';
  bool get isDue => status == 'DUE';
}
