import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import 'order_list_event.dart';
import 'order_list_state.dart';

class OrderListBloc extends Bloc<OrderListEvent, OrderListState> {
  final GetOrdersUseCase getOrdersUseCase;

  OrderListBloc({required this.getOrdersUseCase}) : super(const OrderListLoading()) {
    on<OrderListRequested>(_onRequested);
  }

  Future<void> _onRequested(OrderListRequested event, Emitter<OrderListState> emit) async {
    emit(const OrderListLoading());
    final result = await getOrdersUseCase();
    result.fold(
          (failure) => emit(OrderListError(failure.message)),
          (data) => emit(OrderListLoaded(data.items)),
    );
  }
}