import 'package:flutter/material.dart';
import 'package:car_showroom/services/favorites/favorites_service.dart';
import 'package:car_showroom/views/catalogue/additional/car_card.dart';
import 'package:car_showroom/models/car/car_summary.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<CarSummary> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await _favoritesService.getFavorites();
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showError('Ошибка загрузки избранного');
    }
  }

  Future<void> _removeFromFavorites(int carId) async {
    try {
      await _favoritesService.removeFavorite(carId);
      setState(() {
        _favorites.removeWhere((car) => car.carId == carId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Удалено из избранного'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('Не удалось удалить');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? const Center(child: Text('У вас пока нет избранных автомобилей'))
          : RefreshIndicator(
              onRefresh: _loadFavorites,
              child: ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final car = _favorites[index];
                  return CarCard(
                    car: car,
                    isFavorite: true,
                    onFavoriteToggle: () => _removeFromFavorites(car.carId),
                    onTap: () {
                      // Открыть детальную модалку, передав carId
                      // Пока пропустим (можно сделать позже)
                    },
                  );
                },
              ),
            ),
    );
  }
}
