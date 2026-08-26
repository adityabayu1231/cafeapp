import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_list_result.dart';

abstract class CatalogRepository {
  Future<Either<Failure, ProductListResult>> getProducts({required int cafeId, int page = 1});
}