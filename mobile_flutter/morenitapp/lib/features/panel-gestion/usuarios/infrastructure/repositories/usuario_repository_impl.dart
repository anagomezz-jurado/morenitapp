import 'package:morenitapp/features/auth/domain/datasources/auth_datasource.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/domain/datasources/usuario_datasource.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/domain/entities/grupo_user.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:morenitapp/features/auth/infrastructure/datasources/auth_datasource_impl.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/domain/repositories/usuario_repository.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/infrastructure/datasources/usuario_datasource_impl.dart';

class UsuarioRepositoryImpl extends UsuarioRepository {
  final UsuarioDatasource dataSource;

  UsuarioRepositoryImpl({UsuarioDatasource? dataSource})
      : dataSource = dataSource ?? UsuarioDatasourceImpl();

  @override
  Future<List<User>> getUsuarios() {
    return dataSource.getUsuarios();
  }

  @override
  Future<bool> crearUsuario(Map<String, dynamic> datos) {
    return dataSource.crearUsuario(datos);
  }

  @override
  Future<bool> editarUsuario(int id, Map<String, dynamic> datos) {
    return dataSource.editarUsuario(id, datos);
  }

  @override
  Future<bool> eliminarUsuario(int id) {
    return dataSource.eliminarUsuario(id);
  }

  // 👇 GRUPOS

  @override
  Future<List<Grupo>> getGrupos() {
    return dataSource.getGrupos();
  }

  @override
  Future<void> crearGrupo(String nombre) {
    return dataSource.crearGrupo(nombre);
  }

  @override
  Future<void> editarGrupo(int id, String nombre) {
    return dataSource.editarGrupo(id, nombre);
  }

  @override
  Future<void> eliminarGrupo(int id) {
    return dataSource.eliminarGrupo(id);
  }
}
