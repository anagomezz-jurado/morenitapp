import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:morenitapp/features/panel-gestion/activity_log.dart';

abstract class ActivityLogDatasource {
  Future<List<ActivityLog>> getLogs({int limit});
  Future<void> saveLog(ActivityLog log);
}

class ActivityLogDatasourceImpl implements ActivityLogDatasource {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    },
  ));

  @override
  Future<List<ActivityLog>> getLogs({int limit = 20}) async {
    try {
      final response = await dio.get('/activity-logs', queryParameters: {'limit': limit});
      final data = response.data;

      if (data is! List) return [];

      return data.map((item) => ActivityLog.fromJson(item)).toList();
    } catch (e) {
      throw CustomError('Error al obtener logs: $e');
    }
  }

  @override
  Future<void> saveLog(ActivityLog log) async {
    try {
      await dio.post('/activity-logs', data: {'params': log.toJson()});
    } catch (e) {
      throw CustomError('Error al guardar log: $e');
    }
  }
}
