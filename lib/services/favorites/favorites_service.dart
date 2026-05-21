import 'package:dio/dio.dart';
import 'package:car_showroom/core/api_client.dart';
import 'package:car_showroom/models/car/car_summary.dart';

class FavoritesService {
  final ApiClient _apiClient = ApiClient();

  Future<List<CarSummary>> getFavorites() async {
    try {
      final response = await _apiClient.authDio.get('/api/v1/user/favorites');
      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data.map((json) => CarSummary.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> addFavorite(int carId) async {
    try {
      final response = await _apiClient.authDio.post(
        '/api/v1/user/favorites/$carId',
      );
      if (response.statusCode == 201) {
        return response.data as String;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> removeFavorite(int carId) async {
    try {
      final response = await _apiClient.authDio.delete(
        '/api/v1/user/favorites/$carId',
      );
      if (response.statusCode == 200) {
        return response.data as String;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    String message = 'Ошибка работы с избранным';
    if (e.response?.data != null && e.response!.data['detail'] != null) {
      message = e.response!.data['detail'].toString();
    }
    return Exception(message);
  }
}
