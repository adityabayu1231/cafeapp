import 'package:dio/dio.dart';

abstract class ProductRemoteDataSource {
  Future<Map<String, dynamic>> getProducts({required int cafeId, int page = 1});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getProducts({required int cafeId, int page = 1}) async {
    final response = await dio.get('/cafes/$cafeId/products', queryParameters: {
      'page': page,
    });
    return response.data['data'] as Map<String, dynamic>;
  }
}