import 'package:flutter/material.dart';
import 'package:car_showroom/models/auth/user_registration.dart';
import 'package:car_showroom/services/auth/auth_service.dart';

class RegisterBottomSheet extends StatefulWidget {
  const RegisterBottomSheet({super.key});

  @override
  State<RegisterBottomSheet> createState() => _RegisterBottomSheetState();
}

class _RegisterBottomSheetState extends State<RegisterBottomSheet> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _fioController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fioController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final registration = UserRegistration(
        email: _emailController.text,
        fio: _fioController.text,
        password: _passwordController.text,
      );
      await _authService.register(registration);
      if (mounted) {
        Navigator.pop(context); // закрыть регистрацию
        // После регистрации показываем диалог с предложением войти
        _showLoginPrompt();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Регистрация успешна'),
        content: const Text('Теперь вы можете войти в приложение'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // закрыть диалог
              // Показать модалку входа (можно вызвать через родителя, но проще дать пользователю самому нажать "Войти" в профиле)
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Регистрация',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fioController,
              decoration: const InputDecoration(labelText: 'ФИО'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Введите ФИО' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v?.isEmpty ?? true) ? 'Введите email' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
              validator: (v) => (v?.isEmpty ?? true) ? 'Введите пароль' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Зарегистрироваться'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
