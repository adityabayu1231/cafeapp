import 'package:dio/dio.dart';

abstract class CafeDetailRemoteDataSource {
  Future<Map<String, dynamic>> getCafeDetail(int cafeId);
}

class CafeDetailRemoteDataSourceImpl implements CafeDetailRemoteDataSource {
  final Dio dio;

  CafeDetailRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getCafeDetail(int cafeId) async {
    final response = await dio.get('/cafes/$cafeId');
    return response.data['data'] as Map<String, dynamic>;
  }
}