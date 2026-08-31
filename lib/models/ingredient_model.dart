class IngredientModel {
  final String name;
  final double? confidence;

  IngredientModel({
    required this.name,
    this.confidence,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      name: json['name'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'confidence': confidence,
    };
  }
}
