import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cafe_detail_entity.dart';
import '../repositories/cafe_detail_repository.dart';

class GetCafeDetailUseCase {
  final CafeDetailRepository repository;

  GetCafeDetailUseCase(this.repository);

  Future<Either<Failure, CafeDetailEntity>> call(int cafeId) {
    return repository.getCafeDetail(cafeId);
  }
}