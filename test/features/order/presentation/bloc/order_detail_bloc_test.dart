import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/order/domain/entities/order_entity.dart';
import 'package:cafeapp/features/order/domain/usecases/cancel_order_usecase.dart';
import 'package:cafeapp/features/order/domain/usecases/get_order_detail_usecase.dart';
import 'package:cafeapp/features/order/presentation/bloc/order_detail_bloc.dart';
import 'package:cafeapp/features/order/presentation/bloc/order_detail_event.dart';
import 'package:cafeapp/features/order/presentation/bloc/order_detail_state.dart';

class MockGetOrderDetailUseCase extends Mock implements GetOrderDetailUseCase {}
class MockCancelOrderUseCase extends Mock implements CancelOrderUseCase {}

void main() {
  late OrderDetailBloc orderDetailBloc;
  late MockGetOrderDetailUseCase mockGetOrderDetailUseCase;
  late MockCancelOrderUseCase mockCancelOrderUseCase;

  final pendingOrder = OrderEntity(
    id: 1,
    userId: 10,
    cafeId: 5,
    status: 'pending',
    totalAmount: 25000,
    createdAt: DateTime(2026, 8, 31),
    items: const [],
  );

  final cancelledOrder = OrderEntity(
    id: 1,
    userId: 10,
    cafeId: 5,
    status: 'cancelled',
    totalAmount: 25000,
    createdAt: DateTime(2026, 8, 31),
    items: const [],
  );

  setUp(() {
    mockGetOrderDetailUseCase = MockGetOrderDetailUseCase();
    mockCancelOrderUseCase = MockCancelOrderUseCase();
    orderDetailBloc = OrderDetailBloc(
      getOrderDetailUseCase: mockGetOrderDetailUseCase,
      cancelOrderUseCase: mockCancelOrderUseCase,
    );
  });

  tearDown(() {
    orderDetailBloc.close();
  });

  group('OrderDetailRequested', () {
    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits [OrderDetailLoading, OrderDetailLoaded] when fetch succeeds',
      build: () {
        when(() => mockGetOrderDetailUseCase(1)).thenAnswer((_) async => Right(pendingOrder));
        return orderDetailBloc;
      },
      act: (bloc) => bloc.add(const OrderDetailRequested(1)),
      expect: () => [
        const OrderDetailLoading(),
        OrderDetailLoaded(pendingOrder),
      ],
    );
  });

  group('OrderCancelRequested', () {
    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits isCancelling true then updated order on successful cancel',
      build: () {
        when(() => mockCancelOrderUseCase(1)).thenAnswer((_) async => Right(cancelledOrder));
        return orderDetailBloc;
      },
      seed: () => OrderDetailLoaded(pendingOrder),
      act: (bloc) => bloc.add(const OrderCancelRequested()),
      expect: () => [
        OrderDetailLoaded(pendingOrder, isCancelling: true),
        OrderDetailLoaded(cancelledOrder),
      ],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits cancelErrorMessage and keeps original order when cancel fails',
      build: () {
        when(() => mockCancelOrderUseCase(1)).thenAnswer(
              (_) async => const Left(ServerFailure('Cannot cancel a finished order')),
        );
        return orderDetailBloc;
      },
      seed: () => OrderDetailLoaded(pendingOrder),
      act: (bloc) => bloc.add(const OrderCancelRequested()),
      expect: () => [
        OrderDetailLoaded(pendingOrder, isCancelling: true),
        OrderDetailLoaded(pendingOrder, cancelErrorMessage: 'Cannot cancel a finished order'),
      ],
    );
  });
}