import 'package:flutter/material.dart';
import 'package:car_showroom/services/favorites/favorites_service.dart';
import 'package:car_showroom/models/car/car_summary.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();

  Set<int> _favoriteIds = {};
  List<CarSummary> _favoriteCars = [];
  bool _isLoading = false;

  Set<int> get favoriteIds => _favoriteIds;
  List<CarSummary> get favoriteCars => _favoriteCars;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    try {
      final cars = await _favoritesService.getFavorites();
      _favoriteCars = cars;
      _favoriteIds = cars.map((c) => c.carId).toSet();
    } catch (e) {
      debugPrint('Ошибка загрузки избранного: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addFavorite(int carId) async {
    try {
      await _favoritesService.addFavorite(carId);
      _favoriteIds.add(carId);
      await loadFavorites();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка добавления: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(int carId) async {
    try {
      await _favoritesService.removeFavorite(carId);
      _favoriteIds.remove(carId);
      _favoriteCars.removeWhere((car) => car.carId == carId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка удаления: $e');
      return false;
    }
  }

  bool isFavorite(int carId) => _favoriteIds.contains(carId);
}
