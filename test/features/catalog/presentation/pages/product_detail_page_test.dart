import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/features/catalog/domain/entities/product_detail_entity.dart';
import 'package:cafeapp/features/catalog/domain/entities/product_entity.dart';
import 'package:cafeapp/features/catalog/domain/entities/product_option_entity.dart';
import 'package:cafeapp/features/catalog/domain/usecases/get_product_detail_usecase.dart';
import 'package:cafeapp/features/catalog/injection_container.dart' as di;
import 'package:cafeapp/features/catalog/presentation/bloc/product_detail_bloc.dart';
import 'package:cafeapp/features/catalog/presentation/pages/product_detail_page.dart';

class MockGetProductDetailUseCase extends Mock implements GetProductDetailUseCase {}

void main() {
  late MockGetProductDetailUseCase mockUseCase;

  const product = ProductEntity(
    id: 1,
    cafeId: 5,
    category: 'coffee',
    name: 'Cappuccino',
    basePrice: 25000,
    serviceTimeMinutes: 5,
    isAvailable: true,
  );

  const regularOption = ProductOptionEntity(
    id: 1,
    productId: 1,
    optionType: 'size',
    optionValue: 'Regular',
    extraPrice: 0,
    isDefault: true,
  );

  const largeOption = ProductOptionEntity(
    id: 2,
    productId: 1,
    optionType: 'size',
    optionValue: 'Large',
    extraPrice: 5000,
    isDefault: false,
  );

  const detail = ProductDetailEntity(product: product, options: [regularOption, largeOption]);

  setUp(() {
    mockUseCase = MockGetProductDetailUseCase();
    if (di.sl.isRegistered<ProductDetailBloc>()) {
      di.sl.unregister<ProductDetailBloc>();
    }
    di.sl.registerFactory(() => ProductDetailBloc(getProductDetailUseCase: mockUseCase));
  });

  testWidgets('selecting an alternate option updates the displayed price', (tester) async {
    when(() => mockUseCase(1)).thenAnswer((_) async => const Right(detail));

    await tester.pumpWidget(const MaterialApp(home: ProductDetailPage(productId: 1)));
    await tester.pumpAndSettle();

    expect(find.text('Rp25.000'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Large (+Rp5000)'));
    await tester.pumpAndSettle();

    expect(find.text('Rp30.000'), findsOneWidget);
  });
}