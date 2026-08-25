import 'package:equatable/equatable.dart';

class CafePhotoEntity extends Equatable {
  final int id;
  final String photoPath;
  final int sortOrder;

  const CafePhotoEntity({
    required this.id,
    required this.photoPath,
    required this.sortOrder,
  });

  factory CafePhotoEntity.fromJson(Map<String, dynamic> json) {
    return CafePhotoEntity(
      id: json['id'] as int,
      photoPath: json['photo_path'] as String,
      sortOrder: json['sort_order'] as int,
    );
  }

  @override
  List<Object?> get props => [id, photoPath, sortOrder];
}