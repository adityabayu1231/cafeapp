import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/cancel_order_usecase.dart';
import '../../domain/usecases/get_order_detail_usecase.dart';
import 'order_detail_event.dart';
import 'order_detail_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final GetOrderDetailUseCase getOrderDetailUseCase;
  final CancelOrderUseCase cancelOrderUseCase;

  OrderDetailBloc({
    required this.getOrderDetailUseCase,
    required this.cancelOrderUseCase,
  }) : super(const OrderDetailLoading()) {
    on<OrderDetailRequested>(_onRequested);
    on<OrderCancelRequested>(_onCancelRequested);
  }

  Future<void> _onRequested(OrderDetailRequested event, Emitter<OrderDetailState> emit) async {
    emit(const OrderDetailLoading());
    final result = await getOrderDetailUseCase(event.orderId);
    result.fold(
          (failure) => emit(OrderDetailError(failure.message)),
          (order) => emit(OrderDetailLoaded(order)),
    );
  }

  Future<void> _onCancelRequested(OrderCancelRequested event, Emitter<OrderDetailState> emit) async {
    final currentState = state;
    if (currentState is! OrderDetailLoaded) return;

    emit(currentState.copyWith(isCancelling: true, clearCancelError: true));

    final result = await cancelOrderUseCase(currentState.order.id);

    result.fold(
          (failure) => emit(currentState.copyWith(isCancelling: false, cancelErrorMessage: failure.message)),
          (updatedOrder) => emit(OrderDetailLoaded(updatedOrder)),
    );
  }
}