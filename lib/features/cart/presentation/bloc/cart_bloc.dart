import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_item_to_cart_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_item_from_cart_usecase.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddItemToCartUseCase addItemToCartUseCase;
  final RemoveItemFromCartUseCase removeItemFromCartUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.addItemToCartUseCase,
    required this.removeItemFromCartUseCase,
    required this.clearCartUseCase,
  }) : super(const CartState()) {
    on<CartStarted>(_onCartStarted);
    on<ItemAddedToCart>(_onItemAdded);
    on<ItemRemovedFromCart>(_onItemRemoved);
    on<CartCleared>(_onCartCleared);
  }

  Future<void> _onCartStarted(CartStarted event, Emitter<CartState> emit) async {
    final result = await getCartUseCase();
    result.fold(
          (failure) => emit(state.copyWith(isLoading: false)),
          (data) => emit(CartState(
        items: data.items,
        cafeId: data.cafeId,
        cafeName: data.cafeName,
        isLoading: false,
      )),
    );
  }

  Future<void> _onItemAdded(ItemAddedToCart event, Emitter<CartState> emit) async {
    final result = await addItemToCartUseCase(
      currentItems: state.items,
      currentCafeId: state.cafeId,
      newCafeId: event.cafeId,
      newCafeName: event.cafeName,
      newItem: event.item,
    );

    result.fold(
          (failure) => null,
          (data) => emit(CartState(
        items: data.items,
        cafeId: data.cafeId,
        cafeName: data.cafeName,
        isLoading: false,
      )),
    );
  }

  Future<void> _onItemRemoved(ItemRemovedFromCart event, Emitter<CartState> emit) async {
    final result = await removeItemFromCartUseCase(
      currentItems: state.items,
      cafeId: state.cafeId,
      cafeName: state.cafeName,
      mergeKey: event.mergeKey,
    );

    result.fold(
          (failure) => null,
          (data) => emit(CartState(
        items: data.items,
        cafeId: data.cafeId,
        cafeName: data.cafeName,
        isLoading: false,
      )),
    );
  }

  Future<void> _onCartCleared(CartCleared event, Emitter<CartState> emit) async {
    final result = await clearCartUseCase();
    result.fold(
          (failure) => null,
          (_) => emit(const CartState(isLoading: false)),
    );
  }
}