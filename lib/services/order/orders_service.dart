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

  Future<List<Order>> getMyOrders() async {
    try {
      final response = await _apiClient.authDio.get('/api/v1/user/orders');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Ошибка получения Ваших заказов');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteOrder(int orderId) async {
    try {
      final response = await _apiClient.authDio.delete(
        '/api/v1/user/orders/$orderId',
      );
      if (response.statusCode != 200) {
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
}
