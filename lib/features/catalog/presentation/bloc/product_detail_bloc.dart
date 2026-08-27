import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';
import 'product_detail_event.dart';
import 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final GetProductDetailUseCase getProductDetailUseCase;

  ProductDetailBloc({required this.getProductDetailUseCase}) : super(const ProductDetailLoading()) {
    on<ProductDetailRequested>(_onProductDetailRequested);
  }

  Future<void> _onProductDetailRequested(
      ProductDetailRequested event,
      Emitter<ProductDetailState> emit,
      ) async {
    emit(const ProductDetailLoading());
    final result = await getProductDetailUseCase(event.productId);
    result.fold(
          (failure) => emit(ProductDetailError(failure.message)),
          (detail) => emit(ProductDetailLoaded(detail)),
    );
  }
}