import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:morenitapp/features/panel-gestion/activity_log.dart';
import 'package:morenitapp/features/panel-gestion/activity_log_datasource.dart';

final activityLogDatasourceProvider = Provider<ActivityLogDatasource>((ref) {
  return ActivityLogDatasourceImpl();
});

class ActivityLogNotifier extends StateNotifier<AsyncValue<List<ActivityLog>>> {
  final Ref ref;

  ActivityLogNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    state = const AsyncValue.loading();
    try {
      final logs = await ref.read(activityLogDatasourceProvider).getLogs(limit: 20);
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addLog({
    required String userId,
    required String userName,
    required ActionType action,
    required String entityName,
    String detail = '',
  }) async {
    final newLog = ActivityLog(
      userId: userId,
      userName: userName,
      action: action,
      entityName: entityName,
      description: detail.isNotEmpty ? detail : 'Sin descripción',
      createdAt: DateTime.now(),
    );

    try {
      // Guardar en Odoo
      await ref.read(activityLogDatasourceProvider).saveLog(newLog);

      // Actualizar estado local
      state.whenData((logs) {
        state = AsyncValue.data([newLog, ...logs]);
      });
    } catch (e) {
      // Si falla el guardado remoto, aún actualizamos localmente
      state.whenData((logs) {
        state = AsyncValue.data([newLog, ...logs]);
      });
    }
  }

  Future<void> refresh() => loadLogs();
}

final activityLogProvider =
    StateNotifierProvider<ActivityLogNotifier, AsyncValue<List<ActivityLog>>>((ref) {
  return ActivityLogNotifier(ref);
});
