import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, ({List<CartItemEntity> items, int? cafeId, String? cafeName})>> loadCart() async {
    try {
      final result = await localDataSource.getCart();
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure('Gagal memuat cart tersimpan.'));
    }
  }

  @override
  Future<Either<Failure, void>> saveCart({
    required List<CartItemEntity> items,
    required int? cafeId,
    required String? cafeName,
  }) async {
    try {
      await localDataSource.saveCart(items: items, cafeId: cafeId, cafeName: cafeName);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Gagal menyimpan cart.'));
    }
  }
}