import 'ingredient.dart';

/// Nutritional information per serving.
class NutritionInfo {
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double? fiberGrams;
  final double? sugarGrams;
  final double? sodiumMg;

  const NutritionInfo({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.fiberGrams,
    this.sugarGrams,
    this.sodiumMg,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories'] as int,
      proteinGrams: (json['proteinGrams'] as num).toDouble(),
      carbsGrams: (json['carbsGrams'] as num).toDouble(),
      fatGrams: (json['fatGrams'] as num).toDouble(),
      fiberGrams: (json['fiberGrams'] as num?)?.toDouble(),
      sugarGrams: (json['sugarGrams'] as num?)?.toDouble(),
      sodiumMg: (json['sodiumMg'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        if (fiberGrams != null) 'fiberGrams': fiberGrams,
        if (sugarGrams != null) 'sugarGrams': sugarGrams,
        if (sodiumMg != null) 'sodiumMg': sodiumMg,
      };
}

/// A single step in the recipe.
class RecipeStep {
  final int stepNumber;
  final String instruction;
  final int? durationMinutes;

  const RecipeStep({
    required this.stepNumber,
    required this.instruction,
    this.durationMinutes,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      stepNumber: json['stepNumber'] as int,
      instruction: json['instruction'] as String,
      durationMinutes: json['durationMinutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'stepNumber': stepNumber,
        'instruction': instruction,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
      };
}

/// Full recipe model.
class Recipe {
  final String id;
  final String name;
  final String description;
  final String cuisine;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty; // Easy, Medium, Hard
  final double matchPercentage; // how well it matches user's ingredients
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final NutritionInfo nutrition;
  final List<String> tags; // e.g. ["quick", "high-protein", "comfort food"]
  final List<String> missingIngredients; // ingredients user doesn't have
  final String? imageUrl;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.cuisine,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.matchPercentage,
    required this.ingredients,
    required this.steps,
    required this.nutrition,
    this.tags = const [],
    this.missingIngredients = const [],
    this.imageUrl,
  });

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String,
      cuisine: json['cuisine'] as String,
      prepTimeMinutes: json['prepTimeMinutes'] as int,
      cookTimeMinutes: json['cookTimeMinutes'] as int,
      servings: json['servings'] as int,
      difficulty: json['difficulty'] as String,
      matchPercentage: (json['matchPercentage'] as num).toDouble(),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      nutrition:
          NutritionInfo.fromJson(json['nutrition'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      missingIngredients: (json['missingIngredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'cuisine': cuisine,
        'prepTimeMinutes': prepTimeMinutes,
        'cookTimeMinutes': cookTimeMinutes,
        'servings': servings,
        'difficulty': difficulty,
        'matchPercentage': matchPercentage,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'steps': steps.map((e) => e.toJson()).toList(),
        'nutrition': nutrition.toJson(),
        'tags': tags,
        'missingIngredients': missingIngredients,
        'imageUrl': imageUrl,
      };
}
