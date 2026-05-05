import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Handles persisting user preferences and saved/favorite recipes locally.
class StorageService {
  static const _prefsKey = 'user_preferences';
  static const _favoritesKey = 'favorite_recipes';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // ---------------------------------------------------------------------------
  // User Preferences
  // ---------------------------------------------------------------------------

  Future<void> savePreferences(UserPreferences preferences) async {
    final json = jsonEncode(preferences.toJson());
    await _prefs.setString(_prefsKey, json);
  }

  UserPreferences loadPreferences() {
    final json = _prefs.getString(_prefsKey);
    if (json == null) return const UserPreferences();
    return UserPreferences.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------------------
  // Favorite Recipes
  // ---------------------------------------------------------------------------

  Future<void> saveFavorite(Recipe recipe) async {
    final favorites = loadFavorites();
    // Don't add duplicates
    if (favorites.any((r) => r.id == recipe.id)) return;
    favorites.add(recipe);
    await _saveFavoritesList(favorites);
  }

  Future<void> removeFavorite(String recipeId) async {
    final favorites = loadFavorites();
    favorites.removeWhere((r) => r.id == recipeId);
    await _saveFavoritesList(favorites);
  }

  List<Recipe> loadFavorites() {
    final json = _prefs.getString(_favoritesKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  bool isFavorite(String recipeId) {
    return loadFavorites().any((r) => r.id == recipeId);
  }

  Future<void> _saveFavoritesList(List<Recipe> favorites) async {
    final json = jsonEncode(favorites.map((r) => r.toJson()).toList());
    await _prefs.setString(_favoritesKey, json);
  }
}
