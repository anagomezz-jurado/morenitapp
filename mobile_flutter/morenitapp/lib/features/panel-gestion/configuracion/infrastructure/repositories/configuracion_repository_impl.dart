import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/datasources/configuracion_datasources.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/grupo_proveedor.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_autoridad.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_cargo.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_evento.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_rol.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/repositories/configuracion_repository.dart';

class ConfiguracionRepositoryImpl extends ConfiguracionRepository {
  final ConfiguracionDatasource datasource;

  ConfiguracionRepositoryImpl(this.datasource);

  // --- EVENTOS ---
  @override
  Future<List<TipoEvento>> getTiposEvento() => datasource.getTiposEvento();

  @override
  Future<bool> crearTipoEvento(String codigo, String nombre) =>
      datasource.crearTipoEvento({'cod_tipo_evento': codigo, 'nombre_tipo_evento': nombre});

  @override
  Future<bool> editarTipoEvento(int id, String codigo, String nombre) =>
      datasource.editarTipoEvento(id, {'cod_tipo_evento': codigo, 'nombre_tipo_evento': nombre});

  @override
  Future<bool> eliminarTipoEvento(int id) => datasource.eliminarTipoEvento(id);

  // --- CARGOS ---
  @override
  Future<List<TipoCargo>> getTiposCargo() => datasource.getTiposCargo();

  @override
  Future<bool> crearTipoCargo(String codigo, String nombre, String observaciones) =>
      datasource.crearTipoCargo({'codTipoCargo': codigo, 'nombreTipoCargo': nombre, 'observaciones': observaciones});

  @override
  Future<bool> editarTipoCargo(int id, String codigo, String nombre, String observaciones) =>
      datasource.editarTipoCargo(id, {'codTipoCargo': codigo, 'nombreTipoCargo': nombre, 'observaciones': observaciones});

  @override
  Future<bool> eliminarTipoCargo(int id) => datasource.eliminarTipoCargo(id);

  // --- AUTORIDADES ---
  @override
  Future<List<TipoAutoridad>> getTiposAutoridad() => datasource.getTiposAutoridad();

  @override
  Future<bool> crearTipoAutoridad(String codigo, String nombre) =>
      datasource.crearTipoAutoridad({'codTipoAutoridad': codigo, 'nombreTipoAutoridad': nombre});

  @override
  Future<bool> editarTipoAutoridad(int id, String codigo, String nombre) =>
      datasource.editarTipoAutoridad(id, {'codTipoAutoridad': codigo, 'nombreTipoAutoridad': nombre});

  @override
  Future<bool> eliminarTipoAutoridad(int id) => datasource.eliminarTipoAutoridad(id);

  // --- ROLES ---
  @override
  Future<List<Rol>> getRoles() => datasource.getRoles();

  @override
  Future<bool> crearRol(int codigo, String nombre) =>
      datasource.crearRol({'codRol': codigo, 'name': nombre});

  @override
  Future<bool> editarRol(int id, int codigo, String nombre) =>
      datasource.editarRol(id, {'codRol': codigo, 'name': nombre});

  @override
  Future<bool> eliminarRol(int id) => datasource.eliminarRol(id);

  // --- GRUPOS DE PROVEEDORES ---
  @override
  Future<List<GrupoProveedor>> getGruposProveedor() => datasource.getGruposProveedor();

  @override
  Future<bool> crearGrupoProveedor(String codigo, String nombre) {
    return datasource.crearGrupoProveedor({
      'cod_grupo': codigo,
      'nombre': nombre,
    });
  }

  @override
  Future<bool> editarGrupoProveedor(int id, String codigo, String nombre) {
    return datasource.editarGrupoProveedor(id, {
      'cod_grupo': codigo,
      'nombre': nombre,
    });
  }

  @override
  Future<bool> eliminarGrupoProveedor(int id) => datasource.eliminarGrupoProveedor(id);

  @override
Future<List<User>> getUsers() {
  return datasource.getUsers();
}

@override
Future<bool> crearUsuario(Map<String, dynamic> datos) {
  return datasource.crearUsuario(datos);
}

@override
Future<bool> editarUsuario(int id, Map<String, dynamic> datos) {
  return datasource.editarUsuario(id, datos);
}

@override
Future<bool> eliminarUsuario(int id) {
  return datasource.eliminarUsuario(id);
}
}