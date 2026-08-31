import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/ingredient_model.dart';
import '../../models/recipe_model.dart';
import '../../models/user_profile_model.dart';

abstract class AiService {
  Future<List<IngredientModel>> recognizeIngredients(File image);
  Future<List<RecipeModel>> getRecipeRecommendations({
    required List<String> ingredients,
    required List<String> userAllergies,
    required DietaryPreference dietPreference,
  });
}

class GeminiAiService implements AiService {
  final GenerativeModel _model;
  final GenerativeModel _visionModel;

  GeminiAiService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
        ),
        _visionModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
        );

  @override
  Future<List<IngredientModel>> recognizeIngredients(File image) async {
    try {
      final imageBytes = await image.readAsBytes();
      final content = [
        Content.multi([
          TextPart('List all food ingredients you see in this image. Return the result as a JSON list of objects with "name" and "confidence" fields. Only return the JSON list, no markdown formatting.'),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      final text = response.text;
      if (text == null) return [];

      final cleanedText = _cleanJson(text);
      final List<dynamic> decoded = jsonDecode(cleanedText);
      return decoded.map((e) => IngredientModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error recognizing ingredients: \$e');
      return [];
    }
  }

  @override
  Future<List<RecipeModel>> getRecipeRecommendations({
    required List<String> ingredients,
    required List<String> userAllergies,
    required DietaryPreference dietPreference,
  }) async {
    try {
      final prompt = '''
        Given these ingredients: \${ingredients.join(', ')}.
        User has these allergies: \${userAllergies.join(', ')}.
        Dietary preference: \${dietPreference.name}.
        
        Recommend 3 creative and healthy recipes for kids. For each recipe, provide:
        - name
        - ingredientsUsed (list of strings)
        - matchedAllergens (list of strings that match user's allergies)
        - bioGlowLevel (must be one of: green, yellow, red)
        - healthTip (short, fun health tip for kids)
        
        Return the result as a JSON list of objects. Only return the JSON list, no markdown formatting.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) return [];

      final cleanedText = _cleanJson(text);
      final List<dynamic> decoded = jsonDecode(cleanedText);
      return decoded.map((e) => RecipeModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error getting recipes: \$e');
      return [];
    }
  }

  String _cleanJson(String text) {
    String cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      final lines = cleaned.split('\n');
      if (lines.first.startsWith('```')) lines.removeAt(0);
      if (lines.last.startsWith('```')) lines.removeLast();
      cleaned = lines.join('\n').trim();
    }
    return cleaned;
  }
}

class MockAiService implements AiService {
  @override
  Future<List<IngredientModel>> recognizeIngredients(File image) async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      IngredientModel(name: 'Tomato', confidence: 0.98),
      IngredientModel(name: 'Onion', confidence: 0.95),
      IngredientModel(name: 'Bread', confidence: 0.92),
      IngredientModel(name: 'Cheese', confidence: 0.88),
      IngredientModel(name: 'Egg', confidence: 0.85),
    ];
  }

  @override
  Future<List<RecipeModel>> getRecipeRecommendations({
    required List<String> ingredients,
    required List<String> userAllergies,
    required DietaryPreference dietPreference,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final allRecipes = [
      RecipeModel(
        name: 'Cheese Omelette',
        ingredientsUsed: ['Egg', 'Cheese', 'Onion'],
        matchedAllergens: userAllergies.contains('Eggs') || userAllergies.contains('Milk') ? ['Eggs/Milk'] : [],
        bioGlowLevel: BioGlowLevel.yellow,
        healthTip: 'Add some spinach for extra nutrients.',
      ),
      RecipeModel(
        name: 'Tomato Sandwich',
        ingredientsUsed: ['Bread', 'Tomato', 'Cheese'],
        matchedAllergens: userAllergies.contains('Gluten') || userAllergies.contains('Milk') ? ['Gluten/Milk'] : [],
        bioGlowLevel: BioGlowLevel.green,
      ),
      RecipeModel(
        name: 'Fried Bread with Egg',
        ingredientsUsed: ['Bread', 'Egg'],
        matchedAllergens: userAllergies.contains('Gluten') || userAllergies.contains('Eggs') ? ['Gluten/Eggs'] : [],
        bioGlowLevel: BioGlowLevel.red,
        healthTip: 'Limit fried foods for better heart health.',
      ),
    ];

    return allRecipes.where((recipe) {
      if (dietPreference == DietaryPreference.vegan) {
        return !recipe.ingredientsUsed.contains('Egg') && !recipe.ingredientsUsed.contains('Cheese');
      }
      if (dietPreference == DietaryPreference.vegetarian) {
        return !recipe.ingredientsUsed.contains('Meat') && !recipe.ingredientsUsed.contains('Chicken');
      }
      return true;
    }).toList();
  }
}
