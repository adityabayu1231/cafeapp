import 'package:dio/dio.dart';

abstract class CheckoutRemoteDataSource {
  Future<Map<String, dynamic>> createOrder({
    required int cafeId,
    required List<Map<String, dynamic>> items,
    String? notes,
  });
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final Dio dio;
  CheckoutRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> createOrder({
    required int cafeId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    final response = await dio.post('/orders', data: {
      'cafe_id': cafeId,
      'items': items,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return response.data['data'] as Map<String, dynamic>;
  }
}