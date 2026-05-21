import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_showroom/models/car/car_detail.dart';
import 'package:car_showroom/services/car/car_service.dart';
import 'package:car_showroom/providers/favorites_provider.dart';
import 'package:car_showroom/views/catalogue/additional/order_bottom_sheet.dart';

class CarDetailBottomSheet extends StatefulWidget {
  final int carId;
  final bool isFavorite;
  final Function(bool)
  onFavoriteChanged; // можно оставить для обратного вызова, но не обязательно

  const CarDetailBottomSheet({
    super.key,
    required this.carId,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  State<CarDetailBottomSheet> createState() => _CarDetailBottomSheetState();
}

class _CarDetailBottomSheetState extends State<CarDetailBottomSheet> {
  final CarService _carService = CarService();
  late Future<CarDetail> _carDetailFuture;

  // Простой кеш для деталей (на время сессии)
  static final Map<int, CarDetail> _cache = {};

  @override
  void initState() {
    super.initState();
    _carDetailFuture = _loadCarDetail();
  }

  Future<CarDetail> _loadCarDetail() async {
    if (_cache.containsKey(widget.carId)) {
      return _cache[widget.carId]!;
    }
    final detail = await _carService.getCarDetail(widget.carId);
    _cache[widget.carId] = detail;
    return detail;
  }

  Future<void> _toggleFavorite() async {
    final provider = context.read<FavoritesProvider>();
    final isFav = provider.isFavorite(widget.carId);
    bool success;
    if (isFav) {
      success = await provider.removeFavorite(widget.carId);
    } else {
      success = await provider.addFavorite(widget.carId);
    }
    if (success) {
      widget.onFavoriteChanged(!isFav);
      // Можно показать тост
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFav ? 'Удалено из избранного' : 'Добавлено в избранное',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка изменения избранного'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openOrderForm(CarDetail car) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OrderBottomSheet(car: car),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoritesProvider>();
    final isFavorite = provider.isFavorite(widget.carId);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return FutureBuilder<CarDetail>(
          future: _carDetailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Ошибка загрузки деталей'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _carDetailFuture = _loadCarDetail();
                        });
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }
            final car = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${car.brandName} ${car.modelName}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 32,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Год', car.year.toString()),
                        _buildInfoRow('Цена', '${car.price} ₽'),
                        if (car.generationName != null)
                          _buildInfoRow('Поколение', car.generationName!),
                        if (car.description != null)
                          _buildInfoRow('Описание', car.description!),
                        const Divider(),
                        const Text(
                          'Технические характеристики',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (car.engineVolume != null)
                          _buildInfoRow(
                            'Объём двигателя',
                            '${car.engineVolume} л',
                          ),
                        if (car.engineHp != null)
                          _buildInfoRow('Мощность', '${car.engineHp} л.с.'),
                        if (car.fuelType != null)
                          _buildInfoRow('Топливо', car.fuelType!),
                        if (car.transmission != null)
                          _buildInfoRow('Коробка передач', car.transmission!),
                        if (car.driveType != null)
                          _buildInfoRow('Привод', car.driveType!),
                        if (car.mileageKm != null)
                          _buildInfoRow('Пробег', '${car.mileageKm} км'),
                        if (car.color != null)
                          _buildInfoRow('Цвет', car.color!),
                        if (car.seats != null)
                          _buildInfoRow('Мест', car.seats.toString()),
                        const Divider(),
                        const Text(
                          'Юридическая информация',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (car.vin != null) _buildInfoRow('VIN', car.vin!),
                        if (car.licensePlate != null)
                          _buildInfoRow('Госномер', car.licensePlate!),
                        if (car.ownersCount != null)
                          _buildInfoRow(
                            'Кол-во владельцев',
                            car.ownersCount.toString(),
                          ),
                        if (car.status != null)
                          _buildInfoRow('Статус', car.status!),
                        if (car.origin != null)
                          _buildInfoRow('Состояние', car.origin!),
                        if (car.writeoffReason != null)
                          _buildInfoRow(
                            'Причина списания',
                            car.writeoffReason!,
                          ),
                        if (car.writeoffDate != null)
                          _buildInfoRow(
                            'Дата списания',
                            '${car.writeoffDate!.toLocal()}'.split(' ')[0],
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _openOrderForm(car),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            'Оформить заказ',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
