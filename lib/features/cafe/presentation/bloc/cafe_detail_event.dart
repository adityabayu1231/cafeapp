import 'package:equatable/equatable.dart';

abstract class CafeDetailEvent extends Equatable {
  const CafeDetailEvent();

  @override
  List<Object?> get props => [];
}

class CafeDetailRequested extends CafeDetailEvent {
  final int cafeId;

  const CafeDetailRequested(this.cafeId);

  @override
  List<Object?> get props => [cafeId];
}