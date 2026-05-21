import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_showroom/models/car/car_summary.dart';
import 'package:car_showroom/models/catalogue/car_filters.dart';
import 'package:car_showroom/services/car/car_service.dart';
import 'package:car_showroom/views/catalogue/additional/car_card.dart';
import 'package:car_showroom/views/catalogue/additional/filters_bottom_sheet.dart';
import 'package:car_showroom/views/catalogue/additional/car_detail_bottom_sheet.dart';
import 'package:car_showroom/providers/favorites_provider.dart';
import 'package:car_showroom/core/session/session_manager.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final CarService _carService = CarService();

  List<CarSummary> _cars = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 20;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  CarFilters? _currentFilters;

  @override
  void initState() {
    super.initState();
    // Загружаем избранное при старте, если пользователь авторизован
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (SessionManager.instance.isLoggedIn) {
        context.read<FavoritesProvider>().loadFavorites();
      }
    });
    _loadInitialData();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadCars(reset: true);
  }

  Future<void> _loadCars({bool reset = false}) async {
    if (_isLoading) return;
    if (reset) {
      _currentPage = 1;
      _cars.clear();
      _hasMore = true;
    }
    if (!_hasMore && !reset) return;

    if (mounted) setState(() => _isLoading = true);

    try {
      // Создаём фильтры с q, даже если _currentFilters == null
      final filters = _currentFilters != null
          ? CarFilters(
              q: _searchQuery.isNotEmpty ? _searchQuery : null,
              brandId: _currentFilters!.brandId,
              modelId: _currentFilters!.modelId,
              generationId: _currentFilters!.generationId,
              cityId: _currentFilters!.cityId,
              priceFrom: _currentFilters!.priceFrom,
              priceTo: _currentFilters!.priceTo,
              yearFrom: _currentFilters!.yearFrom,
              yearTo: _currentFilters!.yearTo,
              bodyType: _currentFilters!.bodyType,
              fuelType: _currentFilters!.fuelType,
              transmission: _currentFilters!.transmission,
              driveType: _currentFilters!.driveType,
              origin: _currentFilters!.origin,
            )
          : CarFilters(q: _searchQuery.isNotEmpty ? _searchQuery : null);

      final cars = await _carService.getCars(
        page: _currentPage,
        pageSize: _pageSize,
        filters: filters,
      );
      if (mounted) {
        setState(() {
          if (reset) {
            _cars = cars;
          } else {
            _cars.addAll(cars);
          }
          _hasMore = cars.length == _pageSize;
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
    debugPrint('🔍 apply: query=$query, filters=$filters');
    setState(() {
      if (query != null) {
        _searchQuery = query;
        _searchController.value = TextEditingValue(text: query);
      }
      _currentFilters = filters;
    });
    debugPrint('🔍 after setState: _searchQuery="$_searchQuery"');
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

  /// Используем провайдер для добавления/удаления избранного
  Future<void> _toggleFavorite(CarSummary car) async {
    final provider = context.read<FavoritesProvider>();
    final isFavorite = provider.isFavorite(car.carId);
    bool success;
    if (isFavorite) {
      success = await provider.removeFavorite(car.carId);
    } else {
      success = await provider.addFavorite(car.carId);
    }
    if (!success && mounted) {
      _showErrorSnackBar('Ошибка изменения избранного');
    }
    // Состояние обновится автоматически через провайдер, не нужно вызывать setState
  }

  void _onSearchPressed() {
    debugPrint('🔍 _onSearchPressed called, query="${_searchController.text}"');
    final query = _searchController.text;
    _applySearchAndFilters(query: query);
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
        onFavoriteChanged: (isNowFavorite) {
          // Провайдер уже обновит глобальное состояние, можно ничего не делать
          // Но принудительно обновим экран каталога через setState, если нужно
          if (mounted) {
            setState(() {}); // Перерисовка, чтобы обновить иконку в карточке
          }
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
    // Подписываемся на провайдер, чтобы при изменении избранного перерисовывать карточки
    final favoritesProvider = context.watch<FavoritesProvider>();

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
                    controller: _searchController,
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
                    _onSearchPressed();
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
                          isFavorite: favoritesProvider.isFavorite(car.carId),
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
