import 'package:equatable/equatable.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class CatalogRequested extends CatalogEvent {
  final int cafeId;

  const CatalogRequested(this.cafeId);

  @override
  List<Object?> get props => [cafeId];
}