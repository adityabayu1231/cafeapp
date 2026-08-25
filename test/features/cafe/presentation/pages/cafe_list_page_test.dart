import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/features/cafe/domain/entities/cafe_entity.dart';
import 'package:cafeapp/features/cafe/presentation/bloc/cafe_list_bloc.dart';
import 'package:cafeapp/features/cafe/presentation/bloc/cafe_list_event.dart';
import 'package:cafeapp/features/cafe/presentation/bloc/cafe_list_state.dart';
import 'package:cafeapp/features/cafe/presentation/widgets/cafe_card.dart';
import 'package:cafeapp/features/cafe/presentation/widgets/cafe_card_skeleton.dart';
import 'package:cafeapp/features/cafe/domain/usecases/get_cafes_usecase.dart';

class MockGetCafesUseCase extends Mock implements GetCafesUseCase {}
class MockCafeListBloc extends MockBloc<CafeListEvent, CafeListState> implements CafeListBloc {}

void main() {
  late MockCafeListBloc mockBloc;

  const cafe = CafeEntity(
    id: 1,
    name: 'Awake Coffee - Sudirman',
    city: 'Jakarta',
    address: 'Jl. Sudirman No. 1',
    isActive: true,
    openStatus: 'Buka',
  );

  setUp(() {
    mockBloc = MockCafeListBloc();
  });

  Widget wrap() {
    return MaterialApp(
      home: BlocProvider<CafeListBloc>.value(
        value: mockBloc,
        child: Scaffold(
          body: BlocBuilder<CafeListBloc, CafeListState>(
            builder: (context, state) {
              if (state is CafeListLoading) {
                return ListView.builder(
                  itemCount: 5,
                  itemBuilder: (_, __) => const CafeCardSkeleton(),
                );
              }
              if (state is CafeListLoaded) {
                if (state.cafes.isEmpty) {
                  return const Center(child: Text('Belum ada cafe ditemukan.'));
                }
                return ListView.builder(
                  itemCount: state.cafes.length,
                  itemBuilder: (_, i) => CafeCard(cafe: state.cafes[i]),
                );
              }
              if (state is CafeListError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  testWidgets('shows 5 skeleton cards when loading', (tester) async {
    when(() => mockBloc.state).thenReturn(const CafeListLoading());

    await tester.pumpWidget(wrap());

    expect(find.byType(CafeCardSkeleton), findsNWidgets(5));
  });

  testWidgets('shows cafe cards when loaded with data', (tester) async {
    when(() => mockBloc.state).thenReturn(const CafeListLoaded([cafe]));

    await tester.pumpWidget(wrap());

    expect(find.byType(CafeCard), findsOneWidget);
    expect(find.text('Awake Coffee - Sudirman'), findsOneWidget);
  });

  testWidgets('shows empty state message when loaded with no data', (tester) async {
    when(() => mockBloc.state).thenReturn(const CafeListLoaded([]));

    await tester.pumpWidget(wrap());

    expect(find.text('Belum ada cafe ditemukan.'), findsOneWidget);
  });

  testWidgets('shows error message when fetch fails', (tester) async {
    when(() => mockBloc.state).thenReturn(const CafeListError('Tidak dapat terhubung ke server.'));

    await tester.pumpWidget(wrap());

    expect(find.text('Tidak dapat terhubung ke server.'), findsOneWidget);
  });
}