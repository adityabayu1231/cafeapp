import 'package:equatable/equatable.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => [];
}

class CheckoutSubmitted extends CheckoutEvent {
  final String? notes;
  const CheckoutSubmitted({this.notes});

  @override
  List<Object?> get props => [notes];
}