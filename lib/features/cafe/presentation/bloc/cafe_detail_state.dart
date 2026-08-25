import 'package:equatable/equatable.dart';
import '../../domain/entities/cafe_detail_entity.dart';

abstract class CafeDetailState extends Equatable {
  const CafeDetailState();

  @override
  List<Object?> get props => [];
}

class CafeDetailLoading extends CafeDetailState {
  const CafeDetailLoading();
}

class CafeDetailLoaded extends CafeDetailState {
  final CafeDetailEntity detail;

  const CafeDetailLoaded(this.detail);

  @override
  List<Object?> get props => [detail];
}

class CafeDetailError extends CafeDetailState {
  final String message;

  const CafeDetailError(this.message);

  @override
  List<Object?> get props => [message];
}