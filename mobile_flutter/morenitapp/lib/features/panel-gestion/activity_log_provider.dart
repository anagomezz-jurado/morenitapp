import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ActivityItem {
  final String description;
  final DateTime time;
  final String category; // 'hermano', 'evento', 'auth', etc.

  ActivityItem({
    required this.description, 
    required this.time, 
    this.category = 'general'
  });
}

class ActivityLogNotifier extends StateNotifier<List<ActivityItem>> {
  ActivityLogNotifier() : super([]);

  // Añade una nueva actividad al principio de la lista
  void addActivity(String description, {String category = 'general'}) {
    state = [
      ActivityItem(description: description, time: DateTime.now(), category: category),
      ...state,
    ];
    
    // Opcional: Limitar a los últimos 10 elementos
    if (state.length > 10) {
      state = state.sublist(0, 10);
    }
  }
}

final activityLogProvider = StateNotifierProvider<ActivityLogNotifier, List<ActivityItem>>((ref) {
  return ActivityLogNotifier();
});