import 'package:equatable/equatable.dart';

class ProductOptionEntity extends Equatable {
  final int id;
  final int productId;
  final String optionType;
  final String optionValue;
  final int extraPrice;
  final bool isDefault;

  const ProductOptionEntity({
    required this.id,
    required this.productId,
    required this.optionType,
    required this.optionValue,
    required this.extraPrice,
    required this.isDefault,
  });

  factory ProductOptionEntity.fromJson(Map<String, dynamic> json) {
    return ProductOptionEntity(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      optionType: json['option_type'] as String,
      optionValue: json['option_value'] as String,
      extraPrice: json['extra_price'] as int,
      isDefault: json['is_default'] as bool,
    );
  }

  @override
  List<Object?> get props => [id, productId, optionType, optionValue, extraPrice, isDefault];
}