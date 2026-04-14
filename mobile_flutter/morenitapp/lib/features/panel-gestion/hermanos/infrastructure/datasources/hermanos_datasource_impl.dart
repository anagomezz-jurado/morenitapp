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
  Future<List<Hermano>> obtenerHermanos(
      {int limit = 10, int offset = 0}) async {
    try {
      // Nota: Para GET puro en Odoo usamos type='http', la respuesta es directa (List)
      final response = await dio.get('/hermanos');
      final List<dynamic> data = response.data;
      return data.map((h) => Hermano.fromJson(h)).toList();
    } catch (e) {
      throw CustomError('Error al obtener hermanos: $e');
    }
  }

 // Cambia el helper para que acepte la respuesta directa
  dynamic _processResponse(Response response) {
    final data = response.data;
    if (data == null) throw CustomError('Sin respuesta del servidor');
    
    // Si la respuesta es una lista (caso del GET), la devolvemos tal cual
    if (data is List) return data;
    
    // Si es un error personalizado del servidor
    if (data is Map && data['status'] == 'error') {
      throw CustomError(data['message'] ?? 'Error desconocido');
    }
    
    return data; // Devolvemos el Map (status: success, id: ...)
  }

  @override
  Future<Hermano> anadirHermano(Hermano hermano) async {
    try {
      // Importante: Mandamos 'params' dentro del JSON porque el Python lo busca así
      final response = await dio.post('/hermanos', data: {
        "params": hermano.toJson() 
      });
      final result = _processResponse(response);

      if (result['status'] == 'success') {
        return hermano.copyWith(id: result['id']);
      }
      throw CustomError('No se pudo crear');
    } catch (e) {
      throw CustomError('Error al añadir: $e');
    }
  }

  @override
  Future<void> eliminarHermano(int id) async {
    try {
      final response = await dio.delete('/hermanos/$id'); // Eliminamos el data: {}
      _processResponse(response);
    } catch (e) {
      throw CustomError('Error al eliminar: $e');
    }
  }

  @override
  Future<void> actualizarHermano(int id, Map<String, dynamic> datos) async {
    try {
      final response = await dio.put('/hermanos/$id', data: {"params": datos});
      final result = _processResponse(response);
      if (result['status'] == 'error') throw CustomError(result['message']);
    } catch (e) {
      throw CustomError('Error al actualizar: $e');
    }
  }


  @override
  Future<Hermano> obtenerHermanoPorDni(String dni) async {
    try {
      final response = await dio.get('/hermanos/dni/$dni');
      // get_hermano_by_dni en Odoo es type='http', devuelve el JSON directo
      return Hermano.fromJson(response.data);
    } catch (e) {
      throw CustomError('DNI no encontrado');
    }
  }

  // --- Métodos de compatibilidad con tu Interfaz ---
  @override
  Future<bool> tramitarBajaHermano(int id) async {
    try {
      // Reutilizamos la lógica de actualizar el campo estado
      await actualizarHermano(id, {'estado': 'baja'});
      return true;
    } catch (e) {
      return false;
    }
  }

 @override
  Future<bool> bajaHermano(int id) async {
    try {
      // Llamamos a la acción de Odoo o simplemente actualizamos el estado
      final response = await dio.put('/hermanos/$id', data: {
        "params": {
          "estado": "baja",
          "fecha_baja": DateTime.now().toIso8601String().split('T')[0]
        }
      });
      final result = _processResponse(response);
      return result['status'] == 'success';
    } catch (e) {
      throw CustomError('Error al tramitar baja: $e');
    }
  }

  @override
  Future<Hermano> getHermanoByDni(String dni) async {
    try {
      // El endpoint de DNI es tipo 'http' (no json), devuelve el objeto directo
      final response = await dio.get('/hermanos/dni/$dni');
      if (response.statusCode == 404) throw CustomError('Hermano no encontrado');
      
      return Hermano.fromJson(response.data);
    } catch (e) {
      throw CustomError('Error al buscar por DNI: $e');
    }
  }

  @override
  Future<void> updateHermano(int id, Map<String, dynamic> datos) =>
      actualizarHermano(id, datos);

  @override
  Future<List<Hermano>> getHermanos({int limit = 10, int offset = 0}) =>
      obtenerHermanos(limit: limit, offset: offset);
}
