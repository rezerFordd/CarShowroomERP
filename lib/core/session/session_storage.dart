import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:car_showroom/core/session/session.dart';

class SessionStorage {
  static const _key = 'app_session';
  final _s = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> save(AppSession s) =>
      _s.write(key: _key, value: jsonEncode(s.toJson()));

  Future<AppSession?> load() async {
    final raw = await _s.read(key: _key);
    if (raw == null) return null;
    final map = jsonDecode(raw);
    if (map is Map<String, dynamic>) {
      return AppSession.fromJson(map);
    }
    return AppSession.fromJson(Map<String, dynamic>.from(map as Map));
  }

  Future<void> clear() => _s.delete(key: _key);
}
