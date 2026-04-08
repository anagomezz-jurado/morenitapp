import 'package:morenitapp/features/auth/domain/datasources/auth_datasource.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/domain/repositories/auth_repository.dart';

import '../infrastructure.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({AuthDataSource? dataSource}) 
    : dataSource = dataSource ?? AuthDataSourceImpl();

  @override
  Future<User> checkAuthStatus(String token) {
    return dataSource.checkAuthStatus(token);
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      return await dataSource.login(email, password);
    } catch (e) {
      // Re-lanzamos la excepción (CustomError) para que llegue al AuthNotifier
      rethrow;
    }
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
  }) async {
    try {
      // Pasamos los parámetros nombrados al data source
      return await dataSource.register(
        email: email,
        password: password,
        nombre: nombre,
        apellido1: apellido1,
        apellido2: apellido2,
        telefono: telefono,
        recibirNotiEmail: recibirNotiEmail,
        recibirNotiTelefono: recibirNotiTelefono,
      );
    } catch (e) {
      // Si el DataSource lanza "El correo ya está en uso", esto lo lanza hacia arriba
      rethrow;
    }
  }
}