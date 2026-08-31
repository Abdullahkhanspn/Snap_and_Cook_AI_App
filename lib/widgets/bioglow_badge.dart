import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../core/constants/colors.dart';

class BioGlowBadge extends StatelessWidget {
  final BioGlowLevel level;

  const BioGlowBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (level) {
      case BioGlowLevel.green:
        color = AppColors.primary;
        label = 'Healthy';
        break;
      case BioGlowLevel.yellow:
        color = AppColors.secondary;
        label = 'Moderate';
        break;
      case BioGlowLevel.red:
        color = AppColors.accent;
        label = 'Less Healthy';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
