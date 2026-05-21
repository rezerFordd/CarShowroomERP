class CarModel {
  final int modelId;
  final int brandId;
  final String name;

  CarModel({required this.modelId, required this.brandId, required this.name});

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      modelId: json['model_id'] as int,
      brandId: json['brand_id'] as int,
      name: json['name'] as String,
    );
  }
}
