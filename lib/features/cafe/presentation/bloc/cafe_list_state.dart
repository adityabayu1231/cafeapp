import 'package:equatable/equatable.dart';
import '../../domain/entities/cafe_entity.dart';

abstract class CafeListState extends Equatable {
  const CafeListState();

  @override
  List<Object?> get props => [];
}

class CafeListLoading extends CafeListState {
  const CafeListLoading();
}

class CafeListLoaded extends CafeListState {
  final List<CafeEntity> cafes;

  const CafeListLoaded(this.cafes);

  @override
  List<Object?> get props => [cafes];
}

class CafeListError extends CafeListState {
  final String message;

  const CafeListError(this.message);

  @override
  List<Object?> get props => [message];
}