import 'package:equatable/equatable.dart';
import 'wallet_transaction_entity.dart';

class WalletResult extends Equatable {
  final int balance;
  final List<WalletTransactionEntity> transactions;
  final int currentPage;
  final int lastPage;
  final int total;

  const WalletResult({
    required this.balance,
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  @override
  List<Object?> get props => [balance, transactions, currentPage, lastPage, total];
}