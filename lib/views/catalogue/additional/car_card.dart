import 'package:flutter/material.dart';
import 'package:car_showroom/models/car/car_summary.dart';
import 'package:car_showroom/models/car/car_image.dart';
import 'package:car_showroom/services/car/car_images_service.dart';

class CarCard extends StatefulWidget {
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
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
  final CarImagesService _imagesService = CarImagesService();
  Future<CarImage?>? _mainImageFuture;

  @override
  void initState() {
    super.initState();
    _mainImageFuture = _imagesService.getMainImage(widget.car.carId);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Фото автомобиля
              SizedBox(
                width: 100,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FutureBuilder<CarImage?>(
                    future: _mainImageFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData && snapshot.data != null) {
                        final imageUrl = CarImagesService.getImageUrl(
                          snapshot.data!.imagePath,
                        );
                        return Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 40);
                          },
                        );
                      } else {
                        return const Icon(
                          Icons.directions_car,
                          size: 50,
                          color: Colors.grey,
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.car.brandName} ${widget.car.modelName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: widget.onFavoriteToggle,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    if (widget.car.generationName != null)
                      Text(
                        widget.car.generationName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text('${widget.car.year} год'),
                          backgroundColor: Colors.blue.shade50,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 4),
                        Chip(
                          label: Text('${widget.car.price} ₽'),
                          backgroundColor: Colors.green.shade50,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        if (widget.car.fuelType != null)
                          Chip(
                            label: Text(widget.car.fuelType!),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (widget.car.bodyType != null)
                          Chip(
                            label: Text(widget.car.bodyType!),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (widget.car.transmission != null)
                          Chip(
                            label: Text(widget.car.transmission!),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
