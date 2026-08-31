import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ingredient_model.dart';
import '../../models/recipe_model.dart';
import '../../models/user_profile_model.dart';
import '../../providers/profile_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../../core/services/ai_service.dart';
import '../../widgets/recipe_card.dart';
import '../../core/constants/colors.dart';

final aiServiceProvider = Provider<AiService>((ref) => GeminiAiService());

final scanResultsProvider = StateNotifierProvider.autoDispose<ScanResultsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final image = ref.watch(selectedImageProvider);
  final aiService = ref.read(aiServiceProvider);
  final profile = ref.read(userProfileProvider).value;
  return ScanResultsNotifier(aiService, image, profile);
});

class ScanResultsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final AiService _aiService;
  final File? _image;
  final UserProfileModel? _profile;

  ScanResultsNotifier(this._aiService, this._image, this._profile) : super(const AsyncValue.loading()) {
    if (_image != null && _profile != null) {
      runInitialScan();
    } else {
      state = AsyncValue.error('Missing image or profile', StackTrace.current);
    }
  }

  Future<void> runInitialScan() async {
    state = const AsyncValue.loading();
    try {
      final ingredients = await _aiService.recognizeIngredients(_image!);
      final recipes = await _aiService.getRecipeRecommendations(
        ingredients: ingredients.map((e) => e.name).toList(),
        userAllergies: _profile!.allergies,
        dietPreference: _profile!.dietaryPreference,
      );
      state = AsyncValue.data({'ingredients': ingredients, 'recipes': recipes});
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateIngredients(List<String> ingredientNames) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = const AsyncValue.loading();
    try {
      final recipes = await _aiService.getRecipeRecommendations(
        ingredients: ingredientNames,
        userAllergies: _profile!.allergies,
        dietPreference: _profile!.dietaryPreference,
      );
      
      final updatedIngredients = ingredientNames.map((name) => IngredientModel(name: name)).toList();
      state = AsyncValue.data({'ingredients': updatedIngredients, 'recipes': recipes});
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class AiResultScreen extends ConsumerWidget {
  const AiResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(scanResultsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chef\'s Magic Analysis'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => ref.read(scanResultsProvider.notifier).runInitialScan(),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: resultsAsync.when(
          data: (data) {
            final ingredients = data['ingredients'] as List<IngredientModel>;
            final recipes = data['recipes'] as List<RecipeModel>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader('Look what we found! 🥕'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ingredients.map((ing) {
                      return Chip(
                        label: Text(ing.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        side: const BorderSide(color: AppColors.primary, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        onDeleted: () {
                          final newNames = ingredients.where((e) => e != ing).map((e) => e.name).toList();
                          ref.read(scanResultsProvider.notifier).updateIngredients(newNames);
                        },
                        deleteIconColor: AppColors.accent,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  _buildHeader('Yummy Recipes for You! 🍳'),
                  const SizedBox(height: 16),
                  if (recipes.isEmpty)
                    _buildNoResults()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recipes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return RecipeCard(recipe: recipes[index]);
                      },
                    ),
                ],
              ),
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 32),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Text(
                        'Magic is happening...',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text('Cooking up some ideas!', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.accent),
                const SizedBox(height: 16),
                Text('Oops! $err'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => ref.read(scanResultsProvider.notifier).runInitialScan(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildNoResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'No recipes found yet. Try adding more ingredients!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
