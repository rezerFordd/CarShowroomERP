class CarFilters {
  final String? q;
  final int? brandId;
  final int? modelId;
  final int? generationId;
  final int? cityId;
  final int? priceFrom;
  final int? priceTo;
  final int? yearFrom;
  final int? yearTo;
  final String? bodyType;
  final String? fuelType;
  final String? transmission;
  final String? driveType;
  final String? origin;

  CarFilters({
    this.q,
    this.brandId,
    this.modelId,
    this.generationId,
    this.cityId,
    this.priceFrom,
    this.priceTo,
    this.yearFrom,
    this.yearTo,
    this.bodyType,
    this.fuelType,
    this.transmission,
    this.driveType,
    this.origin,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (q != null && q!.isNotEmpty) params['q'] = q;
    if (brandId != null) params['brand_id'] = brandId;
    if (modelId != null) params['model_id'] = modelId;
    if (generationId != null) params['generation_id'] = generationId;
    if (cityId != null) params['city_id'] = cityId;
    if (priceFrom != null) params['price_from'] = priceFrom;
    if (priceTo != null) params['price_to'] = priceTo;
    if (yearFrom != null) params['year_from'] = yearFrom;
    if (yearTo != null) params['year_to'] = yearTo;
    if (bodyType != null && bodyType!.isNotEmpty) {
      params['body_type'] = bodyType;
    }
    if (fuelType != null && fuelType!.isNotEmpty) {
      params['fuel_type'] = fuelType;
    }
    if (transmission != null && transmission!.isNotEmpty) {
      params['transmission'] = transmission;
    }
    if (driveType != null && driveType!.isNotEmpty) {
      params['drive_type'] = driveType;
    }
    if (origin != null && origin!.isNotEmpty) params['origin'] = origin;
    return params;
  }

  CarFilters copyWith({
    String? q,
    int? brandId,
    int? modelId,
    int? generationId,
    int? cityId,
    int? priceFrom,
    int? priceTo,
    int? yearFrom,
    int? yearTo,
    String? bodyType,
    String? fuelType,
    String? transmission,
    String? driveType,
    String? origin,
  }) {
    return CarFilters(
      q: q ?? this.q,
      brandId: brandId ?? this.brandId,
      modelId: modelId ?? this.modelId,
      generationId: generationId ?? this.generationId,
      cityId: cityId ?? this.cityId,
      priceFrom: priceFrom ?? this.priceFrom,
      priceTo: priceTo ?? this.priceTo,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: yearTo ?? this.yearTo,
      bodyType: bodyType ?? this.bodyType,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      driveType: driveType ?? this.driveType,
      origin: origin ?? this.origin,
    );
  }
}
