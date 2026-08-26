import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_list_result.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/product_remote_datasource.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final ProductRemoteDataSource remoteDataSource;

  CatalogRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ProductListResult>> getProducts({required int cafeId, int page = 1}) async {
    try {
      final data = await remoteDataSource.getProducts(cafeId: cafeId, page: page);
      final items = (data['items'] as List)
          .map((e) => ProductEntity.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = data['pagination'] as Map<String, dynamic>;

      return Right(ProductListResult(
        items: items,
        currentPage: pagination['current_page'] as int,
        lastPage: pagination['last_page'] as int,
        total: pagination['total'] as int,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e)));
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan tidak terduga.'));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
    }
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Tidak dapat terhubung ke server.';
  }
}