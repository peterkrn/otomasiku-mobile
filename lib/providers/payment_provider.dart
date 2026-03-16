import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bca_va_response.dart';

/// Provider for managing BCA Virtual Account payment state
final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier();
});

/// Payment state
class PaymentState {
  final BcaVaResponse? vaResponse;
  final String? vaNumber;
  final DateTime? expiryDate;
  final String? status;
  final int? amount;
  final bool isLoading;
  final String? error;

  const PaymentState({
    this.vaResponse,
    this.vaNumber,
    this.expiryDate,
    this.status,
    this.amount,
    this.isLoading = false,
    this.error,
  });

  PaymentState copyWith({
    BcaVaResponse? vaResponse,
    String? vaNumber,
    DateTime? expiryDate,
    String? status,
    int? amount,
    bool? isLoading,
    String? error,
  }) {
    return PaymentState(
      vaResponse: vaResponse ?? this.vaResponse,
      vaNumber: vaNumber ?? this.vaNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Payment notifier
class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier() : super(const PaymentState());

  /// Set VA response from BCA API
  void setVaResponse(BcaVaResponse response) {
    state = state.copyWith(
      vaResponse: response,
      vaNumber: response.vaNumber,
      expiryDate: response.expiryDate,
      status: response.status,
      amount: response.amount,
    );
  }

  /// Update payment status (from polling or callback)
  void updateStatus(String status) {
    state = state.copyWith(status: status);
  }

  /// Clear payment state
  void clear() {
    state = const PaymentState();
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Set error state
  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }
}
