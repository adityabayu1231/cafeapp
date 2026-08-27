import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cafeapp/core/theme/app_colors.dart';
import 'package:cafeapp/features/catalog/domain/entities/product_entity.dart';
import 'package:cafeapp/features/catalog/domain/entities/product_option_entity.dart';
import 'package:cafeapp/features/catalog/presentation/widgets/product_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  const product = ProductEntity(
    id: 1,
    cafeId: 5,
    category: 'coffee',
    name: 'Cappuccino',
    description: 'Espresso dengan susu yang dikukus',
    basePrice: 25000,
    serviceTimeMinutes: 5,
    isAvailable: true,
  );

  const unavailableProduct = ProductEntity(
    id: 2,
    cafeId: 5,
    category: 'coffee',
    name: 'Matcha Latte',
    basePrice: 28000,
    serviceTimeMinutes: 5,
    isAvailable: false,
  );

  const sizeOption = ProductOptionEntity(
    id: 1,
    productId: 1,
    optionType: 'size',
    optionValue: 'Large',
    extraPrice: 5000,
    isDefault: false,
  );

  const milkOption = ProductOptionEntity(
    id: 2,
    productId: 1,
    optionType: 'milk',
    optionValue: 'Oat milk',
    extraPrice: 8000,
    isDefault: false,
  );

  testWidgets('displays product name and formatted base price with no options selected', (tester) async {
    await tester.pumpWidget(wrap(const ProductCard(product: product)));

    expect(find.text('Cappuccino'), findsOneWidget);
    expect(find.text('Rp25.000'), findsOneWidget);
  });

  testWidgets('displays description when present', (tester) async {
    await tester.pumpWidget(wrap(const ProductCard(product: product)));

    expect(find.text('Espresso dengan susu yang dikukus'), findsOneWidget);
  });

  testWidgets('adds extra_price of selected options to displayed price', (tester) async {
    await tester.pumpWidget(wrap(const ProductCard(
      product: product,
      selectedOptions: [sizeOption, milkOption],
    )));

    // 25000 + 5000 + 8000 = 38000
    expect(find.text('Rp38.000'), findsOneWidget);
  });

  testWidgets('shows "Tidak tersedia" badge when product is unavailable', (tester) async {
    await tester.pumpWidget(wrap(const ProductCard(product: unavailableProduct)));

    expect(find.text('Tidak tersedia'), findsOneWidget);
    final badge = tester.widget<Text>(find.text('Tidak tersedia'));
    expect(badge.style?.color, AppColors.error);
  });

  testWidgets('does not show unavailable badge when product is available', (tester) async {
    await tester.pumpWidget(wrap(const ProductCard(product: product)));

    expect(find.text('Tidak tersedia'), findsNothing);
  });

  testWidgets('calls onTap when card is tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(ProductCard(
      product: product,
      onTap: () => tapped = true,
    )));

    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });
}