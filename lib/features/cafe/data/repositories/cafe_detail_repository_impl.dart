import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cafe_detail_entity.dart';
import '../../domain/repositories/cafe_detail_repository.dart';
import '../datasources/cafe_detail_remote_datasource.dart';

class CafeDetailRepositoryImpl implements CafeDetailRepository {
  final CafeDetailRemoteDataSource remoteDataSource;

  CafeDetailRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, CafeDetailEntity>> getCafeDetail(int cafeId) async {
    try {
      final data = await remoteDataSource.getCafeDetail(cafeId);
      return Right(CafeDetailEntity.fromJson(data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Left(ServerFailure('Cafe tidak ditemukan.'));
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