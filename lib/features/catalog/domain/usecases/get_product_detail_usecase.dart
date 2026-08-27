import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_detail_entity.dart';
import '../repositories/product_detail_repository.dart';

class GetProductDetailUseCase {
  final ProductDetailRepository repository;

  GetProductDetailUseCase(this.repository);

  Future<Either<Failure, ProductDetailEntity>> call(int productId) {
    return repository.getProductDetail(productId);
  }
}