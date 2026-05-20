import 'dart:convert';

class AppSession {
  final int? userId;
  final String? accessToken;
  final String? refreshToken;

  const AppSession({
    this.userId,
    this.accessToken,
    this.refreshToken,
  });

  bool get hasUser => userId != null && userId! > 0;

  bool get isAccessTokenExpired {
  final token = accessToken;
  if (token == null || token.isEmpty) return true;
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final json = jsonDecode(decoded) as Map<String, dynamic>;
    final exp = json['exp'];
    if (exp == null) return false;
    final expDate = DateTime.fromMillisecondsSinceEpoch(
      (exp is int) ? exp * 1000 : int.parse(exp.toString()) * 1000,
    );
    return DateTime.now().isAfter(expDate);
  } catch (_) {
    return true;
  }
}

  AppSession copyWith({
    int? userId,
    String? accessToken,
    String? refreshToken,
    bool dropUser = false,
  }) {
    return AppSession(
      userId: dropUser ? null : (userId ?? this.userId),
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };

  factory AppSession.fromJson(Map<String, dynamic> j) {
    final dynamic u = j['userId'];
    final dynamic at = j['accessToken'];
    final dynamic rt = j['refreshToken'];

    int? parseNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      if (v is String && v.trim().isNotEmpty) return int.tryParse(v);
      return null;
    }

    return AppSession(
      userId: parseNum(u),
      accessToken: at,
      refreshToken: rt,
    );
  }
}
