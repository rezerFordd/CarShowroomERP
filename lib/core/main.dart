import 'package:car_showroom/core/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:car_showroom/providers/favorites_provider.dart';
import 'package:car_showroom/core/api_client.dart';
import 'package:car_showroom/core/session/session_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SessionManager.instance.init();
  final apiClient = ApiClient();
  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  const MyApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    debugPrint('API_BASE_URL = ${dotenv.env['API_BASE_URL']}');
    return ChangeNotifierProvider(
      create: (_) => FavoritesProvider(),
      child: MaterialApp(
        title: 'Car Showroom',
        routes: routes,
        initialRoute: "/",
      ),
    );
  }
}
