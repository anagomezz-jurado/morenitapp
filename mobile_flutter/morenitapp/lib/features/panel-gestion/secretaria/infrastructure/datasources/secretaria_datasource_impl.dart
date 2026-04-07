import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import '../../domain/datasources/secretaria_datasource.dart';
import '../../domain/entities/autoridad.dart';
import '../../domain/entities/cargo.dart';
import '../../domain/entities/cofradia.dart';

class SecretariaDatasourceImpl extends SecretariaDatasource {
  
  // Configuración de Dio mejorada
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl, 
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    },
  ));

  // MÉTODO PRIVADO REFORMADO PARA EVITAR 404
  Future<dynamic> _handleRequest(String method, String path, {Map<String, dynamic>? data}) async {
  try {
    // Aseguramos que el path empiece con / y no tenga espacios
    final cleanPath = path.startsWith('/') ? path.trim() : '/${path.trim()}';
    
    final response = await dio.request(
      cleanPath,
      data: data,
      options: Options(method: method.toUpperCase()),
    );
    return response.data;
  } on DioException catch (e) {
    // Esto te dirá en la consola de VS Code exactamente a qué URL intentó ir
    print("DEBUG: Falló conexión a -> ${dio.options.baseUrl}${e.requestOptions.path}");
    rethrow;
  }
}

  // --- IMPLEMENTACIÓN ---

  @override
  Future<List<Autoridad>> getAutoridades() async {
    // Usamos el path exacto definido en Odoo
    final dynamic data = await _handleRequest('GET', '/autoridades');
    if (data is! List) return [];
    return data.map((json) => Autoridad.fromJson(json)).toList();
  }

  @override
  Future<List<Cargo>> getCargos() async {
    final dynamic data = await _handleRequest('GET', '/cargos');
    if (data is! List) return [];
    return data.map((json) => Cargo.fromJson(json)).toList();
  }

  @override
  Future<List<Cofradia>> getCofradias() async {
    final dynamic data = await _handleRequest('GET', '/cofradias');
    if (data is! List) return [];
    return data.map((json) => Cofradia.fromJson(json)).toList();
  }

  // --- UPSERTS ---

  @override
  Future<Map<String, dynamic>> upsertAutoridad(Map<String, dynamic> data) async {
    final String id = data['id']?.toString() ?? '';
    if (id.isNotEmpty && id != '0') {
      return await _handleRequest('PUT', '/autoridades/$id', data: data);
    } else {
      // Quitamos el ID si es nuevo para evitar conflictos en Odoo
      final cleanData = Map<String, dynamic>.from(data)..remove('id');
      return await _handleRequest('POST', '/autoridades', data: cleanData);
    }
  }

  // --- DELETE ---

  @override
  Future<Map<String, dynamic>> deleteRegistro(String modelo, int id) async {
    String path = '';
    switch (modelo) {
      case 'morenitapp.autoridad': path = '/autoridades'; break;
      case 'morenitapp.cargo':     path = '/cargos'; break;
      case 'morenitapp.cofradia':  path = '/cofradias'; break;
      default: throw Exception('Modelo no soportado');
    }
    // IMPORTANTE: path/$id sin carácteres extraños
    return await _handleRequest('DELETE', '$path/$id');
  }

  // Implementaciones faltantes
  @override
  Future<Map<String, dynamic>> upsertCargo(Map<String, dynamic> data) async {
    final String id = data['id']?.toString() ?? '';
    if (id.isNotEmpty) return await _handleRequest('PUT', '/cargos/$id', data: data);
    return await _handleRequest('POST', '/cargos', data: data);
  }

  @override
  Future<Map<String, dynamic>> upsertCofradia(Map<String, dynamic> data) async {
    final String id = data['id']?.toString() ?? '';
    if (id.isNotEmpty) return await _handleRequest('PUT', '/cofradias/$id', data: data);
    return await _handleRequest('POST', '/cofradias', data: data);
  }
}