import 'package:equatable/equatable.dart';

class CafeOperatingHourEntity extends Equatable {
  final int dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  const CafeOperatingHourEntity({
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    required this.isClosed,
  });

  factory CafeOperatingHourEntity.fromJson(Map<String, dynamic> json) {
    return CafeOperatingHourEntity(
      dayOfWeek: json['day_of_week'] as int,
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
      isClosed: json['is_closed'] as bool,
    );
  }

  @override
  List<Object?> get props => [dayOfWeek, openTime, closeTime, isClosed];
}