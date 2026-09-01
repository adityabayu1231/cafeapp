import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartState extends Equatable {
  final List<CartItemEntity> items;
  final int? cafeId;
  final String? cafeName;
  final bool isLoading;

  const CartState({
    this.items = const [],
    this.cafeId,
    this.cafeName,
    this.isLoading = true,
  });

  int get totalPreview => items.fold(0, (sum, i) => sum + i.subtotal);

  CartState copyWith({
    List<CartItemEntity>? items,
    int? cafeId,
    String? cafeName,
    bool? isLoading,
    bool clearCafe = false,
  }) {
    return CartState(
      items: items ?? this.items,
      cafeId: clearCafe ? null : (cafeId ?? this.cafeId),
      cafeName: clearCafe ? null : (cafeName ?? this.cafeName),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [items, cafeId, cafeName, isLoading];
}