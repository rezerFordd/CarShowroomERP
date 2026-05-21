import 'package:dio/dio.dart';
import 'package:car_showroom/core/api_client.dart';
import 'package:car_showroom/models/car/model.dart';

class ModelsService {
  final ApiClient _apiClient = ApiClient();

  Future<List<CarModel>> getModels({int? brandId}) async {
    try {
      final queryParams = brandId != null ? {'brand_id': brandId} : null;
      final response = await _apiClient.authDio.get(
        '/api/v1/user/models',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => CarModel.fromJson(json)).toList();
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
    String message = 'Ошибка загрузки моделей';
    if (e.response?.data != null && e.response!.data['detail'] != null) {
      message = e.response!.data['detail'].toString();
    }
    return Exception(message);
  }
}
