import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:car_showroom/core/session/session_manager.dart';
import "auth_interceptor.dart";

class ApiClient {
  static final ApiClient _i = ApiClient._internal();
  factory ApiClient() => _i;

  late final Dio dio;
  late final Dio authDio;
  ApiClient._internal() {
    final options = _base();
    dio = Dio(options);
    authDio = Dio(options);

    final refreshDio = Dio(options);
    final interceptor = AuthInterceptor(SessionManager.instance, refreshDio);
    authDio.interceptors.add(interceptor);

    authDio.interceptors.add(_CurlLogger());
  }

  static BaseOptions _base() {
    final baseUrl = dotenv.env['API_BASE_URL']?.trim();
    assert(baseUrl != null && baseUrl.isNotEmpty, 'API_BASE_URL пуст');
    return BaseOptions(
      baseUrl: baseUrl!,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
      headers: {'Accept': 'application/json, text/plain, */*'},
    );
  }
}

class _CurlLogger extends Interceptor {
  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    final qp = o.queryParameters.isEmpty
        ? ''
        : '?${o.queryParameters.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent('${e.value}')}').join('&')}';

    final hdrs =
        (o.headers..removeWhere((k, _) => k.toLowerCase() == 'authorization'))
            .entries
            .map((e) => "-H '${e.key}: ${e.value}'")
            .join(' ');
    final body = (o.data == null) ? '' : "-d '${_toBody(o.data)}'";
    debugPrint('→ ${o.method} ${o.baseUrl}${o.path}$qp');
    debugPrint('curl -X ${o.method} \'${o.baseUrl}${o.path}$qp\' $hdrs $body');
    h.next(o);
  }

  @override
  void onResponse(Response r, ResponseInterceptorHandler h) {
    final body = _limit(r.data);
    debugPrint(
      '← ${r.statusCode} ${r.requestOptions.method} ${r.requestOptions.baseUrl}${r.requestOptions.path}',
    );
    if (body != null) debugPrint('← body: $body');
    h.next(r);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) {
    debugPrint(
      '✖ ${e.response?.statusCode ?? ''} ${e.requestOptions.method} '
      '${e.requestOptions.baseUrl}${e.requestOptions.path}',
    );
    if (e.response?.data != null) {
      debugPrint('✖ body: ${_limit(e.response!.data)}');
    } else if (e.error != null) {
      debugPrint('✖ error: ${e.error}');
    }
    h.next(e);
  }

  static String _toBody(dynamic data) {
    if (data == null) return '';
    try {
      if (data is String) return data;
      return jsonEncode(data);
    } catch (_) {
      return '$data';
    }
  }

  static String? _limit(dynamic data) {
    String s;
    try {
      s = (data is String) ? data : jsonEncode(data);
    } catch (_) {
      s = '$data';
    }
    if (s.length > 400) s = '${s.substring(0, 400)}…(${s.length} bytes)';
    return s;
  }
}
