import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class AllergyWarningCard extends StatelessWidget {
  final List<String> matchedAllergens;

  const AllergyWarningCard({super.key, required this.matchedAllergens});

  @override
  Widget build(BuildContext context) {
    if (matchedAllergens.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Text(
              'Safe to Consume',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Warning: Allergy Risk',
                  style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Contains: ${matchedAllergens.join(', ')}',
                  style: const TextStyle(color: AppColors.accent, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
