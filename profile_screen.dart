import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(preferencesProvider);
    _caloriesController =
        TextEditingController(text: prefs.targetCalories?.toString() ?? '');
    _proteinController = TextEditingController(
        text: prefs.targetProteinGrams?.toStringAsFixed(0) ?? '');
    _carbsController = TextEditingController(
        text: prefs.targetCarbsGrams?.toStringAsFixed(0) ?? '');
    _fatController = TextEditingController(
        text: prefs.targetFatGrams?.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ----- Dietary Restrictions -----
          _SectionHeader(
            icon: Icons.no_food_outlined,
            title: 'Dietary Restrictions',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DietaryRestriction.values.map((restriction) {
              final selected =
                  prefs.dietaryRestrictions.contains(restriction);
              return FilterChip(
                label: Text(restriction.label),
                selected: selected,
                onSelected: (value) {
                  final updated =
                      List<DietaryRestriction>.from(prefs.dietaryRestrictions);
                  if (value) {
                    updated.add(restriction);
                  } else {
                    updated.remove(restriction);
                  }
                  notifier.setDietaryRestrictions(updated);
                },
                selectedColor: AppTheme.primaryLight.withOpacity(0.3),
                checkmarkColor: AppTheme.primaryDark,
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // ----- Cuisine Preferences -----
          _SectionHeader(
            icon: Icons.public,
            title: 'Favorite Cuisines',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CuisineType.values.map((cuisine) {
              final selected = prefs.favoriteCuisines.contains(cuisine);
              return FilterChip(
                label: Text(cuisine.label),
                selected: selected,
                onSelected: (value) {
                  final updated =
                      List<CuisineType>.from(prefs.favoriteCuisines);
                  if (value) {
                    updated.add(cuisine);
                  } else {
                    updated.remove(cuisine);
                  }
                  notifier.setFavoriteCuisines(updated);
                },
                selectedColor: AppTheme.primaryLight.withOpacity(0.3),
                checkmarkColor: AppTheme.primaryDark,
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // ----- Spice Level -----
          _SectionHeader(
            icon: Icons.whatshot,
            title: 'Spice Level',
          ),
          const SizedBox(height: 10),
          _SpiceLevelSelector(
            current: prefs.spiceLevel,
            onChanged: (level) => notifier.setSpiceLevel(level),
          ),

          const SizedBox(height: 28),

          // ----- Servings -----
          _SectionHeader(
            icon: Icons.people_outline,
            title: 'Default Servings',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: prefs.servings > 1
                    ? () => notifier.setServings(prefs.servings - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppTheme.primary,
              ),
              Container(
                width: 48,
                alignment: Alignment.center,
                child: Text(
                  '${prefs.servings}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: prefs.servings < 12
                    ? () => notifier.setServings(prefs.servings + 1)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'people',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ----- Calorie & Macro Targets -----
          _SectionHeader(
            icon: Icons.track_changes,
            title: 'Nutrition Targets (per serving)',
          ),
          const SizedBox(height: 4),
          const Text(
            'Leave blank if you don\'t have a target',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),

          _NumericField(
            controller: _caloriesController,
            label: 'Calories (kcal)',
            onChanged: (val) => notifier.setCalorieTarget(
              val.isEmpty ? null : int.tryParse(val),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NumericField(
                  controller: _proteinController,
                  label: 'Protein (g)',
                  onChanged: (val) => notifier.setMacros(
                    protein: val.isEmpty ? null : double.tryParse(val),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumericField(
                  controller: _carbsController,
                  label: 'Carbs (g)',
                  onChanged: (val) => notifier.setMacros(
                    carbs: val.isEmpty ? null : double.tryParse(val),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumericField(
                  controller: _fatController,
                  label: 'Fat (g)',
                  onChanged: (val) => notifier.setMacros(
                    fat: val.isEmpty ? null : double.tryParse(val),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SpiceLevelSelector extends StatelessWidget {
  final SpiceLevel current;
  final ValueChanged<SpiceLevel> onChanged;

  const _SpiceLevelSelector({
    required this.current,
    required this.onChanged,
  });

  static const _emojis = ['🚫', '🌶️', '🌶️🌶️', '🔥', '🔥🔥'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(SpiceLevel.values.length, (index) {
        final level = SpiceLevel.values[index];
        final isSelected = current == level;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(level),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(0.12)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(_emojis[index], style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(
                    level.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _NumericField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  const _NumericField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }
}
