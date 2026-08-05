import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/payment_service.dart';

enum PaymentMethod { upi, netBanking, card }

class PaymentState {
  final PaymentMethod selectedMethod;
  final String selectedBank;
  final String upiId;
  final bool isProcessing;
  final String? errorMessage;
  final String? lastTransactionId;

  const PaymentState({
    this.selectedMethod = PaymentMethod.upi,
    this.selectedBank = 'State Bank of India',
    this.upiId = 'rajeshkumar@oksbi',
    this.isProcessing = false,
    this.errorMessage,
    this.lastTransactionId,
  });

  PaymentState copyWith({
    PaymentMethod? selectedMethod,
    String? selectedBank,
    String? upiId,
    bool? isProcessing,
    String? errorMessage,
    String? lastTransactionId,
  }) {
    return PaymentState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      selectedBank: selectedBank ?? this.selectedBank,
      upiId: upiId ?? this.upiId,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      lastTransactionId: lastTransactionId ?? this.lastTransactionId,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final IPaymentGatewayService _gatewayService;

  PaymentNotifier(this._gatewayService) : super(const PaymentState());

  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedMethod: method);
  }

  void selectBank(String bank) {
    state = state.copyWith(selectedBank: bank);
  }

  void setUpiId(String upi) {
    state = state.copyWith(upiId: upi);
  }

  Future<bool> processPayment({
    required double amount,
    required String kuriCode,
    required int installmentNumber,
  }) async {
    state = state.copyWith(isProcessing: true, errorMessage: null);

    final response = await _gatewayService.executePayment(
      amount: amount,
      method: state.selectedMethod,
      kuriCode: kuriCode,
      installmentNumber: installmentNumber,
    );

    if (response.isSuccess) {
      state = state.copyWith(
        isProcessing: false,
        lastTransactionId: response.transactionId,
      );
      return true;
    } else {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: response.errorMessage ?? 'Payment failed. Please try again.',
      );
      return false;
    }
  }
}

final paymentGatewayProvider = Provider<IPaymentGatewayService>((ref) {
  return MockPaymentGatewayService();
});

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final gateway = ref.watch(paymentGatewayProvider);
  return PaymentNotifier(gateway);
});
