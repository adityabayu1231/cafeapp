import 'package:equatable/equatable.dart';
import 'cart_item_option_entity.dart';

class CartItemEntity extends Equatable {
  final int productId;
  final String productName;
  final int basePrice;
  final int quantity;
  final List<CartItemOptionEntity> selectedOptions;

  const CartItemEntity({
    required this.productId,
    required this.productName,
    required this.basePrice,
    required this.quantity,
    required this.selectedOptions,
  });

  /// Kunci deterministik untuk deteksi item identik (produk + kombinasi opsi
  /// sama persis, tanpa peduli urutan) — dipakai untuk merge quantity,
  /// bukan entry baru. Lihat plan.md §11.
  String get mergeKey {
    final sortedIds = selectedOptions.map((o) => o.optionId).toList()..sort();
    return '$productId-${sortedIds.join('-')}';
  }

  int get unitPrice =>
      basePrice + selectedOptions.fold(0, (sum, o) => sum + o.extraPrice);

  int get subtotal => unitPrice * quantity;

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      productId: productId,
      productName: productName,
      basePrice: basePrice,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions,
    );
  }

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'product_name': productName,
    'base_price': basePrice,
    'quantity': quantity,
    'selected_options': selectedOptions.map((o) => o.toJson()).toList(),
  };

  factory CartItemEntity.fromJson(Map<String, dynamic> json) {
    return CartItemEntity(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      basePrice: json['base_price'] as int,
      quantity: json['quantity'] as int,
      selectedOptions: (json['selected_options'] as List)
          .map((o) => CartItemOptionEntity.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [productId, productName, basePrice, quantity, selectedOptions];
}