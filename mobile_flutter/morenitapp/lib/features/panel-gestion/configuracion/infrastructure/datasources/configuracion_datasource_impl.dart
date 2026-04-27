import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/infrastructure/mappers/user_mapper.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/datasources/configuracion_datasources.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/grupo_proveedor.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_autoridad.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_cargo.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_evento.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_rol.dart';

class ConfiguracionDatasourceImpl extends ConfiguracionDatasource {
  
  final Dio dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // --- MÉTODOS BASE PARA LLAMADAS REST ---

  Future<dynamic> _get(String path) async {
    try {
      final response = await dio.get(path);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Error GET $path: ${e.message}');
    }
  }

  Future<dynamic> _post(String path, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Error POST $path: ${e.message}');
    }
  }

  Future<dynamic> _put(String path, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Error PUT $path: ${e.message}');
    }
  }

  Future<dynamic> _delete(String path) async {
    try {
      final response = await dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Error DELETE $path: ${e.message}');
    }
  }

  // --- IMPLEMENTACIÓN DE LOS MÉTODOS ---

  @override
  Future<List<TipoEvento>> getTiposEvento() async {
    final result = await _get('/configuracion/tipoevento');
    final List data = result is List ? result : [];
    return data.map((json) => TipoEvento.fromJson(json)).toList();
  }

  @override
  Future<bool> crearTipoEvento(Map<String, dynamic> datos) async {
    final result = await _post('/configuracion/tipoevento', datos);
    return result['id'] != null;
  }

  @override
  Future<bool> editarTipoEvento(int id, Map<String, dynamic> datos) async {
    final result = await _put('/configuracion/tipoevento/$id', datos);
    return result['status'] == 'updated';
  }

  @override
  Future<bool> eliminarTipoEvento(int id) async {
    final result = await _delete('/configuracion/tipoevento/$id');
    return result['status'] == 'deleted';
  }

  // --- CARGOS ---
  @override
  Future<List<TipoCargo>> getTiposCargo() async {
    final result = await _get('/configuracion/tipocargo');
    final List data = result is List ? result : [];
    return data.map((json) => TipoCargo.fromJson(json)).toList();
  }

@override
  Future<bool> crearTipoCargo(Map<String, dynamic> datos) async {
    // Cambiado de '/configuracion/...' a '/api/configuracion/...'
    final result = await _post('/configuracion/tipocargo', datos);
    return result['id'] != null;
  }

  @override
  Future<bool> editarTipoCargo(int id, Map<String, dynamic> datos) async {
    final result = await _put('/configuracion/tipocargo/$id', datos);
    // El controlador ahora devuelve {"status": "updated"}
    return result['status'] == 'updated';
  }

  @override
  Future<bool> eliminarTipoCargo(int id) async {
    final result = await _delete('/configuracion/tipocargo/$id');
    return result['status'] == 'deleted';
  }

  // --- AUTORIDADES ---
  @override
  Future<List<TipoAutoridad>> getTiposAutoridad() async {
    final result = await _get('/configuracion/tipoautoridad');
    final List data = result is List ? result : [];
    return data.map((json) => TipoAutoridad.fromJson(json)).toList();
  }

  @override
  Future<bool> crearTipoAutoridad(Map<String, dynamic> datos) async {
    final result = await _post('/configuracion/tipoautoridad', datos);
    return result['id'] != null;
  }

  @override
  Future<bool> editarTipoAutoridad(int id, Map<String, dynamic> datos) async {
    final result = await _put('/configuracion/tipoautoridad/$id', datos);
    return result['status'] == 'updated';
  }

  @override
  Future<bool> eliminarTipoAutoridad(int id) async {
    final result = await _delete('/configuracion/tipoautoridad/$id');
    return result['status'] == 'deleted';
  }

  // --- ROLES ---
  @override
  Future<List<Rol>> getRoles() async {
    final result = await _get('/configuracion/rol');
    final List data = result is List ? result : [];
    return data.map((json) => Rol.fromJson(json)).toList();
  }

  @override
  Future<bool> crearRol(Map<String, dynamic> datos) async {
    final result = await _post('/configuracion/rol', datos);
    return result['id'] != null;
  }

  @override
  Future<bool> editarRol(int id, Map<String, dynamic> datos) async {
    final result = await _put('/configuracion/rol/$id', datos);
    return result['status'] == 'updated';
  }

  @override
  Future<bool> eliminarRol(int id) async {
    final result = await _delete('/configuracion/rol/$id');
    return result['status'] == 'deleted';
  }

  // --- GRUPOS PROVEEDOR ---
  @override
  Future<List<GrupoProveedor>> getGruposProveedor() async {
    final result = await _get('/configuracion/grupoproveedor');
    final List data = result is List ? result : [];
    return data.map((g) => GrupoProveedor.fromJson(g)).toList();
  }

  @override
  Future<bool> crearGrupoProveedor(Map<String, dynamic> datos) async {
    final result = await _post('/configuracion/grupoproveedor', datos);
    return result['id'] != null;
  }

  @override
  Future<bool> editarGrupoProveedor(int id, Map<String, dynamic> datos) async {
    final result = await _put('/configuracion/grupoproveedor/$id', datos);
    return result['status'] == 'updated';
  }

  @override
  Future<bool> eliminarGrupoProveedor(int id) async {
    final result = await _delete('/configuracion/grupoproveedor/$id');
    return result['status'] == 'deleted';
  }

}