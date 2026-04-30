import '../../domain/datasources/proveedor_datasource.dart';
import '../../domain/entities/proveedor.dart';
import '../../domain/repositories/proveedor_repository.dart';

class ProveedorRepositoryImpl extends ProveedorRepository {
  final ProveedorDatasource datasource;

  ProveedorRepositoryImpl(this.datasource);

  @override
  Future<List<Proveedor>> getProveedores() => datasource.getProveedores();

  @override
  Future<bool> crearProveedor(Map<String, dynamic> datos) =>
      datasource.crearProveedor(datos);

  @override
  Future<bool> editarProveedor(int id, Map<String, dynamic> datos) =>
      datasource.editarProveedor(id, datos);

  @override
  Future<bool> eliminarProveedor(int id) => datasource.eliminarProveedor(id);
}
