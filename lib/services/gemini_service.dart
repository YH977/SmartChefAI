import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

/// Service that handles all Gemini AI interactions:
/// - Image-based ingredient detection
/// - Recipe generation from ingredients + preferences
class GeminiService {
  late final GenerativeModel _textModel;
  late final GenerativeModel _visionModel;
  final _uuid = const Uuid();

  GeminiService({required String apiKey}) {
    _textModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.9,
        maxOutputTokens: 8192,
      ),
    );

    _visionModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        maxOutputTokens: 2048,
      ),
    );
  }

  /// Strips markdown fences, thinking blocks, and any non-JSON preamble
  /// so that jsonDecode never chokes on wrapped responses.
  String _cleanJson(String raw) {
    var text = raw.trim();

    // Remove ```json ... ``` or ``` ... ```
    text = text.replaceAll(RegExp(r'```json\s*', multiLine: true), '');
    text = text.replaceAll(RegExp(r'```\s*', multiLine: true), '');
    text = text.trim();

    // Find the outermost JSON object { ... }
    final start = text.indexOf('{');
    if (start == -1) {
      print('[GeminiService] No JSON object found in response: '
          '${text.substring(0, text.length > 200 ? 200 : text.length)}');
      return text;
    }

    // Walk forward from the first '{', tracking depth while respecting strings
    int depth = 0;
    bool inString = false;
    bool escaped = false;
    int end = start;

    for (int i = start; i < text.length; i++) {
      final c = text[i];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (c == r'\' && inString) {
        escaped = true;
        continue;
      }

      if (c == '"') {
        inString = !inString;
        continue;
      }

      if (!inString) {
        if (c == '{') depth++;
        if (c == '}') {
          depth--;
          if (depth == 0) {
            end = i;
            break;
          }
        }
      }
    }

    final result = text.substring(start, end + 1);
    print('[GeminiService] Cleaned JSON length: ${result.length}');
    return result;
  }

  // ---------------------------------------------------------------------------
  // Ingredient detection from image
  // ---------------------------------------------------------------------------

  /// Detect ingredients from a photo using Gemini Vision.
  /// Returns a list of identified ingredient names.
  Future<List<String>> detectIngredientsFromImage(Uint8List imageBytes) async {
    final prompt = TextPart('''
Analyze this image and identify all visible food ingredients.
Return a JSON object with a single key "ingredients" containing an array of strings.
Only include actual food ingredients, not packaging, utensils, or surfaces.
Be specific (e.g., "red bell pepper" not just "pepper").

Example response:
{"ingredients": ["chicken breast", "garlic", "olive oil", "red bell pepper", "onion"]}
''');

    final imagePart = DataPart('image/jpeg', imageBytes);

    final response = await _visionModel.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('No response from Gemini Vision');
    }

    final parsed = jsonDecode(_cleanJson(text)) as Map<String, dynamic>;
    final ingredients = (parsed['ingredients'] as List<dynamic>)
        .map((e) => e as String)
        .toList();

    return ingredients;
  }

  // ---------------------------------------------------------------------------
  // Recipe recommendation
  // ---------------------------------------------------------------------------

  /// Generate recipe recommendations based on available ingredients
  /// and user preferences.
  Future<List<Recipe>> getRecipeRecommendations({
    required List<String> ingredients,
    required UserPreferences preferences,
    int count = 3,
  }) async {
    final prefsDescription = preferences.toPromptDescription();
    final ingredientList = ingredients.join(', ');

    final prompt = '''
You are a professional chef and nutritionist. Based on the available ingredients and user preferences, recommend exactly $count recipes.

AVAILABLE INGREDIENTS:
$ingredientList

USER PREFERENCES:
$prefsDescription

RULES:
- Prioritize recipes that use as many of the available ingredients as possible.
- Respect ALL dietary restrictions strictly.
- Match the preferred cuisines when possible, but suggest other cuisines if they fit better.
- Match the spice level preference.
- If calorie/macro targets are provided, try to stay within ±15% of those targets per serving.
- Calculate a matchPercentage (0-100) based on how many of the recipe's required ingredients the user already has.
- List any missing ingredients the user would need to buy.

Return a JSON object with a single key "recipes" containing an array of recipe objects.
Each recipe object must have EXACTLY this structure:
{
  "name": "Recipe Name",
  "description": "A brief appetizing description (1-2 sentences)",
  "cuisine": "Italian",
  "prepTimeMinutes": 15,
  "cookTimeMinutes": 30,
  "servings": ${preferences.servings},
  "difficulty": "Easy|Medium|Hard",
  "matchPercentage": 85.0,
  "ingredients": [
    {"name": "chicken breast", "quantity": "500", "unit": "g"},
    {"name": "garlic", "quantity": "3", "unit": "cloves"}
  ],
  "steps": [
    {"stepNumber": 1, "instruction": "Dice the chicken...", "durationMinutes": 5},
    {"stepNumber": 2, "instruction": "Heat oil in a pan...", "durationMinutes": 2}
  ],
  "nutrition": {
    "calories": 450,
    "proteinGrams": 35.0,
    "carbsGrams": 40.0,
    "fatGrams": 15.0,
    "fiberGrams": 5.0,
    "sugarGrams": 8.0,
    "sodiumMg": 600.0
  },
  "tags": ["high-protein", "quick", "comfort food"],
  "missingIngredients": ["soy sauce", "sesame oil"]
}

Return ONLY the JSON, no markdown or explanation.
''';

    final response = await _textModel.generateContent([
      Content.text(prompt),
    ]);

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('No response from Gemini');
    }

    print('[GeminiService] Raw response (first 500 chars): '
        '${text.substring(0, text.length > 500 ? 500 : text.length)}');

    return _parseRecipeResponse(text);
  }

  /// Get a single detailed recipe with more elaborate steps and tips.
  Future<Recipe> getDetailedRecipe({
    required String recipeName,
    required List<String> ingredients,
    required UserPreferences preferences,
  }) async {
    final prompt = '''
You are a professional chef. Provide a detailed version of "$recipeName" 
optimized for the following preferences:
${preferences.toPromptDescription()}

Available ingredients: ${ingredients.join(', ')}

Return a JSON object (NOT wrapped in a "recipes" array, just the single recipe object)
with this EXACT structure:
{
  "name": "Recipe Name",
  "description": "Detailed appetizing description",
  "cuisine": "Italian",
  "prepTimeMinutes": 15,
  "cookTimeMinutes": 30,
  "servings": ${preferences.servings},
  "difficulty": "Easy|Medium|Hard",
  "matchPercentage": 85.0,
  "ingredients": [
    {"name": "ingredient", "quantity": "amount", "unit": "unit"}
  ],
  "steps": [
    {"stepNumber": 1, "instruction": "Detailed instruction with tips...", "durationMinutes": 5}
  ],
  "nutrition": {
    "calories": 450,
    "proteinGrams": 35.0,
    "carbsGrams": 40.0,
    "fatGrams": 15.0,
    "fiberGrams": 5.0,
    "sugarGrams": 8.0,
    "sodiumMg": 600.0
  },
  "tags": ["tag1", "tag2"],
  "missingIngredients": ["ingredient1"]
}

Provide very detailed step-by-step instructions with cooking tips and timing cues.
Return ONLY the JSON.
''';

    final response = await _textModel.generateContent([
      Content.text(prompt),
    ]);

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('No response from Gemini');
    }

    final parsed = jsonDecode(_cleanJson(text)) as Map<String, dynamic>;
    parsed['id'] = _uuid.v4();
    return Recipe.fromJson(parsed);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  List<Recipe> _parseRecipeResponse(String responseText) {
    final cleaned = _cleanJson(responseText);
    final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
    final recipesJson = parsed['recipes'] as List<dynamic>;

    return recipesJson.map((json) {
      final map = json as Map<String, dynamic>;
      map['id'] = _uuid.v4();
      return Recipe.fromJson(map);
    }).toList();
  }
}
