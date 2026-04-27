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
      if (e.type == DioExceptionType.connectionError) {
        throw CustomError('No se pudo conectar al servidor. Revisa tu conexión o el CORS.');
      }
      throw CustomError('Error en el servidor: ${e.response?.statusCode ?? 'Desconocido'}');
    }
  }

  dynamic _processResponse(Response response) {
    if (response.data == null) throw CustomError('Sin respuesta del servidor');
    final data = response.data;
    // Odoo suele envolver la respuesta en un objeto 'result'
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

  // --- UPSERTS GENÉRICOS ---
  Future<Map<String, dynamic>> _upsert(String endpoint, Map<String, dynamic> data) async {
    final id = data['id'];
    // Validar si es nuevo o edición (id != 0 y no nulo)
    final bool isEdit = (id != null && id != 0 && id.toString() != "0");
    final path = isEdit ? '/$endpoint/$id' : '/$endpoint';
    final method = isEdit ? 'PUT' : 'POST';

    final result = await _handleRequest(method, path, data: data);
    return Map<String, dynamic>.from(result);
  }

  Future<Map<String, dynamic>> upsertAutoridad(Map<String, dynamic> data) => _upsert('autoridades', data);
  Future<Map<String, dynamic>> upsertCargo(Map<String, dynamic> data) => _upsert('cargos', data);
  Future<Map<String, dynamic>> upsertCofradia(Map<String, dynamic> data) => _upsert('cofradias', data);

  // --- AUXILIARES ---
  Future<List<Map<String, dynamic>>> getTiposCargos() async {
    final data = await _handleRequest('GET', '/configuracion/tipocargo');
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<List<Map<String, dynamic>>> getCalles() async {
    final data = await _handleRequest('GET', '/calles');
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<Map<String, dynamic>> deleteRegistro(String modelo, int id) async {
    String endpoint = modelo.contains('cargo') ? 'cargos' 
                    : modelo.contains('autoridad') ? 'autoridades' 
                    : 'cofradias';
    final result = await _handleRequest('DELETE', '/$endpoint/$id');
    return Map<String, dynamic>.from(result);
  }
}