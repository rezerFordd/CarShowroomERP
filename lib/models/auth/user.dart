class User {
  final int userId;
  final String email;
  final String fio;
  final String role;

  User({
    required this.userId,
    required this.email,
    required this.fio,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'email': email,
    'fio': fio,
    'role': role,
  };
}
