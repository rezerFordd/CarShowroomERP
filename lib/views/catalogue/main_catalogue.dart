import 'package:flutter/material.dart';
import 'package:car_showroom/models/car/car_summary.dart';
import 'package:car_showroom/models/catalogue/car_filters.dart';
import 'package:car_showroom/services/car/car_service.dart';
import 'package:car_showroom/services/favorites/favorites_service.dart';
import 'package:car_showroom/views/catalogue/additional/car_card.dart';
import 'package:car_showroom/views/catalogue/additional/filters_bottom_sheet.dart';
import 'package:car_showroom/views/catalogue/additional/car_detail_bottom_sheet.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final CarService _carService = CarService();
  final FavoritesService _favoritesService = FavoritesService();

  List<CarSummary> _cars = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 20;

  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  CarFilters? _currentFilters;

  // Множество ID избранных автомобилей (для отображения сердечек)
  Set<int> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadFavorites(); // сначала загружаем избранное
    await _loadCars(reset: true);
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _favoritesService.getFavorites();
      setState(() {
        _favoriteIds = favorites.map((car) => car.carId).toSet();
      });
    } catch (e) {
      // Не показываем ошибку, просто оставляем пустое избранное
      debugPrint('Ошибка загрузки избранного: $e');
    }
  }

  Future<void> _loadCars({bool reset = false}) async {
    if (_isLoading) return;
    if (reset) {
      _currentPage = 1;
      _cars.clear();
      _hasMore = true;
    }
    if (!_hasMore && !reset) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final filters = _currentFilters?.copyWith(
        q: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      final response = await _carService.getCars(
        page: _currentPage,
        pageSize: _pageSize,
        filters: filters,
      );
      setState(() {
        if (reset) {
          _cars = response.items;
        } else {
          _cars.addAll(response.items);
        }
        _hasMore = response.items.length == _pageSize;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Ошибка загрузки машин: ${e.toString()}');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadCars();
    }
  }

  void _applySearchAndFilters({String? query, CarFilters? filters}) {
    setState(() {
      _searchQuery = query ?? _searchQuery;
      _currentFilters = filters;
    });
    _loadCars(reset: true);
  }

  void _showFilters() async {
    final result = await showModalBottomSheet<CarFilters?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FiltersBottomSheet(initialFilters: _currentFilters),
    );
    if (result != null) {
      _applySearchAndFilters(filters: result);
    }
  }

  void _toggleFavorite(CarSummary car) async {
    final isFavorite = _favoriteIds.contains(car.carId);
    try {
      if (isFavorite) {
        await _favoritesService.removeFavorite(car.carId);
      } else {
        await _favoritesService.addFavorite(car.carId);
      }
      setState(() {
        if (isFavorite) {
          _favoriteIds.remove(car.carId);
        } else {
          _favoriteIds.add(car.carId);
        }
      });
    } catch (e) {
      _showErrorSnackBar('Ошибка изменения избранного');
    }
  }

  void _openCarDetail(CarSummary car) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CarDetailBottomSheet(
        carId: car.carId,
        isFavorite: _favoriteIds.contains(car.carId),
        onFavoriteChanged: (isNowFavorite) {
          // Обновляем состояние в списке при изменении избранного из модалки
          setState(() {
            if (isNowFavorite) {
              _favoriteIds.add(car.carId);
            } else {
              _favoriteIds.remove(car.carId);
            }
          });
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Showroom'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilters,
            tooltip: 'Фильтры',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Поиск по марке, модели, описанию',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (value) {
                      _applySearchAndFilters(query: value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _applySearchAndFilters(query: _searchQuery);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Применить'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cars.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ничего не найдено',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _loadCars(reset: true),
                          child: const Text('Обновить'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadCars(reset: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _cars.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _cars.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final car = _cars[index];
                        return CarCard(
                          car: car,
                          isFavorite: _favoriteIds.contains(car.carId),
                          onFavoriteToggle: () => _toggleFavorite(car),
                          onTap: () => _openCarDetail(car),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
