import 'package:equatable/equatable.dart';

class CafeEntity extends Equatable {
  final int id;
  final String name;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final bool isActive;
  final String openStatus;

  const CafeEntity({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    this.latitude,
    this.longitude,
    this.description,
    required this.isActive,
    required this.openStatus,
  });

  factory CafeEntity.fromJson(Map<String, dynamic> json) {
    return CafeEntity(
      id: json['id'] as int,
      name: json['name'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      openStatus: json['open_status'] as String? ?? 'Tutup',
    );
  }

  @override
  List<Object?> get props => [id, name, city, address, latitude, longitude, description, isActive, openStatus];
}