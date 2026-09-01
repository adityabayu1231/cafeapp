import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cafeapp/features/cart/domain/entities/cart_item_entity.dart';
import 'package:cafeapp/features/cart/domain/entities/cart_item_option_entity.dart';
import 'package:cafeapp/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:cafeapp/features/cart/presentation/bloc/cart_event.dart';
import 'package:cafeapp/features/cart/presentation/bloc/cart_state.dart';
import 'package:cafeapp/features/cart/presentation/pages/cart_page.dart';

class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

class FakeCartEvent extends Fake implements CartEvent {}

void main() {
  late MockCartBloc mockCartBloc;

  const option = CartItemOptionEntity(
    optionId: 3,
    optionType: 'size',
    optionValue: 'Large',
    extraPrice: 5000,
  );

  const item = CartItemEntity(
    productId: 12,
    productName: 'Cappuccino',
    basePrice: 20000,
    quantity: 2,
    selectedOptions: [option],
  );

  setUpAll(() {
    registerFallbackValue(FakeCartEvent());
  });

  setUp(() {
    mockCartBloc = MockCartBloc();
  });

  Widget makeTestable() {
    return MaterialApp(
      home: BlocProvider<CartBloc>.value(
        value: mockCartBloc,
        child: const CartPage(),
      ),
    );
  }

  testWidgets('shows skeleton loading when state isLoading', (tester) async {
    when(() => mockCartBloc.state).thenReturn(const CartState(isLoading: true));

    await tester.pumpWidget(makeTestable());

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Keranjang kamu masih kosong.\nYuk pilih menu favoritmu!'), findsNothing);
  });

  testWidgets('shows empty state when cart has no items', (tester) async {
    when(() => mockCartBloc.state).thenReturn(const CartState(isLoading: false));

    await tester.pumpWidget(makeTestable());

    expect(find.text('Keranjang kamu masih kosong.\nYuk pilih menu favoritmu!'), findsOneWidget);
  });

  testWidgets('shows cart items with total preview when loaded', (tester) async {
    when(() => mockCartBloc.state).thenReturn(const CartState(
      items: [item],
      cafeId: 5,
      cafeName: 'Kopi Kita',
      isLoading: false,
    ));

    await tester.pumpWidget(makeTestable());

    expect(find.text('Cappuccino'), findsOneWidget);
    expect(find.text('Kopi Kita'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);
    // unitPrice = 20000 + 5000 = 25000, subtotal = 25000 x 2 = 50000
    expect(find.text('Rp50.000'), findsNWidgets(2));
  });

  testWidgets('tapping remove icon dispatches ItemRemovedFromCart', (tester) async {
    when(() => mockCartBloc.state).thenReturn(const CartState(
      items: [item],
      cafeId: 5,
      cafeName: 'Kopi Kita',
      isLoading: false,
    ));

    await tester.pumpWidget(makeTestable());
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    verify(() => mockCartBloc.add(ItemRemovedFromCart(item.mergeKey))).called(1);
  });
}