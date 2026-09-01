import 'package:equatable/equatable.dart';

class WalletTransactionEntity extends Equatable {
  final int id;
  final String type;
  final int amount;
  final String? referenceType;
  final int? referenceId;
  final int balanceAfter;
  final DateTime createdAt;

  const WalletTransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    this.referenceType,
    this.referenceId,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory WalletTransactionEntity.fromJson(Map<String, dynamic> json) {
    return WalletTransactionEntity(
      id: json['id'] as int,
      type: json['type'] as String,
      amount: json['amount'] as int,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as int?,
      balanceAfter: json['balance_after'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props =>
      [id, type, amount, referenceType, referenceId, balanceAfter, createdAt];
}