import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cafe_list_result.dart';
import '../repositories/cafe_repository.dart';

class GetCafesUseCase {
  final CafeRepository repository;

  GetCafesUseCase(this.repository);

  Future<Either<Failure, CafeListResult>> call({String? city, int page = 1}) {
    return repository.getCafes(city: city, page: page);
  }
}