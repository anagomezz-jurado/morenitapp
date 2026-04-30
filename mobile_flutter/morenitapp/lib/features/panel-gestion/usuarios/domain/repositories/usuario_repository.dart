import 'package:morenitapp/features/auth/domain/entities/user.dart';

abstract class UsuarioRepository {

  //  USUARIOS
  Future<List<User>> getUsuarios(); // <-- Añadir esto
  Future<bool> crearUsuario(Map<String, dynamic> datos);
  Future<bool> editarUsuario(int id, Map<String, dynamic> datos);
  Future<bool> eliminarUsuario(int id);


}