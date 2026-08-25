import 'package:equatable/equatable.dart';

abstract class CafeListEvent extends Equatable {
  const CafeListEvent();

  @override
  List<Object?> get props => [];
}

class CafeListRequested extends CafeListEvent {
  final String? city;

  const CafeListRequested({this.city});

  @override
  List<Object?> get props => [city];
}

class CafeSearchChanged extends CafeListEvent {
  final String city;

  const CafeSearchChanged(this.city);

  @override
  List<Object?> get props => [city];
}