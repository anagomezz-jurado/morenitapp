import '../entities/proveedor.dart';

abstract class ProveedorRepository {
  Future<List<Proveedor>> getProveedores();
  Future<bool> crearProveedor(Map<String, dynamic> datos);
  Future<bool> editarProveedor(int id, Map<String, dynamic> datos);
  Future<bool> eliminarProveedor(int id);
}
