import 'package:flutter/material.dart';
import '../../../features/ingredients/screens/ingredient_input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("SmartChef AI")),
    body: Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const IngredientInputScreen())
          );
        },
        child: const Text("Start Cooking"),
      ),
    ),
  );
}
}