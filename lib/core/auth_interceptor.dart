import 'package:dio/dio.dart';
import 'package:car_showroom/core/session/session_manager.dart';

class AuthInterceptor extends Interceptor {
  final SessionManager sessionManager;
  final Dio tokenDio;

  AuthInterceptor(this.sessionManager, this.tokenDio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = sessionManager.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != '/api/v1/auth/refresh' &&
        err.requestOptions.path != '/api/v1/auth/login') {
      try {
        final newTokens = await _refreshToken();
        if (newTokens != null) {
          await sessionManager.setTokens(
            newTokens['access_token'],
            newTokens['refresh_token'],
          );
          final newOptions = err.requestOptions;
          newOptions.headers['Authorization'] =
              'Bearer ${sessionManager.accessToken}';
          final response = await tokenDio.request(
            newOptions.path,
            options: Options(
              method: newOptions.method,
              headers: newOptions.headers,
            ),
            data: newOptions.data,
            queryParameters: newOptions.queryParameters,
          );
          return handler.resolve(response);
        }
      } catch (_) {
        await sessionManager.logout();
      }
    }
    handler.next(err);
  }

  Future<Map<String, String>?> _refreshToken() async {
    final refresh = sessionManager.refreshToken;
    if (refresh == null || refresh.isEmpty) return null;
    try {
      final response = await tokenDio.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refresh},
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        if (accessToken != null && refreshToken != null) {
          return {'access_token': accessToken, 'refresh_token': refreshToken};
        }
      }
    } catch (_) {}
    return null;
  }
}
