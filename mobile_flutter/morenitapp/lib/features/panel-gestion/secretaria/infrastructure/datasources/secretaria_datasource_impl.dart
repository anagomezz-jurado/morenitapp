import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/features/auth/infrastructure/errors/auth_errors.dart';
import '../../domain/entities/autoridad.dart';
import '../../domain/entities/cargo.dart';
import '../../domain/entities/cofradia.dart';

class SecretariaDatasourceImpl {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    },
  ));

  Future<dynamic> _handleRequest(String method, String path,
      {Map<String, dynamic>? data}) async {
    try {
      final response = await dio.request(
        path,
        data: (method == 'GET' || method == 'DELETE')
            ? null
            : {"params": data ?? {}},
        options: Options(method: method),
      );
      return _processResponse(response);
    } on DioException catch (e) {
      // Si es un error de conexión (como el de XMLHttpRequest)
      if (e.type == DioExceptionType.connectionError) {
        throw CustomError(
            'No se pudo conectar al servidor. Revisa tu conexión o el CORS.');
      }
      throw CustomError('Error en el servidor: ${e.response?.statusCode}');
    }
  }

  dynamic _processResponse(Response response) {
    if (response.data == null) throw CustomError('Sin respuesta del servidor');
    final data = response.data;
    if (data is Map && data.containsKey('result')) return data['result'];
    return data;
  }

  // --- GETTERS ---
  Future<List<Autoridad>> getAutoridades() async {
    final data = await _handleRequest('GET', '/autoridades');
    return (data as List).map((json) => Autoridad.fromJson(json)).toList();
  }

  Future<List<Cargo>> getCargos() async {
    final data = await _handleRequest('GET', '/cargos');
    return (data as List).map((json) => Cargo.fromJson(json)).toList();
  }

  Future<List<Cofradia>> getCofradias() async {
    final data = await _handleRequest('GET', '/cofradias');
    return (data as List).map((json) => Cofradia.fromJson(json)).toList();
  }

  // --- UPSERTS (POST/PUT) ---
  Future<Map<String, dynamic>> upsertAutoridad(
      Map<String, dynamic> data) async {
    final id = data['id'];
    final path = (id != null && id != 0) ? '/autoridades/$id' : '/autoridades';
    return await _handleRequest((id != null && id != 0) ? 'PUT' : 'POST', path,
        data: data);
  }

  Future<Map<String, dynamic>> upsertCargo(Map<String, dynamic> data) async {
    final id = data['id'];
    final path = (id != null && id != 0) ? '/cargos/$id' : '/cargos';
    return await _handleRequest((id != null && id != 0) ? 'PUT' : 'POST', path,
        data: data);
  }

  Future<Map<String, dynamic>> upsertCofradia(Map<String, dynamic> data) async {
    final id = data['id'];
    final path = (id != null && id != 0) ? '/cofradias/$id' : '/cofradias';
    return await _handleRequest((id != null && id != 0) ? 'PUT' : 'POST', path,
        data: data);
  }

  // --- AUXILIARES ---
  Future<List<Map<String, dynamic>>> getTiposCargos() async {
  final data = await _handleRequest('GET', '/configuracion/tipocargo');
  dev.log('DATOS RECIBIDOS: $data', name: 'API_DEBUG');
  return List<Map<String, dynamic>>.from(data as List);
}

  Future<List<Map<String, dynamic>>> getCalles() async {
    final data = await _handleRequest('GET', '/calles');
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<Map<String, dynamic>> deleteRegistro(String modelo, int id) async {
    String path = modelo.contains('cargo')
        ? '/cargos'
        : modelo.contains('autoridad')
            ? '/autoridades'
            : '/cofradias';
    return await _handleRequest('DELETE', '$path/$id');
  }
}
