import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/cafe/domain/entities/cafe_entity.dart';
import 'package:cafeapp/features/cafe/domain/entities/cafe_list_result.dart';
import 'package:cafeapp/features/cafe/domain/usecases/get_cafes_usecase.dart';
import 'package:cafeapp/features/cafe/presentation/bloc/cafe_list_bloc.dart';
import 'package:cafeapp/features/cafe/presentation/bloc/cafe_list_event.dart';
import 'package:cafeapp/features/cafe/presentation/bloc/cafe_list_state.dart';

class MockGetCafesUseCase extends Mock implements GetCafesUseCase {}

void main() {
  late CafeListBloc cafeListBloc;
  late MockGetCafesUseCase mockGetCafesUseCase;

  const cafeA = CafeEntity(
    id: 1,
    name: 'Awake Coffee - Sudirman',
    city: 'Jakarta',
    address: 'Jl. Sudirman No. 1',
    isActive: true,
    openStatus: 'Buka',
  );

  const cafeB = CafeEntity(
    id: 2,
    name: 'Awake Coffee - Malioboro',
    city: 'Yogyakarta',
    address: 'Jl. Malioboro No. 5',
    isActive: true,
    openStatus: 'Tutup',
  );

  const resultWithData = CafeListResult(
    items: [cafeA, cafeB],
    currentPage: 1,
    lastPage: 1,
    total: 2,
  );

  setUp(() {
    mockGetCafesUseCase = MockGetCafesUseCase();
    cafeListBloc = CafeListBloc(getCafesUseCase: mockGetCafesUseCase);
  });

  tearDown(() {
    cafeListBloc.close();
  });

  test('initial state is CafeListLoading', () {
    expect(cafeListBloc.state, const CafeListLoading());
  });

  group('CafeListRequested', () {
    blocTest<CafeListBloc, CafeListState>(
      'emits [CafeListLoading, CafeListLoaded] when fetch succeeds',
      build: () {
        when(() => mockGetCafesUseCase(city: null))
            .thenAnswer((_) async => const Right(resultWithData));
        return cafeListBloc;
      },
      act: (bloc) => bloc.add(const CafeListRequested()),
      expect: () => [
        const CafeListLoading(),
        const CafeListLoaded([cafeA, cafeB]),
      ],
    );

    blocTest<CafeListBloc, CafeListState>(
      'emits [CafeListLoading, CafeListError] when fetch fails',
      build: () {
        when(() => mockGetCafesUseCase(city: null)).thenAnswer(
              (_) async => const Left(ServerFailure('Tidak dapat terhubung ke server.')),
        );
        return cafeListBloc;
      },
      act: (bloc) => bloc.add(const CafeListRequested()),
      expect: () => [
        const CafeListLoading(),
        const CafeListError('Tidak dapat terhubung ke server.'),
      ],
    );

    blocTest<CafeListBloc, CafeListState>(
      'passes city filter to use case when provided',
      build: () {
        when(() => mockGetCafesUseCase(city: 'Jakarta')).thenAnswer(
              (_) async => const Right(CafeListResult(items: [cafeA], currentPage: 1, lastPage: 1, total: 1)),
        );
        return cafeListBloc;
      },
      act: (bloc) => bloc.add(const CafeListRequested(city: 'Jakarta')),
      expect: () => [
        const CafeListLoading(),
        const CafeListLoaded([cafeA]),
      ],
      verify: (_) {
        verify(() => mockGetCafesUseCase(city: 'Jakarta')).called(1);
      },
    );
  });

  group('CafeSearchChanged', () {
    blocTest<CafeListBloc, CafeListState>(
      'emits [CafeListLoading, CafeListLoaded] after debounce when search changes',
      build: () {
        when(() => mockGetCafesUseCase(city: 'Bandung')).thenAnswer(
              (_) async => const Right(CafeListResult(items: [], currentPage: 1, lastPage: 1, total: 0)),
        );
        return cafeListBloc;
      },
      act: (bloc) => bloc.add(const CafeSearchChanged('Bandung')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const CafeListLoading(),
        const CafeListLoaded([]),
      ],
    );

    blocTest<CafeListBloc, CafeListState>(
      'only processes the latest search when typed quickly (debounce + switchMap)',
      build: () {
        when(() => mockGetCafesUseCase(city: 'Ja')).thenAnswer(
              (_) async => const Right(CafeListResult(items: [cafeA], currentPage: 1, lastPage: 1, total: 1)),
        );
        when(() => mockGetCafesUseCase(city: 'Jakarta')).thenAnswer(
              (_) async => const Right(CafeListResult(items: [cafeA], currentPage: 1, lastPage: 1, total: 1)),
        );
        return cafeListBloc;
      },
      act: (bloc) {
        bloc.add(const CafeSearchChanged('Ja'));
        bloc.add(const CafeSearchChanged('Jakarta'));
      },
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const CafeListLoading(),
        const CafeListLoaded([cafeA]),
      ],
      verify: (_) {
        verifyNever(() => mockGetCafesUseCase(city: 'Ja'));
        verify(() => mockGetCafesUseCase(city: 'Jakarta')).called(1);
      },
    );
  });
}