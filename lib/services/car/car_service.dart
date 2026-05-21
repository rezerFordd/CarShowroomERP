import 'package:dio/dio.dart';
import 'package:car_showroom/core/api_client.dart';
import 'package:car_showroom/models/car/car_summary.dart';
import 'package:car_showroom/models/car/car_detail.dart';
import 'package:car_showroom/models/catalogue/car_filters.dart';
import 'package:car_showroom/models/catalogue/paginated_response.dart';

class CarService {
  final ApiClient _apiClient = ApiClient();

  Future<PaginatedResponse<CarSummary>> getCars({
    required int page,
    int pageSize = 20,
    CarFilters? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (filters != null) {
        queryParams.addAll(filters.toQueryParams());
      }

      final response = await _apiClient.authDio.get(
        '/api/v1/user/cars',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return PaginatedResponse<CarSummary>.fromJson(
          response.data,
          (json) => CarSummary.fromJson(json as Map<String, dynamic>),
        );
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

  Future<CarDetail> getCarDetail(int carId) async {
    try {
      final response = await _apiClient.authDio.get('/api/v1/user/cars/$carId');
      if (response.statusCode == 200) {
        return CarDetail.fromJson(response.data as Map<String, dynamic>);
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
    String message = 'Ошибка загрузки данных';
    if (e.response?.data != null && e.response!.data['detail'] != null) {
      message = e.response!.data['detail'].toString();
    }
    return Exception(message);
  }
}
