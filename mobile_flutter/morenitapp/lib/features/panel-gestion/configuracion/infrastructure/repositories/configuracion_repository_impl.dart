import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/notificacion_tipo.dart';
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

  // --- EVENTOS TIPOS ---
  @override
  Future<List<TipoEvento>> getTiposEvento() => datasource.getTiposEvento();
  @override
  Future<void> crearTipoEvento(
      String codigo, String nombre, String color) async {
    await datasource.crearTipoEvento({
      'cod_tipo_evento': codigo,
      'nombre_tipo_evento': nombre,
      'color': color,
    });
  }

  @override
  Future<void> editarTipoEvento(
      int id, String codigo, String nombre, String color) async {
    await datasource.editarTipoEvento(id, {
      'cod_tipo_evento': codigo,
      'nombre_tipo_evento': nombre,
      'color': color,
    });
  }

  @override
  Future<bool> eliminarTipoEvento(int id) => datasource.eliminarTipoEvento(id);

  // --- CARGOS TIPO ---
  @override
  Future<List<TipoCargo>> getTiposCargo() => datasource.getTiposCargo();

  @override
  Future<bool> crearTipoCargo(
          String codigo, String nombre, String observaciones) =>
      datasource.crearTipoCargo({
        'codTipoCargo': codigo,
        'nombreTipoCargo': nombre,
        'observaciones': observaciones
      });

  @override
  Future<bool> editarTipoCargo(
          int id, String codigo, String nombre, String observaciones) =>
      datasource.editarTipoCargo(id, {
        'codTipoCargo': codigo,
        'nombreTipoCargo': nombre,
        'observaciones': observaciones
      });

  @override
  Future<bool> eliminarTipoCargo(int id) => datasource.eliminarTipoCargo(id);

  // --- AUTORIDADES TIPO ---
  @override
  Future<List<TipoAutoridad>> getTiposAutoridad() =>
      datasource.getTiposAutoridad();

  @override
  Future<bool> crearTipoAutoridad(String codigo, String nombre) =>
      datasource.crearTipoAutoridad(
          {'codTipoAutoridad': codigo, 'nombreTipoAutoridad': nombre});

  @override
  Future<bool> editarTipoAutoridad(int id, String codigo, String nombre) =>
      datasource.editarTipoAutoridad(
          id, {'codTipoAutoridad': codigo, 'nombreTipoAutoridad': nombre});

  @override
  Future<bool> eliminarTipoAutoridad(int id) =>
      datasource.eliminarTipoAutoridad(id);

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
  Future<List<GrupoProveedor>> getGruposProveedor() =>
      datasource.getGruposProveedor();

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
  Future<bool> eliminarGrupoProveedor(int id) =>
      datasource.eliminarGrupoProveedor(id);

  // --- NOTIFICACIONES TIPO  ---
  @override
  Future<List<NotificacionTipo>> getNotificacionTipos() {
    return datasource.getNotificacionTipos();
  }

  @override
  Future<bool> crearNotificacionTipo(String nombre) {
    return datasource.crearNotificacionTipo({'name': nombre});
  }

  @override
  Future<bool> editarNotificacionTipo(int id, String nombre) {
    return datasource.editarNotificacionTipo(id, {'name': nombre});
  }

  @override
  Future<bool> eliminarNotificacionTipo(int id) {
    return datasource.eliminarNotificacionTipo(id);
  }
}
