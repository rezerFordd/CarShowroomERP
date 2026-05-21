import 'package:flutter/material.dart';
import 'package:car_showroom/models/catalogue/car_filters.dart';
import 'package:car_showroom/services/directory/brands_service.dart';
import 'package:car_showroom/services/directory/models_service.dart';
import 'package:car_showroom/services/directory/generations_service.dart';
import 'package:car_showroom/services/directory/cities_service.dart';
import 'package:car_showroom/models/car/brand.dart';
import 'package:car_showroom/models/car/model.dart';
import 'package:car_showroom/models/car/generation.dart';
import 'package:car_showroom/models/car/city.dart';

class FiltersBottomSheet extends StatefulWidget {
  final CarFilters? initialFilters;

  const FiltersBottomSheet({super.key, this.initialFilters});

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  // Поля фильтров
  String? _priceFromStr, _priceToStr;
  String? _yearFromStr, _yearToStr;
  String? _bodyType;
  String? _fuelType;
  String? _transmission;
  String? _driveType;
  String? _origin;

  // Справочные данные
  List<Brand> _brands = [];
  List<CarModel> _models = [];
  List<Generation> _generations = [];
  List<City> _cities = [];

  // Выбранные значения
  int? _selectedBrandId;
  int? _selectedModelId;
  int? _selectedGenerationId;
  int? _selectedCityId;

  bool _isLoadingBrands = true;
  bool _isLoadingModels = false;
  bool _isLoadingGenerations = false;
  bool _isLoadingCities = true;

  final BrandsService _brandsService = BrandsService();
  final ModelsService _modelsService = ModelsService();
  final GenerationsService _generationsService = GenerationsService();
  final CitiesService _citiesService = CitiesService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Загружаем бренды и города параллельно
    await Future.wait([_loadBrands(), _loadCities()]);

