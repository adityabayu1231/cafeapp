import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cafe_detail_entity.dart';

abstract class CafeDetailRepository {
  Future<Either<Failure, CafeDetailEntity>> getCafeDetail(int cafeId);
}