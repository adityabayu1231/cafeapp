import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final int cafeId;
  final String category;
  final String name;
  final String? description;
  final int basePrice;
  final String? imagePath;
  final int serviceTimeMinutes;
  final bool isAvailable;

  const ProductEntity({
    required this.id,
    required this.cafeId,
    required this.category,
    required this.name,
    this.description,
    required this.basePrice,
    this.imagePath,
    required this.serviceTimeMinutes,
    required this.isAvailable,
  });

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['id'] as int,
      cafeId: json['cafe_id'] as int,
      category: json['category'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      basePrice: json['base_price'] as int,
      imagePath: json['image_path'] as String?,
      serviceTimeMinutes: json['service_time_minutes'] as int,
      isAvailable: json['is_available'] as bool,
    );
  }

  @override
  List<Object?> get props => [
    id,
    cafeId,
    category,
    name,
    description,
    basePrice,
    imagePath,
    serviceTimeMinutes,
    isAvailable,
  ];
}