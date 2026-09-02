import 'package:equatable/equatable.dart';
import 'order_item_option_entity.dart';

class OrderItemEntity extends Equatable {
  final int id;
  final int productId;
  final int quantity;
  final int unitPrice;
  final int subtotal;
  final List<OrderItemOptionEntity> options;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.options,
  });

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    return OrderItemEntity(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      unitPrice: json['unit_price'] as int,
      subtotal: json['subtotal'] as int,
      options: (json['options'] as List? ?? [])
          .map((e) => OrderItemOptionEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, productId, quantity, unitPrice, subtotal, options];
}