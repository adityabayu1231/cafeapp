import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/features/cart/domain/entities/cart_item_entity.dart';
import 'package:cafeapp/features/cart/domain/entities/cart_item_option_entity.dart';
import 'package:cafeapp/features/cart/domain/usecases/add_item_to_cart_usecase.dart';
import 'package:cafeapp/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:cafeapp/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:cafeapp/features/cart/domain/usecases/remove_item_from_cart_usecase.dart';
import 'package:cafeapp/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:cafeapp/features/cart/presentation/bloc/cart_event.dart';
import 'package:cafeapp/features/cart/presentation/bloc/cart_state.dart';

class MockGetCartUseCase extends Mock implements GetCartUseCase {}
class MockAddItemToCartUseCase extends Mock implements AddItemToCartUseCase {}
class MockRemoveItemFromCartUseCase extends Mock implements RemoveItemFromCartUseCase {}
class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const CartItemEntity(
      productId: 0,
      productName: '',
      basePrice: 0,
      quantity: 0,
      selectedOptions: [],
    ));
  });

  late CartBloc cartBloc;
  late MockGetCartUseCase mockGetCart;
  late MockAddItemToCartUseCase mockAddItem;
  late MockRemoveItemFromCartUseCase mockRemoveItem;
  late MockClearCartUseCase mockClearCart;

  const largeOption = CartItemOptionEntity(
    optionId: 3,
    optionType: 'size',
    optionValue: 'Large',
    extraPrice: 5000,
  );

  const sweetOption = CartItemOptionEntity(
    optionId: 7,
    optionType: 'sweetness',
    optionValue: '50%',
    extraPrice: 0,
  );

  const cappuccino = CartItemEntity(
    productId: 12,
    productName: 'Cappuccino',
    basePrice: 20000,
    quantity: 1,
    selectedOptions: [largeOption, sweetOption],
  );

  setUp(() {
    mockGetCart = MockGetCartUseCase();
    mockAddItem = MockAddItemToCartUseCase();
    mockRemoveItem = MockRemoveItemFromCartUseCase();
    mockClearCart = MockClearCartUseCase();
    cartBloc = CartBloc(
      getCartUseCase: mockGetCart,
      addItemToCartUseCase: mockAddItem,
      removeItemFromCartUseCase: mockRemoveItem,
      clearCartUseCase: mockClearCart,
    );
  });

  tearDown(() {
    cartBloc.close();
  });

  test('initial state has empty items and isLoading true', () {
    expect(cartBloc.state, const CartState());
  });

  group('CartStarted', () {
    blocTest<CartBloc, CartState>(
      'restores persisted cart items on app start',
      build: () {
        when(() => mockGetCart()).thenAnswer(
              (_) async => const Right((items: [cappuccino], cafeId: 5, cafeName: 'Kopi Kita')),
        );
        return cartBloc;
      },
      act: (bloc) => bloc.add(const CartStarted()),
      expect: () => [
        const CartState(items: [cappuccino], cafeId: 5, cafeName: 'Kopi Kita', isLoading: false),
      ],
    );
  });

  group('ItemAddedToCart', () {
    blocTest<CartBloc, CartState>(
      'merges identical product with same options into one entry (quantity bertambah, bukan entry baru)',
      build: () {
        when(() => mockAddItem(
          currentItems: any(named: 'currentItems'),
          currentCafeId: any(named: 'currentCafeId'),
          newCafeId: any(named: 'newCafeId'),
          newCafeName: any(named: 'newCafeName'),
          newItem: any(named: 'newItem'),
        )).thenAnswer(
              (_) async => Right((
          items: [cappuccino.copyWith(quantity: 2)],
          cafeId: 5,
          cafeName: 'Kopi Kita',
          )),
        );
        return cartBloc;
      },
      seed: () => const CartState(items: [cappuccino], cafeId: 5, cafeName: 'Kopi Kita', isLoading: false),
      act: (bloc) => bloc.add(const ItemAddedToCart(
        cafeId: 5,
        cafeName: 'Kopi Kita',
        item: cappuccino,
      )),
      expect: () => [
        CartState(
          items: [cappuccino.copyWith(quantity: 2)],
          cafeId: 5,
          cafeName: 'Kopi Kita',
          isLoading: false,
        ),
      ],
      verify: (_) {
        verify(() => mockAddItem(
          currentItems: [cappuccino],
          currentCafeId: 5,
          newCafeId: 5,
          newCafeName: 'Kopi Kita',
          newItem: cappuccino,
        )).called(1);
      },
    );
  });

  group('ItemRemovedFromCart', () {
    blocTest<CartBloc, CartState>(
      'removes item and updates state',
      build: () {
        when(() => mockRemoveItem(
          currentItems: any(named: 'currentItems'),
          cafeId: any(named: 'cafeId'),
          cafeName: any(named: 'cafeName'),
          mergeKey: any(named: 'mergeKey'),
        )).thenAnswer((_) async => const Right((items: <CartItemEntity>[], cafeId: null, cafeName: null)));
        return cartBloc;
      },
      seed: () => const CartState(items: [cappuccino], cafeId: 5, cafeName: 'Kopi Kita', isLoading: false),
      act: (bloc) => bloc.add(ItemRemovedFromCart(cappuccino.mergeKey)),
      expect: () => [const CartState(items: [], isLoading: false)],
    );
  });

  group('CartCleared', () {
    blocTest<CartBloc, CartState>(
      'clears all items',
      build: () {
        when(() => mockClearCart()).thenAnswer((_) async => const Right(null));
        return cartBloc;
      },
      seed: () => const CartState(items: [cappuccino], cafeId: 5, cafeName: 'Kopi Kita', isLoading: false),
      act: (bloc) => bloc.add(const CartCleared()),
      expect: () => [const CartState(items: [], isLoading: false)],
    );
  });
}