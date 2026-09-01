import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_wallet_usecase.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletUseCase getWalletUseCase;

  WalletBloc({required this.getWalletUseCase}) : super(const WalletLoading()) {
    on<WalletBalanceRequested>(_onBalanceRequested);
    on<WalletBalanceChecked>(_onBalanceChecked);
  }

  Future<void> _onBalanceRequested(
      WalletBalanceRequested event,
      Emitter<WalletState> emit,
      ) async {
    emit(const WalletLoading());
    final result = await getWalletUseCase();
    result.fold(
          (failure) => emit(WalletError(failure.message)),
          (data) => emit(WalletLoaded(balance: data.balance, transactions: data.transactions)),
    );
  }

  void _onBalanceChecked(WalletBalanceChecked event, Emitter<WalletState> emit) {
    final currentState = state;

    if (currentState is WalletLoaded) {
      if (currentState.balance < event.requiredAmount) {
        emit(WalletInsufficientBalance(
          balance: currentState.balance,
          requiredAmount: event.requiredAmount,
          transactions: currentState.transactions,
        ));
      }
      // Kalau saldo cukup, state tetap WalletLoaded (tidak perlu emit ulang).
      return;
    }

    if (currentState is WalletInsufficientBalance) {
      if (currentState.balance >= event.requiredAmount) {
        emit(WalletLoaded(balance: currentState.balance, transactions: currentState.transactions));
      } else if (currentState.requiredAmount != event.requiredAmount) {
        emit(WalletInsufficientBalance(
          balance: currentState.balance,
          requiredAmount: event.requiredAmount,
          transactions: currentState.transactions,
        ));
      }
      return;
    }

    // WalletLoading / WalletError: belum ada data saldo untuk dicek, abaikan.
  }
}