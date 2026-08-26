import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

class CatalogLoaded extends CatalogState {
  final Map<String, List<ProductEntity>> productsByCategory;

  const CatalogLoaded(this.productsByCategory);

  @override
  List<Object?> get props => [productsByCategory];
}

class CatalogError extends CatalogState {
  final String message;

  const CatalogError(this.message);

  @override
  List<Object?> get props => [message];
}