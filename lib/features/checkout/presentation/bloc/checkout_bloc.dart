import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
// import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../../../wallet/presentation/bloc/wallet_event.dart';
import '../../../wallet/presentation/bloc/wallet_state.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/create_order_usecase.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CreateOrderUseCase createOrderUseCase;
  final CartBloc cartBloc;
  final WalletBloc walletBloc;

  CheckoutBloc({
    required this.createOrderUseCase,
    required this.cartBloc,
    required this.walletBloc,
  }) : super(const CheckoutInitial()) {
    on<CheckoutSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(CheckoutSubmitted event, Emitter<CheckoutState> emit) async {
    emit(const CheckoutLoading());

    final cartState = cartBloc.state;

    if (cartState.items.isEmpty || cartState.cafeId == null) {
      emit(const CheckoutFailure('Keranjang kosong, tidak ada yang bisa di-checkout.'));
      return;
    }

    final requiredAmount = cartState.totalPreview;
    final currentWalletState = walletBloc.state;

    int? currentBalance;
    if (currentWalletState is WalletLoaded) {
      currentBalance = currentWalletState.balance;
    } else if (currentWalletState is WalletInsufficientBalance) {
      currentBalance = currentWalletState.balance;
    }

    if (currentBalance == null) {
      emit(const CheckoutFailure('Data saldo belum siap, coba lagi sebentar.'));
      return;
    }

    if (currentBalance < requiredAmount) {
      walletBloc.add(WalletBalanceChecked(requiredAmount));
      emit(const CheckoutFailure(
        'Saldo wallet tidak mencukupi untuk order ini.',
        isInsufficientBalance: true,
      ));
      return;
    }

    final result = await createOrderUseCase(
      cafeId: cartState.cafeId!,
      cartItems: cartState.items,
      notes: event.notes,
    );

    result.fold(
          (failure) {
        final isInsufficientBalance = failure.runtimeType.toString() == 'InsufficientBalanceFailure';
        emit(CheckoutFailure(
          isInsufficientBalance ? 'Saldo wallet tidak mencukupi untuk order ini.' : failure.message,
          isInsufficientBalance: isInsufficientBalance,
        ));
      },
          (OrderEntity order) {
        emit(CheckoutSuccess(order));
        cartBloc.add(const CartCleared());
        walletBloc.add(const WalletBalanceRequested());
      },
    );
  }
}