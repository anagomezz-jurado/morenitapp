import 'package:morenitapp/features/auth/domain/entities/user.dart';

abstract class UsuarioDatasource {
  //  USUARIOS
  Future<List<User>> getUsuarios(); // <-
  Future<bool> crearUsuario(Map<String, dynamic> datos);
  Future<bool> editarUsuario(int id, Map<String, dynamic> datos);
  Future<bool> eliminarUsuario(int id);


}
