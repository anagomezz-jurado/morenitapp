import 'package:morenitapp/features/panel-gestion/activity_log.dart';

abstract class ActivityLogRepository {
  Future<void> saveLog(ActivityLog log);
  Future<List<ActivityLog>> getLogs();
}

class ActivityLogRepositoryImpl implements ActivityLogRepository {

  @override
  Future<void> saveLog(ActivityLog log) async {
    try {
     
    } catch (e) {
      print("Error persistiendo log en remoto: $e");
    }
  }

  @override
  Future<List<ActivityLog>> getLogs() async {
    return [];
  }
}
