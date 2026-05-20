class UserRegistration {
  final String email;
  final String fio;
  final String password;

  UserRegistration({
    required this.email,
    required this.fio,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'fio': fio,
    'password': password,
  };
}
