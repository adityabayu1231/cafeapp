import 'package:dio/dio.dart';

abstract class CafeRemoteDataSource {
  Future<Map<String, dynamic>> getCafes({String? city, int page = 1});
}

class CafeRemoteDataSourceImpl implements CafeRemoteDataSource {
  final Dio dio;

  CafeRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getCafes({String? city, int page = 1}) async {
    final response = await dio.get('/cafes', queryParameters: {
      if (city != null && city.isNotEmpty) 'city': city,
      'page': page,
    });
    return response.data['data'] as Map<String, dynamic>;
  }
}