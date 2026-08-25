import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/cafe/domain/entities/cafe_detail_entity.dart';
import 'package:cafeapp/features/cafe/domain/entities/cafe_entity.dart';
import 'package:cafeapp/features/cafe/domain/usecases/get_cafe_detail_usecase.dart';
import 'package:cafeapp/features/cafe/presentation/bloc/cafe_detail_bloc.dart';
import 'package:cafeapp/features/cafe/presentation/bloc/cafe_detail_event.dart';
import 'package:cafeapp/features/cafe/presentation/bloc/cafe_detail_state.dart';

class MockGetCafeDetailUseCase extends Mock implements GetCafeDetailUseCase {}

void main() {
  late CafeDetailBloc cafeDetailBloc;
  late MockGetCafeDetailUseCase mockGetCafeDetailUseCase;

  const cafe = CafeEntity(
    id: 1,
    name: 'Awake Coffee - Sudirman',
    city: 'Jakarta',
    address: 'Jl. Sudirman No. 1',
    isActive: true,
    openStatus: 'Buka',
  );

  const detail = CafeDetailEntity(cafe: cafe, photos: [], operatingHours: []);

  setUp(() {
    mockGetCafeDetailUseCase = MockGetCafeDetailUseCase();
    cafeDetailBloc = CafeDetailBloc(getCafeDetailUseCase: mockGetCafeDetailUseCase);
  });

  tearDown(() {
    cafeDetailBloc.close();
  });

  test('initial state is CafeDetailLoading', () {
    expect(cafeDetailBloc.state, const CafeDetailLoading());
  });

  group('CafeDetailRequested', () {
    blocTest<CafeDetailBloc, CafeDetailState>(
      'emits [CafeDetailLoading, CafeDetailLoaded] when fetch succeeds',
      build: () {
        when(() => mockGetCafeDetailUseCase(1)).thenAnswer((_) async => const Right(detail));
        return cafeDetailBloc;
      },
      act: (bloc) => bloc.add(const CafeDetailRequested(1)),
      expect: () => [const CafeDetailLoading(), const CafeDetailLoaded(detail)],
    );

    blocTest<CafeDetailBloc, CafeDetailState>(
      'emits [CafeDetailLoading, CafeDetailError] when cafe not found',
      build: () {
        when(() => mockGetCafeDetailUseCase(999))
            .thenAnswer((_) async => const Left(ServerFailure('Cafe tidak ditemukan.')));
        return cafeDetailBloc;
      },
      act: (bloc) => bloc.add(const CafeDetailRequested(999)),
      expect: () => [const CafeDetailLoading(), const CafeDetailError('Cafe tidak ditemukan.')],
    );
  });
}