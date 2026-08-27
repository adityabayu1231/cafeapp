import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_detail_entity.dart';

abstract class ProductDetailRepository {
  Future<Either<Failure, ProductDetailEntity>> getProductDetail(int productId);
}