import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/catalog/domain/entities/product_entity.dart';
import 'package:cafeapp/features/catalog/domain/entities/product_list_result.dart';
import 'package:cafeapp/features/catalog/domain/usecases/get_products_usecase.dart';
import 'package:cafeapp/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:cafeapp/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:cafeapp/features/catalog/presentation/bloc/catalog_state.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

void main() {
  late CatalogBloc catalogBloc;
  late MockGetProductsUseCase mockGetProductsUseCase;

  const productA = ProductEntity(
    id: 1,
    cafeId: 5,
    category: 'coffee',
    name: 'Cappuccino',
    basePrice: 25000,
    serviceTimeMinutes: 5,
    isAvailable: true,
  );

  const productB = ProductEntity(
    id: 2,
    cafeId: 5,
    category: 'snack',
    name: 'Croissant',
    basePrice: 18000,
    serviceTimeMinutes: 2,
    isAvailable: true,
  );

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    catalogBloc = CatalogBloc(getProductsUseCase: mockGetProductsUseCase);
  });

  tearDown(() {
    catalogBloc.close();
  });

  test('initial state is CatalogLoading', () {
    expect(catalogBloc.state, const CatalogLoading());
  });

  group('CatalogRequested', () {
    blocTest<CatalogBloc, CatalogState>(
      'emits [CatalogLoading, CatalogLoaded] with products grouped by category when fetch succeeds',
      build: () {
        when(() => mockGetProductsUseCase(cafeId: 5)).thenAnswer(
              (_) async => const Right(ProductListResult(
            items: [productA, productB],
            currentPage: 1,
            lastPage: 1,
            total: 2,
          )),
        );
        return catalogBloc;
      },
      act: (bloc) => bloc.add(const CatalogRequested(5)),
      expect: () => [
        const CatalogLoading(),
        const CatalogLoaded({
          'coffee': [productA],
          'snack': [productB],
        }),
      ],
      verify: (_) {
        verify(() => mockGetProductsUseCase(cafeId: 5)).called(1);
      },
    );

    blocTest<CatalogBloc, CatalogState>(
      'emits [CatalogLoading, CatalogError] when fetch fails',
      build: () {
        when(() => mockGetProductsUseCase(cafeId: 5)).thenAnswer(
              (_) async => const Left(ServerFailure('Tidak dapat terhubung ke server.')),
        );
        return catalogBloc;
      },
      act: (bloc) => bloc.add(const CatalogRequested(5)),
      expect: () => [
        const CatalogLoading(),
        const CatalogError('Tidak dapat terhubung ke server.'),
      ],
    );
  });
}