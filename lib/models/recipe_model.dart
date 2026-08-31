enum BioGlowLevel { green, yellow, red }

class RecipeModel {
  final String name;
  final List<String> ingredientsUsed;
  final List<String> matchedAllergens;
  final BioGlowLevel bioGlowLevel;
  final String? healthTip;

  RecipeModel({
    required this.name,
    required this.ingredientsUsed,
    required this.matchedAllergens,
    required this.bioGlowLevel,
    this.healthTip,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      name: json['name'] ?? '',
      ingredientsUsed: List<String>.from(json['ingredientsUsed'] ?? []),
      matchedAllergens: List<String>.from(json['matchedAllergens'] ?? []),
      bioGlowLevel: BioGlowLevel.values.firstWhere(
        (e) => e.name == json['bioGlowLevel'],
        orElse: () => BioGlowLevel.yellow,
      ),
      healthTip: json['healthTip'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ingredientsUsed': ingredientsUsed,
      'matchedAllergens': matchedAllergens,
      'bioGlowLevel': bioGlowLevel.name,
      'healthTip': healthTip,
    };
  }
}
