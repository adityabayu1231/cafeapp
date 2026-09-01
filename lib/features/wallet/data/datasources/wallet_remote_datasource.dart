import 'package:dio/dio.dart';

abstract class WalletRemoteDataSource {
  Future<Map<String, dynamic>> getWallet({int page = 1});
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final Dio dio;
  WalletRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getWallet({int page = 1}) async {
    final response = await dio.get('/wallet', queryParameters: {'page': page});
    return response.data['data'] as Map<String, dynamic>;
  }
}