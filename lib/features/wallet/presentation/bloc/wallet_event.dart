import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class WalletBalanceRequested extends WalletEvent {
  const WalletBalanceRequested();
}

/// Dipanggil CheckoutBloc SEBELUM submit order, untuk pre-check UX
/// (validasi final tetap di backend). Lihat plan.md §11.
class WalletBalanceChecked extends WalletEvent {
  final int requiredAmount;
  const WalletBalanceChecked(this.requiredAmount);

  @override
  List<Object?> get props => [requiredAmount];
}