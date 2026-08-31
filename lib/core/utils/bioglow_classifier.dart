import '../../models/recipe_model.dart';

class BioGlowClassifier {
  static BioGlowLevel classify(String name, List<String> ingredients) {
    final combined = '$name ${ingredients.join(' ')}'.toLowerCase();

    final greenKeywords = ['salad', 'soup', 'steamed', 'grilled', 'boiled', 'fruit', 'vegetable bowl', 'sprouts', 'healthy'];
    final redKeywords = ['burger', 'fries', 'fried', 'fast food', 'dessert', 'cake', 'sugary', 'soda', 'deep fried'];
    final yellowKeywords = ['pizza', 'paratha', 'pasta', 'sandwich', 'rice bowl', 'wrap', 'omelette'];

    for (var kw in redKeywords) {
      if (combined.contains(kw)) return BioGlowLevel.red;
    }
    
    for (var kw in greenKeywords) {
      if (combined.contains(kw)) return BioGlowLevel.green;
    }

    for (var kw in yellowKeywords) {
      if (combined.contains(kw)) return BioGlowLevel.yellow;
    }

    return BioGlowLevel.yellow; // Default
  }
}
