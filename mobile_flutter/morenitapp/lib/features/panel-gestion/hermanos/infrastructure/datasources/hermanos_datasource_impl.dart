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
      final response = await dio.get('/hermanos');
      final data = _processResponse(response);
      
      // Aseguramos que data sea una lista para evitar errores de cast
      if (data is! List) {
        // A veces Odoo devuelve la lista dentro de un campo 'result'
        if (data is Map && data['result'] != null) {
          return (data['result'] as List).map((h) => Hermano.fromJson(h)).toList();
        }
        return [];
      }

      return data.map((h) => Hermano.fromJson(h)).toList();
    } catch (e) {
      throw CustomError('Error al obtener hermanos: $e');
    }
  }

  // MÉTODO CORREGIDO: Búsqueda por DNI
  @override
  Future<Hermano> getHermanoByDni(String dni) async {
    try {
      // 1. Obtenemos la lista (o podrías llamar a un endpoint de búsqueda si el backend lo tiene)
      final todos = await obtenerHermanos();
      
      // 2. Buscamos con normalización (quitar espacios y pasar a Mayúsculas)
      final dniBusqueda = dni.trim().toUpperCase();
      
      try {
        return todos.firstWhere(
          (h) => h.dni?.toString().trim().toUpperCase() == dniBusqueda
        );
      } catch (e) {
        // Si firstWhere no encuentra nada, lanza una excepción StateError
        throw CustomError('No se ha encontrado ningún hermano con el DNI: $dni');
      }
    } catch (e) {
      throw CustomError(e.toString());
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
  Future<List<Hermano>> getHermanos({int limit = 10, int offset = 0}) => obtenerHermanos(limit: limit, offset: offset);

}