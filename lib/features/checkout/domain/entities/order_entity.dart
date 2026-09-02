import 'package:equatable/equatable.dart';
import 'order_item_entity.dart';

class OrderEntity extends Equatable {
  final int id;
  final int userId;
  final int cafeId;
  final String status;
  final int totalAmount;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItemEntity> items;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.cafeId,
    required this.status,
    required this.totalAmount,
    this.notes,
    required this.createdAt,
    required this.items,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      cafeId: json['cafe_id'] as int,
      status: json['status'] as String,
      totalAmount: json['total_amount'] as int,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItemEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, userId, cafeId, status, totalAmount, notes, createdAt, items];
}