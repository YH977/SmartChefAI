import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Temporary state for UI demonstration (Person B will move this to Riverpod)
  String selectedDiet = "Halal";
  List<String> selectedCuisines = ["Italian", "Middle Eastern"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. User Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person, size: 50, color: theme.primaryColor),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Chef User",
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Text("Personalized Cooking Experience"),
                ],
              ),
            ),
            const Divider(),

            // 2. Religious & Dietary Section
            _buildSectionHeader(context, "Religious & Dietary Laws"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                children: [
                  _buildChoiceChip("Halal", selectedDiet == "Halal", (val) {
                    setState(() => selectedDiet = "Halal");
                  }),
                  _buildChoiceChip("Haram (None)", selectedDiet == "Haram (None)", (val) {
                    setState(() => selectedDiet = "Haram (None)");
                  }),
                  _buildChoiceChip("Vegan", selectedDiet == "Vegan", (val) {
                    setState(() => selectedDiet = "Vegan");
                  }),
                ],
              ),
            ),

            const Divider(),

            // 3. Cuisine Preferences
            _buildSectionHeader(context, "Favorite Cuisines"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                children: [
                  _buildFilterChip("Italian"),
                  _buildFilterChip("French"),
                  _buildFilterChip("Middle Eastern"),
                  _buildFilterChip("Japanese"),
                  _buildFilterChip("Mexican"),
                ],
              ),
            ),

            const Divider(),

            // 4. Activity
            _buildSectionHeader(context, "Account"),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text("Saved Recipes"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, Function(bool) onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isFav = selectedCuisines.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isFav,
      onSelected: (val) {
        setState(() {
          val ? selectedCuisines.add(label) : selectedCuisines.remove(label);
        });
      },
    );
  }
}