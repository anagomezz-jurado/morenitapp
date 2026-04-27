import 'package:morenitapp/features/auth/domain/datasources/auth_datasource.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/domain/entities/grupo_user.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:morenitapp/features/auth/infrastructure/datasources/auth_datasource_impl.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({AuthDataSource? dataSource})
      : dataSource = dataSource ?? AuthDataSourceImpl();

  @override
  Future<User> checkAuthStatus(String token) {
    return dataSource.checkAuthStatus(token);
  }

  @override
  Future<List<User>> getUsuarios() {
    return dataSource.getUsuarios();
  }

  @override
  Future<User> login(String email, String password) {
    return dataSource.login(email, password);
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido1,
    required String apellido2,
    required String telefono,
    required bool recibirNotiEmail,
    required bool recibirNotiTelefono,
  }) {
    return dataSource.register(
      email: email,
      password: password,
      nombre: nombre,
      apellido1: apellido1,
      apellido2: apellido2,
      telefono: telefono,
      recibirNotiEmail: recibirNotiEmail,
      recibirNotiTelefono: recibirNotiTelefono,
    );
  }


}