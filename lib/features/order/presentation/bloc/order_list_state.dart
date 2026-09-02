import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderListState extends Equatable {
  const OrderListState();
  @override
  List<Object?> get props => [];
}

class OrderListLoading extends OrderListState {
  const OrderListLoading();
}

class OrderListLoaded extends OrderListState {
  final List<OrderEntity> orders;
  const OrderListLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderListError extends OrderListState {
  final String message;
  const OrderListError(this.message);

  @override
  List<Object?> get props => [message];
}