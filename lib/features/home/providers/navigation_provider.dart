import 'package:flutter_riverpod/flutter_riverpod.dart';

// This keeps track of the current tab index (0, 1, or 2)
final navigationIndexProvider = StateProvider<int>((ref) => 0);