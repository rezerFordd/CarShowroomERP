import 'package:flutter/material.dart';
import 'package:car_showroom/core/session/session_storage.dart';
import 'package:car_showroom/core/session/session.dart';
import 'dart:convert';

class SessionManager {
  SessionManager._();
  static final instance = SessionManager._();

  final _storage = SessionStorage();
  AppSession _session = const AppSession();

  Future<void> init() async {
    _session = await _storage.load() ?? const AppSession();
  }

  bool get isLoggedIn => _session.hasUser;
  bool get isAccessTokenExpired => _session.isAccessTokenExpired;
  int? get userId => _session.userId;

  String? get accessToken => _session.accessToken;
  String? get refreshToken => _session.refreshToken;

  Future<void> setUserId(int id) async {
    _session = _session.copyWith(userId: id);
    await _storage.save(_session);
  }

  Future<String?> getAccessToken() async {
    return _session.accessToken;
  }

  Future<void> setTokens(String? accessToken, String? refreshToken) async {
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw ArgumentError('Access token and refresh token must be non-empty');
    }
    int? newUserId;

    try {
      final parts = accessToken.split('.');
      if (parts.length == 3) {
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final json = jsonDecode(decoded) as Map<String, dynamic>;
        newUserId = int.tryParse(json['user_id']?.toString() ?? '');
      }
    } catch (e) {
      debugPrint('⚠️ JWT parse error: $e');
    }

    _session = _session.copyWith(
      userId: newUserId,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _storage.save(_session);
  }

  Future<void> logout() async {
    _session = const AppSession();
    await _storage.clear();
  }
}
