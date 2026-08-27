import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/catalog/domain/entities/product_detail_entity.dart';
import 'package:cafeapp/features/catalog/domain/entities/product_entity.dart';
import 'package:cafeapp/features/catalog/domain/entities/product_option_entity.dart';
import 'package:cafeapp/features/catalog/domain/usecases/get_product_detail_usecase.dart';
import 'package:cafeapp/features/catalog/presentation/bloc/product_detail_bloc.dart';
import 'package:cafeapp/features/catalog/presentation/bloc/product_detail_event.dart';
import 'package:cafeapp/features/catalog/presentation/bloc/product_detail_state.dart';

class MockGetProductDetailUseCase extends Mock implements GetProductDetailUseCase {}

void main() {
  late ProductDetailBloc productDetailBloc;
  late MockGetProductDetailUseCase mockGetProductDetailUseCase;

  const product = ProductEntity(
    id: 1,
    cafeId: 5,
    category: 'coffee',
    name: 'Cappuccino',
    basePrice: 25000,
    serviceTimeMinutes: 5,
    isAvailable: true,
  );

  const option = ProductOptionEntity(
    id: 1,
    productId: 1,
    optionType: 'size',
    optionValue: 'Regular',
    extraPrice: 0,
    isDefault: true,
  );

  const detail = ProductDetailEntity(product: product, options: [option]);

  setUp(() {
    mockGetProductDetailUseCase = MockGetProductDetailUseCase();
    productDetailBloc = ProductDetailBloc(getProductDetailUseCase: mockGetProductDetailUseCase);
  });

  tearDown(() {
    productDetailBloc.close();
  });

  test('initial state is ProductDetailLoading', () {
    expect(productDetailBloc.state, const ProductDetailLoading());
  });

  group('ProductDetailRequested', () {
    blocTest<ProductDetailBloc, ProductDetailState>(
      'emits [ProductDetailLoading, ProductDetailLoaded] when fetch succeeds',
      build: () {
        when(() => mockGetProductDetailUseCase(1)).thenAnswer((_) async => const Right(detail));
        return productDetailBloc;
      },
      act: (bloc) => bloc.add(const ProductDetailRequested(1)),
      expect: () => [
        const ProductDetailLoading(),
        const ProductDetailLoaded(detail),
      ],
    );

    blocTest<ProductDetailBloc, ProductDetailState>(
      'emits [ProductDetailLoading, ProductDetailError] when fetch fails',
      build: () {
        when(() => mockGetProductDetailUseCase(1)).thenAnswer(
              (_) async => const Left(ServerFailure('Produk tidak ditemukan.')),
        );
        return productDetailBloc;
      },
      act: (bloc) => bloc.add(const ProductDetailRequested(1)),
      expect: () => [
        const ProductDetailLoading(),
        const ProductDetailError('Produk tidak ditemukan.'),
      ],
    );
  });
}