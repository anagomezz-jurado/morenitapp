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
      final response = await dio.get('/proveedores');

      final List listado = response.data['proveedores'] ?? [];

      return listado
          .map((p) => Proveedor(
                id: p['id'].toString(),
                codProveedor: p['cod_proveedor'] ?? '',
                nombre: p['nombre'] ?? '',
                contacto: p['contacto'],
                telefono: p['telefono'],
                email: p['email'],
                grupoId: p['grupo_id'],
                grupoNombre: p['grupo_nombre'],
                anunciante: p['anunciante'] ?? false,
                observaciones: p['observaciones'],
                calleId: p['calle_id'],
                calleNombre: p['calle_nombre'],
                numero: p['numero'],
                escalera: p['escalera'],
                bloque: p['bloque'],
                portal: p['portal'],
                piso: p['piso'],
                puerta: p['puerta'],
              ))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener proveedores: $e');
    }
  }

  @override
  Future<bool> crearProveedor(Map<String, dynamic> datos) async {
    try {
      final response =
          await dio.post('/proveedores/crear', data: {"params": datos});
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> editarProveedor(int id, Map<String, dynamic> datos) async {
    try {
      final response = await dio.post('/proveedores/update', data: {
        "params": {...datos, "id": id}
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
        "params": {"id": id}
      });
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