    // Если есть начальные фильтры – устанавливаем выбранные ID и подгружаем зависимые списки
    final initial = widget.initialFilters;
    if (initial != null) {
      setState(() {
        _selectedBrandId = initial.brandId;
        _selectedModelId = initial.modelId;
        _selectedGenerationId = initial.generationId;
        _selectedCityId = initial.cityId;
      });
      if (_selectedBrandId != null) {
        await _loadModelsForBrand(_selectedBrandId!);
      }
      if (_selectedModelId != null) {
        await _loadGenerationsForModel(_selectedModelId!);
      }
    }
  }

  Future<void> _loadBrands() async {
    setState(() => _isLoadingBrands = true);
    try {
      final brands = await _brandsService.getBrands();
      if (mounted) {
        setState(() {
          _brands = brands;
          _isLoadingBrands = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingBrands = false);
    }
  }

  Future<void> _loadModelsForBrand(int brandId) async {
    setState(() {
      _isLoadingModels = true;
      _models = [];
      _selectedModelId = null;
      _generations = [];
      _selectedGenerationId = null;
    });
    try {
      final models = await _modelsService.getModels(brandId: brandId);
      if (mounted) {
        setState(() {
          _models = models;
          _isLoadingModels = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingModels = false);
    }
  }

  Future<void> _loadGenerationsForModel(int modelId) async {
    setState(() {
      _isLoadingGenerations = true;
      _generations = [];
      _selectedGenerationId = null;
    });
    try {
      final generations = await _generationsService.getGenerations(
        modelId: modelId,
      );
      if (mounted) {
        setState(() {
          _generations = generations;
          _isLoadingGenerations = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingGenerations = false);
    }
  }

  Future<void> _loadCities() async {
    setState(() => _isLoadingCities = true);
    try {
      final cities = await _citiesService.getCities();
      if (mounted) {
        setState(() {
          _cities = cities;
          _isLoadingCities = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCities = false);
    }
  }

  void _applyFilters() {
    if (!_formKey.currentState!.validate()) return;
    final filters = CarFilters(
      brandId: _selectedBrandId,
      modelId: _selectedModelId,
      generationId: _selectedGenerationId,
      cityId: _selectedCityId,
      priceFrom: _priceFromStr != null && _priceFromStr!.isNotEmpty
          ? int.tryParse(_priceFromStr!)
          : null,
      priceTo: _priceToStr != null && _priceToStr!.isNotEmpty
          ? int.tryParse(_priceToStr!)
          : null,
      yearFrom: _yearFromStr != null && _yearFromStr!.isNotEmpty
          ? int.tryParse(_yearFromStr!)
          : null,
      yearTo: _yearToStr != null && _yearToStr!.isNotEmpty
          ? int.tryParse(_yearToStr!)
          : null,
      bodyType: _bodyType,
      fuelType: _fuelType,
      transmission: _transmission,
      driveType: _driveType,
      origin: _origin,
    );
    Navigator.pop(context, filters);
  }

  void _resetFilters() {
    setState(() {
      _priceFromStr = null;
      _priceToStr = null;
      _yearFromStr = null;
      _yearToStr = null;
      _bodyType = null;
      _fuelType = null;
      _transmission = null;
      _driveType = null;
      _origin = null;
      _selectedBrandId = null;
      _selectedModelId = null;
      _selectedGenerationId = null;
      _selectedCityId = null;
      _models = [];
      _generations = [];
    });
    // Сбрасываем зависимые списки (но не перезагружаем их заново)
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Фильтры',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Бренд
              _buildBrandDropdown(),
              const SizedBox(height: 8),
              // Модель (зависит от бренда)
              _buildModelDropdown(),
              const SizedBox(height: 8),
              // Поколение (зависит от модели)
              _buildGenerationDropdown(),
              const SizedBox(height: 8),
              // Город
              _buildCityDropdown(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Цена от (₽)',
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _priceFromStr,
                      onChanged: (v) => _priceFromStr = v,
                      validator: (v) => _validateNumber(v, 'цена'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Цена до (₽)',
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _priceToStr,
                      onChanged: (v) => _priceToStr = v,
                      validator: (v) => _validateNumber(v, 'цена'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Год от'),
                      keyboardType: TextInputType.number,
                      initialValue: _yearFromStr,
                      onChanged: (v) => _yearFromStr = v,
                      validator: (v) => _validateNumber(v, 'год'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Год до'),
                      keyboardType: TextInputType.number,
                      initialValue: _yearToStr,
                      onChanged: (v) => _yearToStr = v,
                      validator: (v) => _validateNumber(v, 'год'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Тип кузова'),
                initialValue: _bodyType,
                items: _bodyTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _bodyType = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Тип топлива'),
                initialValue: _fuelType,
                items: _fuelTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _fuelType = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Коробка передач'),
                initialValue: _transmission,
                items: _transmissions
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _transmission = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Привод'),
                initialValue: _driveType,
                items: _driveTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _driveType = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Состояние'),
                initialValue: _origin,
                items: _origins
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _origin = v),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetFilters,
                      child: const Text('Сбросить'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Применить'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandDropdown() {
    if (_isLoadingBrands) {
      return DropdownButtonFormField<int>(
        decoration: InputDecoration(labelText: 'Бренд'),
        items: [DropdownMenuItem(value: null, child: Text('Загрузка...'))],
        onChanged: null,
      );
    }
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(labelText: 'Бренд'),
      initialValue: _selectedBrandId,
      items: _brands
          .map((b) => DropdownMenuItem(value: b.brandId, child: Text(b.name)))
          .toList(),
      onChanged: (value) async {
        setState(() {
          _selectedBrandId = value;
          _selectedModelId = null;
          _selectedGenerationId = null;
        });
        if (value != null) {
          await _loadModelsForBrand(value);
        } else {
          setState(() {
            _models = [];
            _generations = [];
          });
        }
      },
    );
  }

  Widget _buildModelDropdown() {
    if (_isLoadingModels) {
      return DropdownButtonFormField<int>(
        decoration: InputDecoration(labelText: 'Модель'),
        items: [DropdownMenuItem(value: null, child: Text('Загрузка...'))],
        onChanged: null,
      );
    }
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(labelText: 'Модель'),
      initialValue: _selectedModelId,
      items: _models
          .map((m) => DropdownMenuItem(value: m.modelId, child: Text(m.name)))
          .toList(),
      onChanged: (value) async {
        setState(() {
          _selectedModelId = value;
          _selectedGenerationId = null;
        });
        if (value != null) {
          await _loadGenerationsForModel(value);
        } else {
          setState(() => _generations = []);
        }
      },
    );
  }

  Widget _buildGenerationDropdown() {
    if (_isLoadingGenerations) {
      return DropdownButtonFormField<int>(
        decoration: InputDecoration(labelText: 'Поколение'),
        items: [DropdownMenuItem(value: null, child: Text('Загрузка...'))],
        onChanged: null,
      );
    }
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(labelText: 'Поколение'),
      initialValue: _selectedGenerationId,
      items: _generations
          .map(
            (g) => DropdownMenuItem(value: g.generationId, child: Text(g.name)),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedGenerationId = value),
    );
  }

  Widget _buildCityDropdown() {
    if (_isLoadingCities) {
      return DropdownButtonFormField<int>(
        decoration: InputDecoration(labelText: 'Город'),
        items: [DropdownMenuItem(value: null, child: Text('Загрузка...'))],
        onChanged: null,
      );
    }
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(labelText: 'Город'),
      initialValue: _selectedCityId,
      items: _cities
          .map((c) => DropdownMenuItem(value: c.cityId, child: Text(c.name)))
          .toList(),
      onChanged: (value) => setState(() => _selectedCityId = value),
    );
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;
    if (int.tryParse(value) == null) {
      return 'Введите целое число';
    }
    return null;
  }

  // Статические списки для остальных фильтров
  static const List<String> _bodyTypes = [
    'Седан',
    'Хэтчбек',
    'Внедорожник',
    'Кроссовер',
    'Универсал',
    'Купе',
    'Минивэн',
    'Пикап',
    'Кабриолет',
    'Лифтбек',
  ];
  static const List<String> _fuelTypes = [
    'Бензин',
    'Дизель',
    'Электро',
    'Гибрид',
    'Газ',
  ];
  static const List<String> _transmissions = [
    'МКПП',
    'АКПП',
    'Робот',
    'Вариатор',
  ];
  static const List<String> _driveTypes = ['Передний', 'Задний', 'Полный'];
  static const List<String> _origins = ['Новый', 'Б/У'];
}
