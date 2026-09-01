import 'package:equatable/equatable.dart';

class CartItemOptionEntity extends Equatable {
  final int optionId;
  final String optionType;
  final String optionValue;
  final int extraPrice;

  const CartItemOptionEntity({
    required this.optionId,
    required this.optionType,
    required this.optionValue,
    required this.extraPrice,
  });

  Map<String, dynamic> toJson() => {
    'option_id': optionId,
    'option_type': optionType,
    'option_value': optionValue,
    'extra_price': extraPrice,
  };

  factory CartItemOptionEntity.fromJson(Map<String, dynamic> json) {
    return CartItemOptionEntity(
      optionId: json['option_id'] as int,
      optionType: json['option_type'] as String,
      optionValue: json['option_value'] as String,
      extraPrice: json['extra_price'] as int,
    );
  }

  @override
  List<Object?> get props => [optionId, optionType, optionValue, extraPrice];
}