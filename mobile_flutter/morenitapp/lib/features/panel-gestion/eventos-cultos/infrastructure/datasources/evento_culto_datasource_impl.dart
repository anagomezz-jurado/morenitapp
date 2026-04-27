import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import '../../domain/datasources/evento_culto_datasource.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/organizador.dart';

class EventoCultoDatasourceImpl extends EventoCultoDatasource {
  // Configuración de Dio
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl, // Ejemplo: http://192.168.1.XX:8069/api
    connectTimeout: const Duration(seconds: 7),
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // --- MÉTODOS BASE ---

  Future<dynamic> _get(String path) async {
    final response = await dio.get(path);
    return response.data;
  }

  // --- EVENTOS ---

  @override
  Future<List<Evento>> getEventos() async {
    try {
      print('*** Iniciando petición a: ${dio.options.baseUrl}/eventos ***');

      final response = await dio.get('/eventos');

      print('*** Respuesta recibida: ${response.statusCode} ***');
      print('*** Datos brutos: ${response.data} ***');

      if (response.data == null) {
        print('*** OJO: Odoo devolvió null ***');
        return [];
      }

      final List<dynamic> data = response.data;

      final lista = data
          .map((json) {
            try {
              return Evento.fromJson(json);
            } catch (e) {
              // Esto te dirá si falta algún campo como 'nombre' o 'fecha'
              print("!!! Error parseando evento ID ${json['id']}: $e");
              return null;
            }
          })
          .whereType<Evento>()
          .toList();

      print('*** Total eventos procesados: ${lista.length} ***');
      return lista;
    } on DioException catch (e) {
      print('!!! ERROR DE DIO: ${e.type}');
      print('!!! Mensaje: ${e.message}');
      print('!!! Error del server: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('!!! ERROR INESPERADO: $e');
      rethrow;
    }
  }

  @override
  Future<bool> crearEvento(Map<String, dynamic> datos) async {
    try {
      final response = await dio.post('/eventos', data: datos);
      return response.data['success'] == true;
    } catch (e) {
      print('Error crearEvento: $e');
      return false;
    }
  }

  @override
  Future<bool> editarEvento(int id, Map<String, dynamic> datos) async {
    try {
      final response = await dio.put('/eventos/$id', data: datos);
      return response.data['success'] == true;
    } catch (e) {
      print('Error editarEvento: $e');
      return false;
    }
  }

  @override
  Future<bool> eliminarEvento(int id) async {
    try {
      final response = await dio.delete('/eventos/$id');
      return response.data['success'] == true;
    } catch (e) {
      print('Error eliminarEvento: $e');
      return false;
    }
  }

  // --- ORGANIZADORES ---

  @override
  Future<List<Organizador>> getOrganizadores() async {
    try {
      final result = await _get('/organizadores');

      final List data = result is List ? result : [];

      return data.map((o) => Organizador.fromJson(o)).toList();
    } on DioException catch (e) {
      print('DioError Organizadores: ${e.requestOptions.uri}');
      throw Exception('Error de conexión con organizadores');
    } catch (e) {
      throw Exception('Error al obtener organizadores: $e');
    }
  }

  @override
  Future<bool> crearOrganizador(Map<String, dynamic> datos) async {
    try {
      final response = await dio.post('/organizadores', data: datos);
      return response.data['success'] == true;
    } on DioException catch (e) {
      print('Error al crear organizador: ${e.response?.data}');
      return false;
    }
  }

  @override
  Future<bool> editarOrganizador(int id, Map<String, dynamic> datos) async {
    try {
      final response = await dio.put('/organizadores/$id', data: datos);
      return response.data['success'] == true;
    } on DioException catch (e) {
      print('Error al editar organizador: ${e.response?.data}');
      return false;
    }
  }

  @override
  Future<bool> eliminarOrganizador(int id) async {
    try {
      final response = await dio.delete('/organizadores/$id');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
