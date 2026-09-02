import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/cart/domain/entities/cart_item_entity.dart';
import 'package:cafeapp/features/cart/domain/entities/cart_item_option_entity.dart';
import 'package:cafeapp/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:cafeapp/features/cart/presentation/bloc/cart_event.dart';
import 'package:cafeapp/features/cart/presentation/bloc/cart_state.dart';
import 'package:cafeapp/features/order/domain/entities/order_entity.dart';
import 'package:cafeapp/features/checkout/domain/usecases/create_order_usecase.dart';
import 'package:cafeapp/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:cafeapp/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:cafeapp/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:cafeapp/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:cafeapp/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:cafeapp/features/wallet/presentation/bloc/wallet_state.dart';

class MockCreateOrderUseCase extends Mock implements CreateOrderUseCase {}
class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}
class MockWalletBloc extends MockBloc<WalletEvent, WalletState> implements WalletBloc {}
class FakeCartEvent extends Fake implements CartEvent {}
class FakeWalletEvent extends Fake implements WalletEvent {}

void main() {
  late CheckoutBloc checkoutBloc;
  late MockCreateOrderUseCase mockCreateOrderUseCase;
  late MockCartBloc mockCartBloc;
  late MockWalletBloc mockWalletBloc;

  const option = CartItemOptionEntity(
    optionId: 3,
    optionType: 'size',
    optionValue: 'Large',
    extraPrice: 5000,
  );

  const cartItem = CartItemEntity(
    productId: 12,
    productName: 'Cappuccino',
    basePrice: 20000,
    quantity: 1,
    selectedOptions: [option],
  );

  final order = OrderEntity(
    id: 1,
    userId: 10,
    cafeId: 5,
    status: 'pending',
    totalAmount: 25000,
    createdAt: DateTime(2026, 8, 31),
    items: const [],
  );

  setUpAll(() {
    registerFallbackValue(FakeCartEvent());
    registerFallbackValue(FakeWalletEvent());
  });

  setUp(() {
    mockCreateOrderUseCase = MockCreateOrderUseCase();
    mockCartBloc = MockCartBloc();
    mockWalletBloc = MockWalletBloc();
    checkoutBloc = CheckoutBloc(
      createOrderUseCase: mockCreateOrderUseCase,
      cartBloc: mockCartBloc,
      walletBloc: mockWalletBloc,
    );
  });

  tearDown(() {
    checkoutBloc.close();
  });

  group('CheckoutSubmitted', () {
    blocTest<CheckoutBloc, CheckoutState>(
      'emits [CheckoutLoading, CheckoutFailure(isInsufficientBalance: true)] when wallet balance is less than cart total',
      build: () {
        when(() => mockCartBloc.state).thenReturn(const CartState(
          items: [cartItem],
          cafeId: 5,
          cafeName: 'Kopi Kita',
          isLoading: false,
        ));
        when(() => mockWalletBloc.state).thenReturn(const WalletLoaded(balance: 10000, transactions: []));
        return checkoutBloc;
      },
      act: (bloc) => bloc.add(const CheckoutSubmitted()),
      expect: () => [
        const CheckoutLoading(),
        const CheckoutFailure(
          'Saldo wallet tidak mencukupi untuk order ini.',
          isInsufficientBalance: true,
        ),
      ],
      verify: (_) {
        verify(() => mockWalletBloc.add(const WalletBalanceChecked(25000))).called(1);
        verifyNever(() => mockCreateOrderUseCase(
          cafeId: any(named: 'cafeId'),
          cartItems: any(named: 'cartItems'),
          notes: any(named: 'notes'),
        ));
      },
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'emits [CheckoutLoading, CheckoutSuccess] and clears cart when balance sufficient and API succeeds',
      build: () {
        when(() => mockCartBloc.state).thenReturn(const CartState(
          items: [cartItem],
          cafeId: 5,
          cafeName: 'Kopi Kita',
          isLoading: false,
        ));
        when(() => mockWalletBloc.state).thenReturn(const WalletLoaded(balance: 100000, transactions: []));
        when(() => mockCreateOrderUseCase(
          cafeId: any(named: 'cafeId'),
          cartItems: any(named: 'cartItems'),
          notes: any(named: 'notes'),
        )).thenAnswer((_) async => Right(order));
        return checkoutBloc;
      },
      act: (bloc) => bloc.add(const CheckoutSubmitted()),
      expect: () => [
        const CheckoutLoading(),
        CheckoutSuccess(order),
      ],
      verify: (_) {
        verify(() => mockCartBloc.add(const CartCleared())).called(1);
        verify(() => mockWalletBloc.add(const WalletBalanceRequested())).called(1);
      },
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'emits [CheckoutLoading, CheckoutFailure] with generic message when API returns a non-balance error',
      build: () {
        when(() => mockCartBloc.state).thenReturn(const CartState(
          items: [cartItem],
          cafeId: 5,
          cafeName: 'Kopi Kita',
          isLoading: false,
        ));
        when(() => mockWalletBloc.state).thenReturn(const WalletLoaded(balance: 100000, transactions: []));
        when(() => mockCreateOrderUseCase(
          cafeId: any(named: 'cafeId'),
          cartItems: any(named: 'cartItems'),
          notes: any(named: 'notes'),
        )).thenAnswer((_) async => const Left(ServerFailure('Produk tidak tersedia.')));
        return checkoutBloc;
      },
      act: (bloc) => bloc.add(const CheckoutSubmitted()),
      expect: () => [
        const CheckoutLoading(),
        const CheckoutFailure('Produk tidak tersedia.'),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'emits CheckoutFailure immediately when cart is empty, without calling API',
      build: () {
        when(() => mockCartBloc.state).thenReturn(const CartState(items: [], isLoading: false));
        return checkoutBloc;
      },
      act: (bloc) => bloc.add(const CheckoutSubmitted()),
      expect: () => [
        const CheckoutLoading(),
        const CheckoutFailure('Keranjang kosong, tidak ada yang bisa di-checkout.'),
      ],
      verify: (_) {
        verifyNever(() => mockCreateOrderUseCase(
          cafeId: any(named: 'cafeId'),
          cartItems: any(named: 'cartItems'),
          notes: any(named: 'notes'),
        ));
      },
    );
  });
}