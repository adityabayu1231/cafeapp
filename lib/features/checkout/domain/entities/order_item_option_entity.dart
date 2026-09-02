import 'package:equatable/equatable.dart';

class OrderItemOptionEntity extends Equatable {
  final int id;
  final String optionType;
  final String optionValue;
  final int extraPrice;

  const OrderItemOptionEntity({
    required this.id,
    required this.optionType,
    required this.optionValue,
    required this.extraPrice,
  });

  factory OrderItemOptionEntity.fromJson(Map<String, dynamic> json) {
    return OrderItemOptionEntity(
      id: json['id'] as int,
      optionType: json['option_type'] as String,
      optionValue: json['option_value'] as String,
      extraPrice: json['extra_price'] as int,
    );
  }

  @override
  List<Object?> get props => [id, optionType, optionValue, extraPrice];
}