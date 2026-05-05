import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final String title;
  // In the future, Person B will pass a full Recipe object here
  const RecipeDetailsScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. The Animated Image Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: Container(
                color: Theme.of(context).primaryColor.withOpacity(0.7),
                child: const Icon(Icons.restaurant, size: 80, color: Colors.white), 
                // Later replace Icon with Image.network
              ),
            ),
          ),
          
          // 2. The Recipe Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn(Icons.timer, "20 min", context),
                      _buildInfoColumn(Icons.bolt, "Easy", context),
                      _buildInfoColumn(Icons.restaurant_menu, "400 kcal", context),
                    ],
                  ),
                  const Divider(height: 40),
                  
                  const Text("Ingredients Needed", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildIngredientList(["2 Eggs", "1 Tomato", "Salt & Pepper", "Olive Oil"]),
                  
                  const SizedBox(height: 30),
                  const Text("Cooking Steps", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildStep(1, "Chop the tomatoes into small cubes."),
                  _buildStep(2, "Whisk the eggs in a small bowl."),
                  _buildStep(3, "Heat oil in a pan and sauté tomatoes for 3 minutes."),
                  _buildStep(4, "Add eggs and stir until cooked through."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Helper widgets to keep code clean
  Widget _buildInfoColumn(IconData icon, String text, BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildIngredientList(List<String> items) {
    return Column(
      children: items.map((item) => ListTile(
        leading: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
        title: Text(item),
        dense: true,
      )).toList(),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 12, child: Text(number.toString(), style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}