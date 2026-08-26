import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_list_result.dart';
import '../repositories/catalog_repository.dart';

class GetProductsUseCase {
  final CatalogRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, ProductListResult>> call({required int cafeId, int page = 1}) {
    return repository.getProducts(cafeId: cafeId, page: page);
  }
}