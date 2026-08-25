import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cafe_list_result.dart';

abstract class CafeRepository {
  Future<Either<Failure, CafeListResult>> getCafes({String? city, int page = 1});
}