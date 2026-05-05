import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).any((r) => r.id == recipe.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary,
                      AppTheme.primaryDark,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.restaurant, size: 56, color: Colors.white70),
                      const SizedBox(height: 8),
                      Text(
                        recipe.cuisine,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppTheme.error : Colors.white,
                ),
                onPressed: () {
                  ref.read(favoritesProvider.notifier).toggle(recipe);
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    recipe.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick info row
                  _QuickInfoRow(recipe: recipe),
                  const SizedBox(height: 24),

                  // Match & tags
                  _MatchBadge(matchPercentage: recipe.matchPercentage),
                  if (recipe.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: recipe.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 28),

                  // Nutrition card
                  _SectionTitle('Nutrition per Serving'),
                  const SizedBox(height: 12),
                  _NutritionCard(nutrition: recipe.nutrition),
                  const SizedBox(height: 28),

                  // Ingredients
                  _SectionTitle('Ingredients'),
                  const SizedBox(height: 12),
                  _IngredientsList(
                    ingredients: recipe.ingredients,
                    missingIngredients: recipe.missingIngredients,
                  ),
                  const SizedBox(height: 28),

                  // Missing ingredients warning
                  if (recipe.missingIngredients.isNotEmpty) ...[
                    _MissingIngredientsCard(
                      missing: recipe.missingIngredients,
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Steps
                  _SectionTitle('Steps'),
                  const SizedBox(height: 12),
                  _StepsList(steps: recipe.steps),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _QuickInfoRow extends StatelessWidget {
  final Recipe recipe;
  const _QuickInfoRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.accentLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoChip(
            icon: Icons.timer_outlined,
            label: '${recipe.prepTimeMinutes}m prep',
          ),
          _InfoChip(
            icon: Icons.local_fire_department_outlined,
            label: '${recipe.cookTimeMinutes}m cook',
          ),
          _InfoChip(
            icon: Icons.people_outline,
            label: '${recipe.servings} servings',
          ),
          _InfoChip(
            icon: Icons.signal_cellular_alt,
            label: recipe.difficulty,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: AppTheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MatchBadge extends StatelessWidget {
  final double matchPercentage;
  const _MatchBadge({required this.matchPercentage});

  @override
  Widget build(BuildContext context) {
    final color = matchPercentage >= 80
        ? AppTheme.primary
        : matchPercentage >= 50
            ? AppTheme.accent
            : AppTheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            '${matchPercentage.toStringAsFixed(0)}% ingredient match',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final NutritionInfo nutrition;
  const _NutritionCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calories headline
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department,
                  color: AppTheme.accent, size: 28),
              const SizedBox(width: 8),
              Text(
                '${nutrition.calories} kcal',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Macros row
          Row(
            children: [
              _MacroTile(
                  label: 'Protein',
                  value: '${nutrition.proteinGrams.toStringAsFixed(0)}g',
                  color: const Color(0xFF5E8B7E)),
              _MacroTile(
                  label: 'Carbs',
                  value: '${nutrition.carbsGrams.toStringAsFixed(0)}g',
                  color: const Color(0xFFD4A373)),
              _MacroTile(
                  label: 'Fat',
                  value: '${nutrition.fatGrams.toStringAsFixed(0)}g',
                  color: const Color(0xFFBC4749)),
            ],
          ),
          if (nutrition.fiberGrams != null || nutrition.sodiumMg != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (nutrition.fiberGrams != null)
                  Text('Fiber: ${nutrition.fiberGrams!.toStringAsFixed(0)}g',
                      style: _microStyle),
                if (nutrition.sugarGrams != null)
                  Text('Sugar: ${nutrition.sugarGrams!.toStringAsFixed(0)}g',
                      style: _microStyle),
                if (nutrition.sodiumMg != null)
                  Text(
                      'Sodium: ${nutrition.sodiumMg!.toStringAsFixed(0)}mg',
                      style: _microStyle),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static const _microStyle = TextStyle(
    fontSize: 12,
    color: AppTheme.textSecondary,
    fontWeight: FontWeight.w500,
  );
}

class _MacroTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _IngredientsList extends StatelessWidget {
  final List<Ingredient> ingredients;
  final List<String> missingIngredients;

  const _IngredientsList({
    required this.ingredients,
    required this.missingIngredients,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ingredients.map((ingredient) {
        final isMissing = missingIngredients
            .any((m) => m.toLowerCase() == ingredient.name.toLowerCase());
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                isMissing
                    ? Icons.shopping_cart_outlined
                    : Icons.check_circle_outline,
                size: 20,
                color: isMissing ? AppTheme.accent : AppTheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ingredient.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: isMissing
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                    fontStyle:
                        isMissing ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MissingIngredientsCard extends StatelessWidget {
  final List<String> missing;
  const _MissingIngredientsCard({required this.missing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shopping_bag_outlined,
                  size: 20, color: AppTheme.accent),
              SizedBox(width: 8),
              Text(
                'Shopping List',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll need to pick up: ${missing.join(', ')}',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsList extends StatelessWidget {
  final List<RecipeStep> steps;
  const _StepsList({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.map((step) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step number circle
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.instruction,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (step.durationMinutes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '⏱ ~${step.durationMinutes} min',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
