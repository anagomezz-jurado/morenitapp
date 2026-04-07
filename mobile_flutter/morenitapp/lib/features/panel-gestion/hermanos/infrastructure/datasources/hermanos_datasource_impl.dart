import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/datasources/hermano_datasource.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';

class HermanosDatasourceImpl extends HermanoDatasource {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    },
  ));

  @override
  Future<List<Hermano>> getHermanos({int limit = 10, int offset = 0}) async {
    try {
      final response = await dio.get('/hermanos');
      final List<dynamic> data = response.data;
      return data.map((hermanoJson) => Hermano.fromJson(hermanoJson)).toList();
    } on DioException catch (e) {
      throw CustomError('Error: ${e.response?.data['message'] ?? 'Error interno'}');
    }
  }

  @override
  Future<Hermano> anadirHermano(Hermano hermano) async {
    try {
      final response = await dio.post('/hermanos', data: jsonEncode(hermano.toJson()));
      final res = (response.data is String) ? jsonDecode(response.data) : response.data;

      if (res['status'] == 'success') {
        return Hermano.fromJson({
          ...hermano.toJson(),
          'id': res['id'],
          'codigo_hermano': res['codigo'],
        });
      }
      throw CustomError(res['message'] ?? 'Error del servidor');
    } on DioException catch (e) {
      throw CustomError(e.response?.data?['message'] ?? 'Error 500');
    }
  }

  @override
  Future<void> updateHermano(int id, Map<String, dynamic> datos) async {
    try {
      await dio.put('/hermanos/$id', data: datos);
    } on DioException catch (e) {
      throw CustomError('Error al actualizar: ${e.response?.data['message'] ?? 'Error'}');
    }
  }

  @override
  Future<void> eliminarHermano(int id) async {
    try {
      await dio.delete('/hermanos/$id');
    } on DioException catch (e) {
      throw CustomError('Error al eliminar');
    }
  }

  @override
  Future<Hermano> getHermanoByDni(String dni) async {
    // Implementar si es necesario
    throw UnimplementedError();
  }

  @override
  Future<bool> bajaHermano(int id) async {
    try {
      final response = await dio.post('/hermanos/$id/baja');
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw CustomError('Error al dar de baja');
    }
  }
}