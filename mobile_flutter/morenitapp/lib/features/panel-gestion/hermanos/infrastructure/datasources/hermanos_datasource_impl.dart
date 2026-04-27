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

  dynamic _processResponse(Response response) {
    final data = response.data;
    if (data == null) throw CustomError('Sin respuesta del servidor');
    
    // Si Odoo devuelve el formato estándar de error
    if (data is Map && data.containsKey('error')) {
       throw CustomError(data['error'] ?? 'Error en servidor Odoo');
    }
    
    return data; 
  }

  @override
  Future<List<Hermano>> obtenerHermanos({int limit = 10, int offset = 0}) async {
    try {
      // IMPORTANTE: Añadir /api
      final response = await dio.get('/hermanos');
      final data = _processResponse(response);
      return (data as List).map((h) => Hermano.fromJson(h)).toList();
    } catch (e) {
      throw CustomError('Error al obtener hermanos: $e');
    }
  }

  @override
  Future<void> actualizarHermano(int id, Map<String, dynamic> datos) async {
    try {
      // Odoo NECESITA los datos dentro de "params"
      final response = await dio.put(
        '/hermanos/$id', 
        data: { "params": datos }
      );
      _processResponse(response);
    } catch (e) {
      throw CustomError('Error al actualizar: $e');
    }
  }

  @override
  Future<bool> bajaHermano(int id) async {
    try {
      final response = await dio.put(
        '/hermanos/$id', 
        data: {
          "params": {
            "estado": "baja",
            "fecha_baja": DateTime.now().toIso8601String().split('T')[0]
          }
        }
      );
      final result = _processResponse(response);
      // El backend devuelve "status": "success" o "updated"
      return result['status'] != 'error';
    } catch (e) {
      throw CustomError('Error al tramitar baja: $e');
    }
  }

  @override
  Future<Hermano> anadirHermano(Hermano hermano) async {
    try {
      final response = await dio.post(
        '/hermanos', 
        data: { "params": hermano.toJson() }
      );
      final result = _processResponse(response);
      return hermano.copyWith(id: result['id']);
    } catch (e) {
      throw CustomError('Error al añadir: $e');
    }
  }

  @override
  Future<void> eliminarHermano(int id) async {
    try {
      await dio.delete('/hermanos/$id');
    } catch (e) {
      throw CustomError('Error al eliminar: $e');
    }
  }

  // Métodos de compatibilidad
  @override
  Future<void> updateHermano(int id, Map<String, dynamic> datos) => actualizarHermano(id, datos);
  @override
  Future<List<Hermano>> getHermanos({int limit = 10, int offset = 0}) => obtenerHermanos();
  @override
  Future<Hermano> getHermanoByDni(String dni) async {
     final todos = await obtenerHermanos();
     return todos.firstWhere((h) => h.dni == dni);
  }
}