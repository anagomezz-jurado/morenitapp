
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/grupo_proveedor.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/notificacion_tipo.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_autoridad.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_cargo.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_evento.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_rol.dart';

abstract class ConfiguracionDatasource {
  // Todas las escrituras reciben Map<String, dynamic> para Odoo
  Future<bool> crearTipoEvento(Map<String, dynamic> datos);
  Future<bool> editarTipoEvento(int id, Map<String, dynamic> datos);
  Future<bool> eliminarTipoEvento(int id);
  Future<List<TipoEvento>> getTiposEvento();

  Future<bool> crearTipoCargo(Map<String, dynamic> datos);
  Future<bool> editarTipoCargo(int id, Map<String, dynamic> datos);
  Future<bool> eliminarTipoCargo(int id);
  Future<List<TipoCargo>> getTiposCargo();

  Future<bool> crearTipoAutoridad(Map<String, dynamic> datos);
  Future<bool> editarTipoAutoridad(int id, Map<String, dynamic> datos);
  Future<bool> eliminarTipoAutoridad(int id);
  Future<List<TipoAutoridad>> getTiposAutoridad();

  Future<bool> crearRol(Map<String, dynamic> datos);
  Future<bool> editarRol(int id, Map<String, dynamic> datos);
  Future<bool> eliminarRol(int id);
  Future<List<Rol>> getRoles();

  Future<List<GrupoProveedor>> getGruposProveedor();
Future<bool> crearGrupoProveedor(Map<String, dynamic> datos);
Future<bool> editarGrupoProveedor(int id, Map<String, dynamic> datos);
Future<bool> eliminarGrupoProveedor(int id);
// --- NOTIFICACIONES TIPO ---
  Future<List<NotificacionTipo>> getNotificacionTipos();
  // Se cambia String por Map para ser consistente con el resto del Datasource
  Future<bool> crearNotificacionTipo(Map<String, dynamic> datos);
  Future<bool> editarNotificacionTipo(int id, Map<String, dynamic> datos);
  Future<bool> eliminarNotificacionTipo(int id);

}