import 'package:flutter/material.dart';
import 'package:car_showroom/core/session/session_manager.dart';
import 'package:car_showroom/services/auth/auth_service.dart';
import 'package:car_showroom/views/auth/login.dart';
import 'package:car_showroom/views/auth/registration.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SessionManager _sessionManager = SessionManager.instance;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _sessionManager.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    _sessionManager.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  void _showLoginModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const LoginBottomSheet(),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showRegisterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const RegisterBottomSheet(),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _sessionManager.isLoggedIn;
    final userId = _sessionManager.userId;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Center(
        child: isLoggedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ID пользователя: $userId',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Выйти'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Вы не авторизованы',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _showLoginModal,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 48),
                    ),
                    child: const Text('Войти'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _showRegisterModal,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(200, 48),
                    ),
                    child: const Text('Зарегистрироваться'),
                  ),
                ],
              ),
      ),
    );
  }
}
