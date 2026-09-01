import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/wallet/domain/entities/wallet_result.dart';
import 'package:cafeapp/features/wallet/domain/entities/wallet_transaction_entity.dart';
import 'package:cafeapp/features/wallet/domain/usecases/get_wallet_usecase.dart';
import 'package:cafeapp/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:cafeapp/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:cafeapp/features/wallet/presentation/bloc/wallet_state.dart';

class MockGetWalletUseCase extends Mock implements GetWalletUseCase {}

void main() {
  late WalletBloc walletBloc;
  late MockGetWalletUseCase mockGetWalletUseCase;

  final transaction = WalletTransactionEntity(
    id: 1,
    type: 'payment',
    amount: 20000,
    referenceType: 'order',
    referenceId: 99,
    balanceAfter: 30000,
    createdAt: DateTime(2026, 8, 31),
  );

  setUp(() {
    mockGetWalletUseCase = MockGetWalletUseCase();
    walletBloc = WalletBloc(getWalletUseCase: mockGetWalletUseCase);
  });

  tearDown(() {
    walletBloc.close();
  });

  test('initial state is WalletLoading', () {
    expect(walletBloc.state, const WalletLoading());
  });

  group('WalletBalanceRequested', () {
    blocTest<WalletBloc, WalletState>(
      'emits [WalletLoading, WalletLoaded] when fetch succeeds',
      build: () {
        when(() => mockGetWalletUseCase()).thenAnswer(
              (_) async => Right(WalletResult(
            balance: 50000,
            transactions: [transaction],
            currentPage: 1,
            lastPage: 1,
            total: 1,
          )),
        );
        return walletBloc;
      },
      act: (bloc) => bloc.add(const WalletBalanceRequested()),
      expect: () => [
        const WalletLoading(),
        WalletLoaded(balance: 50000, transactions: [transaction]),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'emits [WalletLoading, WalletError] when fetch fails',
      build: () {
        when(() => mockGetWalletUseCase()).thenAnswer(
              (_) async => const Left(ServerFailure('Tidak dapat terhubung ke server.')),
        );
        return walletBloc;
      },
      act: (bloc) => bloc.add(const WalletBalanceRequested()),
      expect: () => [
        const WalletLoading(),
        const WalletError('Tidak dapat terhubung ke server.'),
      ],
    );
  });

  group('WalletBalanceChecked', () {
    blocTest<WalletBloc, WalletState>(
      'emits WalletInsufficientBalance when balance is less than required amount',
      build: () => walletBloc,
      seed: () => WalletLoaded(balance: 20000, transactions: [transaction]),
      act: (bloc) => bloc.add(const WalletBalanceChecked(35000)),
      expect: () => [
        WalletInsufficientBalance(balance: 20000, requiredAmount: 35000, transactions: [transaction]),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'stays WalletLoaded (no new emission) when balance is sufficient',
      build: () => walletBloc,
      seed: () => WalletLoaded(balance: 50000, transactions: [transaction]),
      act: (bloc) => bloc.add(const WalletBalanceChecked(35000)),
      expect: () => [],
    );

    blocTest<WalletBloc, WalletState>(
      'recovers to WalletLoaded when balance becomes sufficient for a lower required amount',
      build: () => walletBloc,
      seed: () => WalletInsufficientBalance(
        balance: 20000,
        requiredAmount: 35000,
        transactions: [transaction],
      ),
      act: (bloc) => bloc.add(const WalletBalanceChecked(10000)),
      expect: () => [
        WalletLoaded(balance: 20000, transactions: [transaction]),
      ],
    );
  });
}