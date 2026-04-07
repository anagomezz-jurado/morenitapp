import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/grupo_proveedor.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_autoridad.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_cargo.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_evento.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_rol.dart';

abstract class ConfiguracionRepository {
  // --- TIPOS DE EVENTO ---
  Future<bool> crearTipoEvento(String codigo, String nombre);
  Future<bool> editarTipoEvento(int id, String codigo, String nombre);
  Future<bool> eliminarTipoEvento(int id);
  Future<List<TipoEvento>> getTiposEvento();

  // --- TIPOS DE CARGO ---
  Future<bool> crearTipoCargo(String codigo, String nombre, String observaciones);
  Future<bool> editarTipoCargo(int id, String codigo, String nombre, String observaciones);
  Future<bool> eliminarTipoCargo(int id);
  Future<List<TipoCargo>> getTiposCargo();

  // --- TIPOS DE AUTORIDAD ---
  Future<List<TipoAutoridad>> getTiposAutoridad();
  Future<bool> crearTipoAutoridad(String codigo, String nombre);
  Future<bool> editarTipoAutoridad(int id, String codigo, String nombre);
  Future<bool> eliminarTipoAutoridad(int id);

  // --- ROLES ---
  Future<List<Rol>> getRoles();
  Future<bool> crearRol(int codigo, String nombre);
  Future<bool> editarRol(int id, int codigo, String nombre);
  Future<bool> eliminarRol(int id);

  Future<List<GrupoProveedor>> getGruposProveedor();
Future<bool> crearGrupoProveedor(String codigo, String nombre);
Future<bool> editarGrupoProveedor(int id, String codigo, String nombre);
Future<bool> eliminarGrupoProveedor(int id);

Future<List<User>> getUsers();
Future<bool> crearUsuario(Map<String, dynamic> datos);
Future<bool> editarUsuario(int id, Map<String, dynamic> datos);
Future<bool> eliminarUsuario(int id);
}