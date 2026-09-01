import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wallet_result.dart';
import '../../domain/entities/wallet_transaction_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  WalletRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, WalletResult>> getWallet({int page = 1}) async {
    try {
      final data = await remoteDataSource.getWallet(page: page);
      final balance = data['balance'] as int;
      final transactionsData = data['transactions'] as Map<String, dynamic>;
      final items = (transactionsData['items'] as List)
          .map((e) => WalletTransactionEntity.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = transactionsData['pagination'] as Map<String, dynamic>;

      return Right(WalletResult(
        balance: balance,
        transactions: items,
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