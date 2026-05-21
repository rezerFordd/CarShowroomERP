import 'package:dio/dio.dart';
import 'package:car_showroom/core/session/session_manager.dart';
import 'package:flutter/material.dart';

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
    debugPrint('🔄 [AuthInterceptor] 401 для ${err.requestOptions.path}, пробуем обновить токен...');
    try {
      final newTokens = await _refreshToken();
      if (newTokens != null) {
        debugPrint('✅ [AuthInterceptor] Токены обновлены, повторяем запрос');
        await sessionManager.setTokens(
          newTokens['access_token']!,
          newTokens['refresh_token']!,
        );
        final newOptions = err.requestOptions;
        newOptions.headers['Authorization'] = 'Bearer ${sessionManager.accessToken}';
        try {
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
        } catch (retryError) {
          debugPrint('❌ [AuthInterceptor] Повторный запрос не удался: $retryError');
          return handler.next(retryError as DioException);
        }
      } else {
        debugPrint('❌ [AuthInterceptor] Не удалось обновить токены, разлогиниваем');
        await sessionManager.logout();
        return handler.next(err);
      }
    } catch (e) {
      debugPrint('❌ [AuthInterceptor] Ошибка при обновлении: $e');
      await sessionManager.logout();
      return handler.next(err);
    }
  }
  handler.next(err);
}

  Future<Map<String, String>?> _refreshToken() async {
    final refresh = sessionManager.refreshToken;
    if (refresh == null || refresh.isEmpty) {
      debugPrint('❌ [_refreshToken] refreshToken отсутствует');
      return null;
    }
    try {
      debugPrint('🔄 [_refreshToken] Отправляем запрос на /refresh');
      final response = await tokenDio.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refresh},
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        if (accessToken != null && refreshToken != null) {
          debugPrint('✅ [_refreshToken] Получены новые токены');
          return {'access_token': accessToken, 'refresh_token': refreshToken};
        }
      }
      debugPrint('❌ [_refreshToken] Ответ не содержит токенов');
    } catch (e) {
      debugPrint('❌ [_refreshToken] Исключение: $e');
    }
    return null;
  }
  // @override
  // void onError(DioException err, ErrorInterceptorHandler handler) async {
  //   if (err.response?.statusCode == 401 &&
  //       err.requestOptions.path != '/api/v1/auth/refresh' &&
  //       err.requestOptions.path != '/api/v1/auth/login') {
  //     try {
  //       final newTokens = await _refreshToken();
  //       if (newTokens != null) {
  //         await sessionManager.setTokens(
  //           newTokens['access_token'],
  //           newTokens['refresh_token'],
  //         );
  //         final newOptions = err.requestOptions;
  //         newOptions.headers['Authorization'] =
  //             'Bearer ${sessionManager.accessToken}';
  //         final response = await tokenDio.request(
  //           newOptions.path,
  //           options: Options(
  //             method: newOptions.method,
  //             headers: newOptions.headers,
  //           ),
  //           data: newOptions.data,
  //           queryParameters: newOptions.queryParameters,
  //         );
  //         return handler.resolve(response);
  //       }
  //     } catch (_) {
  //       await sessionManager.logout();
  //     }
  //   }
  //   handler.next(err);
  // }

  // Future<Map<String, String>?> _refreshToken() async {
  //   final refresh = sessionManager.refreshToken;
  //   if (refresh == null || refresh.isEmpty) return null;
  //   try {
  //     final response = await tokenDio.post(
  //       '/api/v1/auth/refresh',
  //       data: {'refresh_token': refresh},
  //     );
  //     if (response.statusCode == 200) {
  //       final data = response.data as Map<String, dynamic>;
  //       final accessToken = data['access_token'] as String?;
  //       final refreshToken = data['refresh_token'] as String?;
  //       if (accessToken != null && refreshToken != null) {
  //         return {'access_token': accessToken, 'refresh_token': refreshToken};
  //       }
  //     }
  //   } catch (_) {}
  //   return null;
  // }
}
