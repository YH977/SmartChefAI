import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_chef_ai_2/features/home/screens/splash_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  // ProviderScope is required for Riverpod to work
  runApp(const ProviderScope(child: SmartChefApp()));
}

class SmartChefApp extends StatelessWidget {
  const SmartChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartChef AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Using the theme you just created!
      home: const SplashScreen(), // We will replace this in the next step
    );
  }
}

// Temporary Home Screen just to see the app running
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SmartChef AI")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text("Ready to Cook?"),
        ),
      ),
    );
  }
}