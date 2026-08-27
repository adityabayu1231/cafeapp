import 'package:equatable/equatable.dart';
import 'product_entity.dart';
import 'product_option_entity.dart';

class ProductDetailEntity extends Equatable {
  final ProductEntity product;
  final List<ProductOptionEntity> options;

  const ProductDetailEntity({
    required this.product,
    required this.options,
  });

  factory ProductDetailEntity.fromJson(Map<String, dynamic> json) {
    return ProductDetailEntity(
      product: ProductEntity.fromJson(json),
      options: (json['options'] as List? ?? [])
          .map((e) => ProductOptionEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [product, options];
}