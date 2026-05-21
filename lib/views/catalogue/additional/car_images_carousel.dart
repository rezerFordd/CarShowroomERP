import 'package:flutter/material.dart';
import 'package:car_showroom/services/car/car_images_service.dart';
import 'package:car_showroom/models/car/car_image.dart';

class CarImagesCarousel extends StatefulWidget {
  final int carId;

  const CarImagesCarousel({super.key, required this.carId});

  @override
  State<CarImagesCarousel> createState() => _CarImagesCarouselState();
}

class _CarImagesCarouselState extends State<CarImagesCarousel> {
  final CarImagesService _service = CarImagesService();
  late Future<List<CarImage>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _imagesFuture = _service.getCarImages(widget.carId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CarImage>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text('Нет фото', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          );
        }
        final images = snapshot.data!;
        return SizedBox(
          height: 250,
          child: PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              final url = CarImagesService.getImageUrl(image.imagePath);
              return GestureDetector(
                onTap: () {
                  // Можно добавить просмотр в полный экран
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 50);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
