import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import '../../domain/datasources/proveedor_datasource.dart';
import '../../domain/entities/proveedor.dart';

class ProveedorDatasourceImpl extends ProveedorDatasource {
  
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    },
  ));

  @override
  Future<List<Proveedor>> getProveedores() async {
    try {
      // Petición GET directa al endpoint corregido en Odoo
      final response = await dio.get('/proveedores');
      
      // Con type='http' en Odoo, los datos están en response.data directamente
      final List listado = response.data['proveedores'] ?? [];
      
      return listado.map((p) => Proveedor(
        id: p['id'].toString(),
        codProveedor: p['cod_proveedor'] ?? '',
        nombre: p['nombre'] ?? '',
        contacto: p['contacto'],
        telefono: p['telefono'],
        email: p['email'],
        grupoId: p['grupo_id'],
        grupoNombre: p['grupo_nombre'],
        direccion: p['direccion'],
        anunciante: p['anunciante'] ?? false,
      )).toList();
    } catch (e) {
      throw Exception('Error al obtener proveedores: $e');
    }
  }

  @override
  Future<bool> crearProveedor(Map<String, dynamic> datos) async {
    try {
      // Enviamos los datos directamente o envueltos en params según prefieras, 
      // el controlador de Odoo que te pasé acepta ambos.
      final response = await dio.post('/proveedores/crear', data: {"params": datos});
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> editarProveedor(int id, Map<String, dynamic> datos) async {
    try {
      final response = await dio.post('/proveedores/update', data: {
        "params": { "id": id, ...datos }
      });
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> eliminarProveedor(int id) async {
    try {
      final response = await dio.post('/proveedores/delete', data: {
        "params": { "id": id }
      });
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}