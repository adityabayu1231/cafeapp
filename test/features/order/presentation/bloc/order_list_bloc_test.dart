import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/order/domain/entities/order_entity.dart';
import 'package:cafeapp/features/order/domain/entities/order_list_result.dart';
import 'package:cafeapp/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:cafeapp/features/order/presentation/bloc/order_list_bloc.dart';
import 'package:cafeapp/features/order/presentation/bloc/order_list_event.dart';
import 'package:cafeapp/features/order/presentation/bloc/order_list_state.dart';

class MockGetOrdersUseCase extends Mock implements GetOrdersUseCase {}

void main() {
  late OrderListBloc orderListBloc;
  late MockGetOrdersUseCase mockGetOrdersUseCase;

  final order = OrderEntity(
    id: 1,
    userId: 10,
    cafeId: 5,
    status: 'pending',
    totalAmount: 25000,
    createdAt: DateTime(2026, 8, 31),
    items: const [],
  );

  setUp(() {
    mockGetOrdersUseCase = MockGetOrdersUseCase();
    orderListBloc = OrderListBloc(getOrdersUseCase: mockGetOrdersUseCase);
  });

  tearDown(() {
    orderListBloc.close();
  });

  test('initial state is OrderListLoading', () {
    expect(orderListBloc.state, const OrderListLoading());
  });

  group('OrderListRequested', () {
    blocTest<OrderListBloc, OrderListState>(
      'emits [OrderListLoading, OrderListLoaded] when fetch succeeds',
      build: () {
        when(() => mockGetOrdersUseCase()).thenAnswer(
              (_) async => Right(OrderListResult(
            items: [order],
            currentPage: 1,
            lastPage: 1,
            total: 1,
          )),
        );
        return orderListBloc;
      },
      act: (bloc) => bloc.add(const OrderListRequested()),
      expect: () => [
        const OrderListLoading(),
        OrderListLoaded([order]),
      ],
    );

    blocTest<OrderListBloc, OrderListState>(
      'emits [OrderListLoading, OrderListError] when fetch fails',
      build: () {
        when(() => mockGetOrdersUseCase()).thenAnswer(
              (_) async => const Left(ServerFailure('Tidak dapat terhubung ke server.')),
        );
        return orderListBloc;
      },
      act: (bloc) => bloc.add(const OrderListRequested()),
      expect: () => [
        const OrderListLoading(),
        const OrderListError('Tidak dapat terhubung ke server.'),
      ],
    );
  });
}