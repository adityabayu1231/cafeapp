import 'package:equatable/equatable.dart';
import 'cafe_entity.dart';
import 'cafe_photo_entity.dart';
import 'cafe_operating_hour_entity.dart';

class CafeDetailEntity extends Equatable {
  final CafeEntity cafe;
  final List<CafePhotoEntity> photos;
  final List<CafeOperatingHourEntity> operatingHours;

  const CafeDetailEntity({
    required this.cafe,
    required this.photos,
    required this.operatingHours,
  });

  factory CafeDetailEntity.fromJson(Map<String, dynamic> json) {
    return CafeDetailEntity(
      cafe: CafeEntity.fromJson(json),
      photos: (json['photos'] as List? ?? [])
          .map((e) => CafePhotoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      operatingHours: (json['operating_hours'] as List? ?? [])
          .map((e) => CafeOperatingHourEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [cafe, photos, operatingHours];
}