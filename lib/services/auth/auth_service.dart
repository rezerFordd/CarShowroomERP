import 'package:dio/dio.dart';
import 'package:car_showroom/core/api_client.dart';
import 'package:car_showroom/core/session/session_manager.dart';
import 'package:car_showroom/models/auth/user.dart';
import 'package:car_showroom/models/auth/user_registration.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final SessionManager _sessionManager = SessionManager.instance;

  Future<User> register(UserRegistration registration) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/register',
        data: registration.toJson(),
      );
      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return User(
          userId: data['user_id'] as int,
          email: data['email'] as String,
          fio: data['fio'] as String,
          role: data['role'] as String,
        );
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['access_token'] as String;
        final refreshToken = data['refresh_token'] as String;
        await _sessionManager.setTokens(accessToken, refreshToken);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> refreshTokens() async {
    final refreshToken = _sessionManager.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Refresh token not found');
    }
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _sessionManager.setTokens(
          data['access_token'] as String,
          data['refresh_token'] as String,
        );
      } else {
        throw Exception('Failed to refresh tokens');
      }
    } on DioException catch (e) {
      await _sessionManager.logout();
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    await _sessionManager.logout();
  }

  Exception _handleDioError(DioException e) {
    String message = 'Network error';
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('detail')) {
        message = data['detail'].toString();
      } else {
        message = 'Server error: ${e.response?.statusCode}';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = 'Receive timeout';
    }
    return Exception(message);
  }
}
