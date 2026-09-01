import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_transaction_entity.dart';

abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final int balance;
  final List<WalletTransactionEntity> transactions;

  const WalletLoaded({required this.balance, required this.transactions});

  @override
  List<Object?> get props => [balance, transactions];
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State khusus saat pre-check saldo (dipicu CheckoutBloc) mendeteksi
/// balance < requiredAmount. Tetap membawa balance & transactions supaya
/// UI wallet tidak kehilangan data saat state ini di-emit.
class WalletInsufficientBalance extends WalletState {
  final int balance;
  final int requiredAmount;
  final List<WalletTransactionEntity> transactions;

  const WalletInsufficientBalance({
    required this.balance,
    required this.requiredAmount,
    required this.transactions,
  });

  @override
  List<Object?> get props => [balance, requiredAmount, transactions];
}