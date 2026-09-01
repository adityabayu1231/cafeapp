import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wallet_result.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletResult>> getWallet({int page = 1});
}