import '../providers/payment_provider.dart';

class PaymentGatewayResponse {
  final bool isSuccess;
  final String transactionId;
  final String? errorMessage;
  final DateTime timestamp;

  const PaymentGatewayResponse({
    required this.isSuccess,
    required this.transactionId,
    this.errorMessage,
    required this.timestamp,
  });
}

abstract class IPaymentGatewayService {
  Future<PaymentGatewayResponse> executePayment({
    required double amount,
    required PaymentMethod method,
    required String kuriCode,
    required int installmentNumber,
  });
}

class MockPaymentGatewayService implements IPaymentGatewayService {
  @override
  Future<PaymentGatewayResponse> executePayment({
    required double amount,
    required PaymentMethod method,
    required String kuriCode,
    required int installmentNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final txnId = 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
    return PaymentGatewayResponse(
      isSuccess: true,
      transactionId: txnId,
      timestamp: DateTime.now(),
    );
  }
}
