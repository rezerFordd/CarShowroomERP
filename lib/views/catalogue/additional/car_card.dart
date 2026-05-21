import 'package:flutter/material.dart';
import 'package:car_showroom/models/car/car_summary.dart';

class CarCard extends StatelessWidget {
  final CarSummary car;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const CarCard({
    super.key,
    required this.car,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${car.brandName} ${car.modelName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (car.generationName != null)
                          Text(
                            car.generationName!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: onFavoriteToggle,
                    tooltip: isFavorite
                        ? 'Удалить из избранного'
                        : 'В избранное',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text('${car.year} год'),
                    backgroundColor: Colors.blue.shade50,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('${car.price} ₽'),
                    backgroundColor: Colors.green.shade50,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  if (car.fuelType != null)
                    Chip(
                      label: Text(car.fuelType!),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (car.bodyType != null)
                    Chip(
                      label: Text(car.bodyType!),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (car.transmission != null)
                    Chip(
                      label: Text(car.transmission!),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
