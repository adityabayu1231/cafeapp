import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartStarted extends CartEvent {
  const CartStarted();
}

class ItemAddedToCart extends CartEvent {
  final int cafeId;
  final String cafeName;
  final CartItemEntity item;

  const ItemAddedToCart({
    required this.cafeId,
    required this.cafeName,
    required this.item,
  });

  @override
  List<Object?> get props => [cafeId, cafeName, item];
}

class ItemRemovedFromCart extends CartEvent {
  final String mergeKey;
  const ItemRemovedFromCart(this.mergeKey);

  @override
  List<Object?> get props => [mergeKey];
}

class CartCleared extends CartEvent {
  const CartCleared();
}