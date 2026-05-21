class Generation {
  final int generationId;
  final int modelId;
  final String name;
  final int? yearStart;
  final int? yearEnd;

  Generation({
    required this.generationId,
    required this.modelId,
    required this.name,
    this.yearStart,
    this.yearEnd,
  });

  factory Generation.fromJson(Map<String, dynamic> json) {
    return Generation(
      generationId: json['generation_id'] as int,
      modelId: json['model_id'] as int,
      name: json['name'] as String,
      yearStart: json['year_start'] as int?,
      yearEnd: json['year_end'] as int?,
    );
  }
}
