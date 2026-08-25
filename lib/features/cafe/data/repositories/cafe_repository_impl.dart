import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cafe_entity.dart';
import '../../domain/entities/cafe_list_result.dart';
import '../../domain/repositories/cafe_repository.dart';
import '../datasources/cafe_remote_datasource.dart';

class CafeRepositoryImpl implements CafeRepository {
  final CafeRemoteDataSource remoteDataSource;

  CafeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, CafeListResult>> getCafes({String? city, int page = 1}) async {
    try {
      final data = await remoteDataSource.getCafes(city: city, page: page);
      final items = (data['items'] as List)
          .map((e) => CafeEntity.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = data['pagination'] as Map<String, dynamic>;

      return Right(CafeListResult(
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