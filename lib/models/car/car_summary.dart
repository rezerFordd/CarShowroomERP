class CarSummary {
  final int carId;
  final int? brandId;
  final int? modelId;
  final int? generationId;
  final int? cityId;
  final String? description;
  final int year;
  final int price;
  final int? mileageKm;
  final String? vin;
  final String? licensePlate;
  final int? ownersCount;
  final String? bodyType;
  final double? engineVolume;
  final int? engineHp;
  final String? fuelType;
  final String? transmission;
  final String? driveType;
  final String? color;
  final int? seats;
  final String? status;
  final String? origin;
  final String? writeoffReason;
  final DateTime? writeoffDate;
  final bool isPublished;
  final String brandName;
  final String modelName;
  final String? generationName;
  final String? cityName;

  CarSummary({
    required this.carId,
    this.brandId,
    this.modelId,
    this.generationId,
    this.cityId,
    this.description,
    required this.year,
    required this.price,
    this.mileageKm,
    this.vin,
    this.licensePlate,
    this.ownersCount,
    this.bodyType,
    this.engineVolume,
    this.engineHp,
    this.fuelType,
    this.transmission,
    this.driveType,
    this.color,
    this.seats,
    this.status,
    this.origin,
    this.writeoffReason,
    this.writeoffDate,
    required this.isPublished,
    required this.brandName,
    required this.modelName,
    this.generationName,
    this.cityName,
  });

  factory CarSummary.fromJson(Map<String, dynamic> json) {
    return CarSummary(
      carId: json['car_id'] as int,
      brandId: json['brand_id'] as int?,
      modelId: json['model_id'] as int?,
      generationId: json['generation_id'] as int?,
      cityId: json['city_id'] as int?,
      description: json['description'] as String?,
      year: json['year'] as int,
      price: json['price'] as int,
      mileageKm: json['mileage_km'] as int?,
      vin: json['vin'] as String?,
      licensePlate: json['license_plate'] as String?,
      ownersCount: json['owners_count'] as int?,
      bodyType: json['body_type'] as String?,
      engineVolume: (json['engine_volume'] as num?)?.toDouble(),
      engineHp: json['engine_hp'] as int?,
      fuelType: json['fuel_type'] as String?,
      transmission: json['transmission'] as String?,
      driveType: json['drive_type'] as String?,
      color: json['color'] as String?,
      seats: json['seats'] as int?,
      status: json['status'] as String?,
      origin: json['origin'] as String?,
      writeoffReason: json['writeoff_reason'] as String?,
      writeoffDate: json['writeoff_date'] != null
          ? DateTime.parse(json['writeoff_date'])
          : null,
      isPublished: json['is_published'] as bool,
      brandName: json['brand_name'] as String,
      modelName: json['model_name'] as String,
      generationName: json['generation_name'] as String?,
      cityName: json['city_name'] as String?,
    );
  }
}
