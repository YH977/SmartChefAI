import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/providers.dart';
import 'utils/theme.dart';

// Import screens — Person A will build the scaffold with bottom nav.
// Person B provides: RecipeDetailScreen, ProfileScreen, and all providers.
import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ChefMateApp(),
    ),
  );
}

class ChefMateApp extends StatelessWidget {
  const ChefMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChefMate',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // Person A will replace this with a shell/scaffold containing
      // bottom navigation between: Home, Ingredients, Results, Favorites, Profile.
      // For now, default to Profile so Person B can test independently.
      home: const _TemporaryShell(),
    );
  }
}

/// Temporary navigation shell for Person B to test screens independently.
/// Person A will replace this with the real bottom nav bar.
class _TemporaryShell extends ConsumerStatefulWidget {
  const _TemporaryShell();

  @override
  ConsumerState<_TemporaryShell> createState() => _TemporaryShellState();
}

class _TemporaryShellState extends ConsumerState<_TemporaryShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          // Tab 0: Quick ingredient test + recipe generation
          const _IngredientTestPage(),
          // Tab 1: Profile & Preferences
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Test',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// A minimal test page so Person B can test the AI flow end-to-end
/// without waiting for Person A's full ingredient input screen.
class _IngredientTestPage extends ConsumerStatefulWidget {
  const _IngredientTestPage();

  @override
  ConsumerState<_IngredientTestPage> createState() =>
      _IngredientTestPageState();
}

class _IngredientTestPageState extends ConsumerState<_IngredientTestPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(ingredientsProvider);
    final recipeState = ref.watch(recipeProvider);
    final speechState = ref.watch(speechProvider);
    final imageState = ref.watch(imageDetectionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ingredient Test')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add an ingredient...',
                    ),
                    onSubmitted: (value) {
                      ref.read(ingredientsProvider.notifier).add(value);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Voice button
                IconButton(
                  onPressed: () =>
                      ref.read(speechProvider.notifier).toggleListening(),
                  icon: Icon(
                    speechState.isListening ? Icons.mic : Icons.mic_none,
                    color: speechState.isListening
                        ? AppTheme.error
                        : AppTheme.primary,
                  ),
                ),
                // Camera button
                IconButton(
                  onPressed: () => ref
                      .read(imageDetectionProvider.notifier)
                      .detectFromCamera(),
                  icon: const Icon(Icons.camera_alt_outlined,
                      color: AppTheme.primary),
                ),
              ],
            ),

            if (speechState.isListening)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Listening: "${speechState.currentWords}"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),

            if (imageState.status == DetectionStatus.detecting)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),

            const SizedBox(height: 12),

            // Ingredient chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: ingredients.map((ing) {
                return Chip(
                  label: Text(ing),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () =>
                      ref.read(ingredientsProvider.notifier).remove(ing),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Get recipes button
            ElevatedButton.icon(
              onPressed: recipeState.status == RecipeLoadingStatus.loading
                  ? null
                  : () => ref.read(recipeProvider.notifier).getRecommendations(),
              icon: recipeState.status == RecipeLoadingStatus.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                recipeState.status == RecipeLoadingStatus.loading
                    ? 'Finding recipes...'
                    : 'Get Recipe Recommendations',
              ),
            ),

            if (recipeState.status == RecipeLoadingStatus.error)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  recipeState.errorMessage ?? 'Unknown error',
                  style: const TextStyle(color: AppTheme.error, fontSize: 13),
                ),
              ),

            const SizedBox(height: 16),

            // Results list
            Expanded(
              child: ListView.builder(
                itemCount: recipeState.recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipeState.recipes[index];
                  return Card(
                    child: ListTile(
                      title: Text(recipe.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${recipe.cuisine} · ${recipe.totalTimeMinutes}m · '
                        '${recipe.matchPercentage.toStringAsFixed(0)}% match',
                      ),
                      trailing: Text(
                        '${recipe.nutrition.calories}\nkcal',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
