import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import '../../domain/datasources/evento_culto_datasource.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/organizador.dart';

class EventoCultoDatasourceImpl extends EventoCultoDatasource {
  
  // Configuración de Dio con interceptores para logging (opcional pero recomendado)
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl, // DEBE SER: http://192.168.56.1:8069/api
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // --- MÉTODOS BASE ---
  // Se eliminan los '/' extras para evitar el error de doble slash en la URL
  Future<dynamic> _get(String path) async {
    final response = await dio.get(path);
    return response.data;
  }

  // --- EVENTOS ---
  @override
  Future<List<Evento>> getEventos() async {
    try {
      // Si la baseUrl termina en /api, path debe ser '/eventos'
      final result = await _get('/eventos');
      
      // El controlador corregido devuelve directamente una Lista []
      final List data = result is List ? result : [];
      
      return data.map((e) => Evento.fromJson(e)).toList();
    } on DioException catch (e) {
      print('DioError Eventos: ${e.type} - ${e.message}');
      throw Exception('Error de red al obtener eventos');
    } catch (e) {
      throw Exception('Error al procesar eventos: $e');
    }
  }

  @override
  Future<bool> crearEvento(Map<String, dynamic> datos) async {
    try {
      final response = await dio.post('/eventos', data: datos);
      // El controlador de Odoo devuelve {"success": true, "id": ...}
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> editarEvento(int id, Map<String, dynamic> datos) async {
    try {
      final response = await dio.put('/eventos/$id', data: datos);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> eliminarEvento(int id) async {
    try {
      final response = await dio.delete('/eventos/$id');
      return response.data['success'] == true;
    } catch (e) {
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
      print('DioError Organizadores: ${e.message}');
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
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> editarOrganizador(int id, Map<String, dynamic> datos) async {
    try {
      final response = await dio.put('/organizadores/$id', data: datos);
      return response.data['success'] == true;
    } catch (e) {
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