import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();
  @override
  List<Object?> get props => [];
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderDetailState {
  final OrderEntity order;
  final bool isCancelling;
  final String? cancelErrorMessage;

  const OrderDetailLoaded(
      this.order, {
        this.isCancelling = false,
        this.cancelErrorMessage,
      });

  OrderDetailLoaded copyWith({
    OrderEntity? order,
    bool? isCancelling,
    String? cancelErrorMessage,
    bool clearCancelError = false,
  }) {
    return OrderDetailLoaded(
      order ?? this.order,
      isCancelling: isCancelling ?? this.isCancelling,
      cancelErrorMessage: clearCancelError ? null : (cancelErrorMessage ?? this.cancelErrorMessage),
    );
  }

  @override
  List<Object?> get props => [order, isCancelling, cancelErrorMessage];
}

class OrderDetailError extends OrderDetailState {
  final String message;
  const OrderDetailError(this.message);

  @override
  List<Object?> get props => [message];
}