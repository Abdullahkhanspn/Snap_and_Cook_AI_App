import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import 'bioglow_badge.dart';
import 'allergy_warning_card.dart';
import '../core/constants/colors.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Future: Navigate to recipe details
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      BioGlowBadge(level: recipe.bioGlowLevel),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.restaurant_rounded, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Uses: ${recipe.ingredientsUsed.join(', ')}',
                          style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  if (recipe.healthTip != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              recipe.healthTip!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AllergyWarningCard(matchedAllergens: recipe.matchedAllergens),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Tap for Recipe →',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
