import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_showroom/providers/favorites_provider.dart';
import 'package:car_showroom/views/catalogue/additional/car_card.dart';
import 'package:car_showroom/core/session/session_manager.dart';
import 'package:car_showroom/models/car/car_summary.dart';
import 'package:car_showroom/views/catalogue/additional/car_detail_bottom_sheet.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Загружаем избранное при входе на экран, если пользователь авторизован
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (SessionManager.instance.isLoggedIn) {
        context.read<FavoritesProvider>().loadFavorites();
      }
    });
  }

  Future<void> _refresh() async {
    await context.read<FavoritesProvider>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: provider.isLoading && provider.favoriteCars.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.favoriteCars.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('У вас пока нет избранных автомобилей'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                itemCount: provider.favoriteCars.length,
                itemBuilder: (context, index) {
                  final car = provider.favoriteCars[index];
                  return CarCard(
                    car: car,
                    isFavorite: true, // на этом экране всегда true
                    onFavoriteToggle: () async {
                      // Удаляем из избранного
                      await provider.removeFavorite(car.carId);
                    },
                    onTap: () {
                      // Открыть детальную модалку (аналогично каталогу)
                      _openCarDetail(car);
                    },
                  );
                },
              ),
            ),
    );
  }

  void _openCarDetail(CarSummary car) {
    final provider = context.read<FavoritesProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CarDetailBottomSheet(
        carId: car.carId,
        isFavorite: provider.isFavorite(car.carId),
        onFavoriteChanged: (_) {
          // Провайдер обновит глобальное состояние, можно не делать ничего
        },
      ),
    );
  }
}
