import 'package:flutter/material.dart';
import '../../features/recipes/screens/recipe_details_screen.dart';

class RecipeCard extends StatelessWidget {
  final String title;
  final String cookTime;
  final String matchPercentage;
  final String imageUrl;

  const RecipeCard({
    super.key,
    required this.title,
    required this.cookTime,
    required this.matchPercentage,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      clipBehavior: Clip.antiAlias, // This clips the InkWell ripple to the card corners
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to the Details Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailsScreen(title: title),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE SECTION ---
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                  ),
                  child: imageUrl.isEmpty
                      ? Icon(
                          Icons.restaurant, 
                          size: 50, 
                          color: colorScheme.primary.withOpacity(0.3),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.broken_image),
                        ),
                ),
                // "Match" Percent Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$matchPercentage Match",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- TEXT & INFO SECTION ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Time Icon
                      Icon(Icons.access_time, size: 18, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        cookTime,
                        style: TextStyle(color: theme.hintColor),
                      ),
                      const SizedBox(width: 20),
                      // Difficulty Icon
                      Icon(Icons.bolt, size: 18, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        "Easy",
                        style: TextStyle(color: theme.hintColor),
                      ),
                      const Spacer(),
                      // Subtle "View" indicator
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}