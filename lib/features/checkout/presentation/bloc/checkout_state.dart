import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

class CheckoutSuccess extends CheckoutState {
  final OrderEntity order;
  const CheckoutSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

class CheckoutFailure extends CheckoutState {
  final String message;
  final bool isInsufficientBalance;

  const CheckoutFailure(this.message, {this.isInsufficientBalance = false});

  @override
  List<Object?> get props => [message, isInsufficientBalance];
}