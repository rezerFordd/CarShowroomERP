import 'package:dio/dio.dart';
import 'package:car_showroom/core/api_client.dart';
import 'package:car_showroom/models/order/order.dart';
import 'package:car_showroom/models/order/create_order_request.dart';

class OrdersService {
  final ApiClient _apiClient = ApiClient();

  /// Создать заказ
  Future<Order> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _apiClient.authDio.post(
        '/api/v1/user/orders',
        data: request.toJson(),
      );
      if (response.statusCode == 201) {
        return Order.fromJson(response.data as Map<String, dynamic>);
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
    String message = 'Ошибка создания заказа';
    if (e.response?.data != null && e.response!.data['detail'] != null) {
      message = e.response!.data['detail'].toString();
    }
    return Exception(message);
  }
}
