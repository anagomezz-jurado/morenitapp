import 'package:morenitapp/features/panel-gestion/usuarios/domain/entities/grupo_user.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';

abstract class UsuarioDatasource {

  //  USUARIOS
Future<List<User>> getUsuarios(); // <-
  Future<bool> crearUsuario(Map<String, dynamic> datos);
  Future<bool> editarUsuario(int id, Map<String, dynamic> datos);
  Future<bool> eliminarUsuario(int id);

  // GRUPOS
  Future<List<Grupo>> getGrupos();
  Future<void> crearGrupo(String nombre);
  Future<void> editarGrupo(int id, String nombre);
  Future<void> eliminarGrupo(int id);
}