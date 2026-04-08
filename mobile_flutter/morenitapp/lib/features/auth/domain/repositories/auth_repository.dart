import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);

  Future<User> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido1,
    required String apellido2,
    required String telefono,
    required bool recibirNotiEmail,
    required bool recibirNotiTelefono,
  });

  Future<User> checkAuthStatus(String token);
}