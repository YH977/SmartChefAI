/// Dietary restriction options.
enum DietaryRestriction {
  vegetarian('Vegetarian'),
  vegan('Vegan'),
  glutenFree('Gluten-Free'),
  dairyFree('Dairy-Free'),
  nutFree('Nut-Free'),
  halal('Halal'),
  kosher('Kosher'),
  keto('Keto'),
  paleo('Paleo'),
  lowSodium('Low Sodium');

  final String label;
  const DietaryRestriction(this.label);
}

/// Cuisine preference options.
enum CuisineType {
  italian('Italian'),
  mexican('Mexican'),
  chinese('Chinese'),
  japanese('Japanese'),
  indian('Indian'),
  thai('Thai'),
  mediterranean('Mediterranean'),
  middleEastern('Middle Eastern'),
  korean('Korean'),
  french('French'),
  american('American'),
  ethiopian('Ethiopian'),
  brazilian('Brazilian'),
  turkish('Turkish'),
  vietnamese('Vietnamese');

  final String label;
  const CuisineType(this.label);
}

/// Spice tolerance level.
enum SpiceLevel {
  none('No Spice'),
  mild('Mild'),
  medium('Medium'),
  hot('Hot'),
  extraHot('Extra Hot');

  final String label;
  const SpiceLevel(this.label);
}

/// User preferences for recipe recommendations.
class UserPreferences {
  final List<DietaryRestriction> dietaryRestrictions;
  final List<CuisineType> favoriteCuisines;
  final SpiceLevel spiceLevel;
  final int? targetCalories; // daily target
  final double? targetProteinGrams;
  final double? targetCarbsGrams;
  final double? targetFatGrams;
  final int servings;

  const UserPreferences({
    this.dietaryRestrictions = const [],
    this.favoriteCuisines = const [],
    this.spiceLevel = SpiceLevel.medium,
    this.targetCalories,
    this.targetProteinGrams,
    this.targetCarbsGrams,
    this.targetFatGrams,
    this.servings = 2,
  });

  UserPreferences copyWith({
    List<DietaryRestriction>? dietaryRestrictions,
    List<CuisineType>? favoriteCuisines,
    SpiceLevel? spiceLevel,
    int? targetCalories,
    double? targetProteinGrams,
    double? targetCarbsGrams,
    double? targetFatGrams,
    int? servings,
  }) {
    return UserPreferences(
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      favoriteCuisines: favoriteCuisines ?? this.favoriteCuisines,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProteinGrams: targetProteinGrams ?? this.targetProteinGrams,
      targetCarbsGrams: targetCarbsGrams ?? this.targetCarbsGrams,
      targetFatGrams: targetFatGrams ?? this.targetFatGrams,
      servings: servings ?? this.servings,
    );
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      dietaryRestrictions: (json['dietaryRestrictions'] as List<dynamic>?)
              ?.map((e) => DietaryRestriction.values[e as int])
              .toList() ??
          [],
      favoriteCuisines: (json['favoriteCuisines'] as List<dynamic>?)
              ?.map((e) => CuisineType.values[e as int])
              .toList() ??
          [],
      spiceLevel: SpiceLevel.values[json['spiceLevel'] as int? ?? 2],
      targetCalories: json['targetCalories'] as int?,
      targetProteinGrams: (json['targetProteinGrams'] as num?)?.toDouble(),
      targetCarbsGrams: (json['targetCarbsGrams'] as num?)?.toDouble(),
      targetFatGrams: (json['targetFatGrams'] as num?)?.toDouble(),
      servings: json['servings'] as int? ?? 2,
    );
  }

  Map<String, dynamic> toJson() => {
        'dietaryRestrictions':
            dietaryRestrictions.map((e) => e.index).toList(),
        'favoriteCuisines': favoriteCuisines.map((e) => e.index).toList(),
        'spiceLevel': spiceLevel.index,
        'targetCalories': targetCalories,
        'targetProteinGrams': targetProteinGrams,
        'targetCarbsGrams': targetCarbsGrams,
        'targetFatGrams': targetFatGrams,
        'servings': servings,
      };

  /// Build a natural language description for the LLM prompt.
  String toPromptDescription() {
    final parts = <String>[];

    if (dietaryRestrictions.isNotEmpty) {
      parts.add(
          'Dietary restrictions: ${dietaryRestrictions.map((d) => d.label).join(', ')}.');
    }
    if (favoriteCuisines.isNotEmpty) {
      parts.add(
          'Preferred cuisines: ${favoriteCuisines.map((c) => c.label).join(', ')}.');
    }
    parts.add('Spice level: ${spiceLevel.label}.');

    if (targetCalories != null) {
      parts.add('Target calories per serving: ~$targetCalories kcal.');
    }
    if (targetProteinGrams != null) {
      parts.add('Target protein: ~${targetProteinGrams!.toStringAsFixed(0)}g.');
    }
    if (targetCarbsGrams != null) {
      parts.add('Target carbs: ~${targetCarbsGrams!.toStringAsFixed(0)}g.');
    }
    if (targetFatGrams != null) {
      parts.add('Target fat: ~${targetFatGrams!.toStringAsFixed(0)}g.');
    }
    parts.add('Servings: $servings.');

    return parts.join(' ');
  }
}
