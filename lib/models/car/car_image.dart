class CarImage {
  final int imageId;
  final int carId;
  final String imagePath;
  final bool isMain;
  final int sortOrder;

  CarImage({
    required this.imageId,
    required this.carId,
    required this.imagePath,
    required this.isMain,
    required this.sortOrder,
  });

  factory CarImage.fromJson(Map<String, dynamic> json) {
    return CarImage(
      imageId: json['image_id'] as int,
      carId: json['car_id'] as int,
      imagePath: json['image_path'] as String,
      isMain: json['is_main'] as bool,
      sortOrder: json['sort_order'] as int,
    );
  }
}