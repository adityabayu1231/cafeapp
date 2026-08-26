import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final GetProductsUseCase getProductsUseCase;

  CatalogBloc({required this.getProductsUseCase}) : super(const CatalogLoading()) {
    on<CatalogRequested>(_onCatalogRequested);
  }

  Future<void> _onCatalogRequested(CatalogRequested event, Emitter<CatalogState> emit) async {
    emit(const CatalogLoading());
    final result = await getProductsUseCase(cafeId: event.cafeId);
    result.fold(
          (failure) => emit(CatalogError(failure.message)),
          (data) => emit(CatalogLoaded(_groupByCategory(data.items))),
    );
  }

  Map<String, List<ProductEntity>> _groupByCategory(List<ProductEntity> products) {
    final Map<String, List<ProductEntity>> grouped = {};
    for (final product in products) {
      grouped.putIfAbsent(product.category, () => []).add(product);
    }
    return grouped;
  }
}