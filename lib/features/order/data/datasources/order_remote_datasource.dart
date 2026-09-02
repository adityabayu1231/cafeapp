import 'package:dio/dio.dart';

abstract class OrderRemoteDataSource {
  Future<Map<String, dynamic>> getOrders({int page = 1});
  Future<Map<String, dynamic>> getOrderDetail(int orderId);
  Future<Map<String, dynamic>> cancelOrder(int orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;
  OrderRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getOrders({int page = 1}) async {
    final response = await dio.get('/orders', queryParameters: {'page': page});
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getOrderDetail(int orderId) async {
    final response = await dio.get('/orders/$orderId');
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    final response = await dio.patch('/orders/$orderId/cancel');
    return response.data['data'] as Map<String, dynamic>;
  }
}