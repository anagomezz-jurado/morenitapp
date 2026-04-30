import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:morenitapp/features/panel-gestion/activity_log.dart';
import 'package:morenitapp/features/panel-gestion/activity_log_repository.dart';

final activityLogRepositoryProvider = Provider<ActivityLogRepository>((ref) {
  return ActivityLogRepositoryImpl();
});

class ActivityLogNotifier extends StateNotifier<List<ActivityLog>> {
  final Ref ref;
  ActivityLogNotifier(this.ref) : super([]);

  Future<void> addLog({
    required String userId,
    required String userName,
    required ActionType action,
    required String entityName,
    String detail = '',
  }) async {
    final newLog = ActivityLog(
      id: DateTime.now().toString(),
      userId: userId,
      userName: userName,
      action: action,
      entityName: entityName,
      description: detail.isNotEmpty ? detail : 'Sin descripción',
      createdAt: DateTime.now(),
    );

    state = [newLog, ...state];
    await ref.read(activityLogRepositoryProvider).saveLog(newLog);
  }
}

final activityLogProvider =
    StateNotifierProvider<ActivityLogNotifier, List<ActivityLog>>((ref) {
  return ActivityLogNotifier(ref);
});
