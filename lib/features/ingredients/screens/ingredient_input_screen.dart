import 'package:flutter/material.dart';

class IngredientInputScreen extends StatefulWidget {
  const IngredientInputScreen({super.key});

  @override
  State<IngredientInputScreen> createState() => _IngredientInputScreenState();
}

class _IngredientInputScreenState extends State<IngredientInputScreen> {
  final List<String> _ingredients = [];
  final TextEditingController _controller = TextEditingController();

  void _addIngredient(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !_ingredients.contains(trimmed)) {
      setState(() {
        _ingredients.add(trimmed);
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("What's in your fridge?"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add your ingredients",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text("We'll find the best recipes for you."),
            const SizedBox(height: 20),
            
            // Input Field
            TextField(
              controller: _controller,
              onSubmitted: _addIngredient,
              decoration: InputDecoration(
                hintText: "e.g. Chicken, Tomato, Garlic",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _addIngredient(_controller.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Ingredients Display Area (The "Chips")
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _ingredients.map((ingredient) {
                    return Chip(
                      label: Text(ingredient),
                      onDeleted: () {
                        setState(() {
                          _ingredients.remove(ingredient);
                        });
                      },
                      deleteIconColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // The "Action" Button
            ElevatedButton(
              onPressed: _ingredients.isEmpty 
                ? null // Disable button if no ingredients
                : () {
                    // This is where you'll navigate to the Results Screen
                    // Person B will use this list of ingredients for the AI!
                  },
              child: const Text("Find Recipes"),
            ),
          ],
        ),
      ),
    );
  }
}