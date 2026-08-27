import 'package:dio/dio.dart';

abstract class ProductDetailRemoteDataSource {
  Future<Map<String, dynamic>> getProductDetail(int productId);
}

class ProductDetailRemoteDataSourceImpl implements ProductDetailRemoteDataSource {
  final Dio dio;

  ProductDetailRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getProductDetail(int productId) async {
    final response = await dio.get('/products/$productId');
    return response.data['data'] as Map<String, dynamic>;
  }
}