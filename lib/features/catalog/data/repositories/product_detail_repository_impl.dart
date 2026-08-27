import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product_detail_entity.dart';
import '../../domain/repositories/product_detail_repository.dart';
import '../datasources/product_detail_remote_datasource.dart';

class ProductDetailRepositoryImpl implements ProductDetailRepository {
  final ProductDetailRemoteDataSource remoteDataSource;

  ProductDetailRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ProductDetailEntity>> getProductDetail(int productId) async {
    try {
      final data = await remoteDataSource.getProductDetail(productId);
      return Right(ProductDetailEntity.fromJson(data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Left(ServerFailure('Produk tidak ditemukan.'));
      }
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