class Brand {
  final int brandId;
  final String name;
  final String? logoPath;

  Brand({required this.brandId, required this.name, this.logoPath});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      brandId: json['brand_id'] as int,
      name: json['name'] as String,
      logoPath: json['logo_path'] as String?,
    );
  }
}
