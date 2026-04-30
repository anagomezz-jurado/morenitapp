import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/datasources/ubicaciones_datasource.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/codigo_postal.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/localidad.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/provincia.dart';

class UbicacionDataSourceImpl extends UbicacionDatasource {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));


  Future<List<T>> _getList<T>(
      String path, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await dio.get(path);

      if (response.data is Map && response.data['error'] != null) {
        throw Exception(response.data['error']['message'] ?? 'Error de Odoo');
      }

      final dynamic rawData =
          response.data is Map && response.data.containsKey('result')
              ? response.data['result']
              : response.data;

      if (rawData == null || rawData == false) return [];

      final List<dynamic> dataList = rawData is List ? rawData : [];

      return dataList.map((item) => fromJson(item)).toList();
    } catch (e) {
      print("FALLO EN $path: $e");
      throw Exception('Error al obtener datos: $e');
    }
  }

  Future<T> _create<T>(String path, Map<String, dynamic> data,
      T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await dio.post(path, data: data);

      final responseData =
          (response.data is Map && response.data.containsKey('result'))
              ? response.data['result']
              : response.data;

      if (responseData == null || responseData == false) {
        throw Exception('El servidor no devolvió datos válidos al crear');
      }

      return fromJson(responseData);
    } catch (e) {
      throw Exception('Error en POST $path: $e');
    }
  }

  Future<bool> _update(String path, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(path, data: data);
      return response.statusCode == 200;
    } catch (e) {
      print("Error en PUT $path: $e");
      return false;
    }
  }

  Future<bool> _delete(String path) async {
    try {
      final response = await dio.delete(path);
      return response.statusCode == 200;
    } catch (e) {
      print('Error en DELETE $path: $e');
      return false;
    }
  }

  @override
  Future<List<Provincia>> getProvincias() async =>
      _getList('/ubicacion/provincias', (json) => Provincia.fromJson(json));

  @override
  Future<Provincia> crearProvincia(Provincia provincia) async => _create(
      '/ubicacion/provincias',
      provincia.toJson(),
      (json) => Provincia.fromJson(json));

  @override
  Future<bool> editarProvincia(int id, Map<String, dynamic> datos) async =>
      _update('/ubicacion/provincias/$id', datos);

  @override
  Future<bool> eliminarProvincia(int id) async =>
      _delete('/ubicacion/provincias/$id');

  @override
  Future<List<Localidad>> getLocalidades({int? provinciaId}) async {
    final path = provinciaId != null
        ? '/ubicacion/localidades?provincia_id=$provinciaId'
        : '/ubicacion/localidades';
    return _getList(path, (json) => Localidad.fromJson(json));
  }

  @override
  Future<Localidad> crearLocalidad(Localidad localidad) async => _create(
      '/ubicacion/localidades',
      localidad.toJson(),
      (json) => Localidad.fromJson(json));

  @override
  Future<bool> editarLocalidad(int id, Map<String, dynamic> datos) async =>
      _update('/ubicacion/localidades/$id', datos);

  @override
  Future<bool> eliminarLocalidad(int id) async =>
      _delete('/ubicacion/localidades/$id');

  @override
  Future<List<CodigoPostal>> getCodigosPostales({int? localidadId}) async {
    final path = localidadId != null
        ? '/ubicacion/cp?localidad_id=$localidadId'
        : '/ubicacion/cp';
    return _getList(path, (json) => CodigoPostal.fromJson(json));
  }

  @override
  Future<CodigoPostal> crearCodigoPostal(CodigoPostal cp) async {
    final data = {
      'name': cp.name,
      'localidad_id': cp.localidadId,
    };
    return _create(
        '/ubicacion/cp', data, (json) => CodigoPostal.fromJson(json));
  }

  @override
  Future<bool> editarCodigoPostal(int id, Map<String, dynamic> datos) async =>
      _update('/ubicacion/cp/$id', datos);

  @override
  Future<bool> eliminarCodigoPostal(int id) async =>
      _delete('/ubicacion/cp/$id');

  @override
  Future<List<Calle>> getCalles() async =>
      _getList('/ubicacion/calles', (json) => Calle.fromJson(json));

  @override
  Future<Calle> crearCalle(Calle calle) async {
    final data = {
      'nombreCalle': calle.nombreCalle,
      'localidad_id': calle.localidadId,
      'codPostal_id': calle.codPostalId,
    };

    return _create('/ubicacion/calles', data, (json) => Calle.fromJson(json));
  }

  @override
  Future<bool> editarCalle(int id, Map<String, dynamic> datos) async =>
      _update('/ubicacion/calles/$id', datos);

  @override
  Future<bool> eliminarCalle(int id) async => _delete('/ubicacion/calles/$id');
}
