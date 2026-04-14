import 'package:morenitapp/features/auth/domain/entities/user.dart';

abstract class AuthDataSource {
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
  
  // AÑADIR ESTA LÍNEA
  Future<List<User>> getUsuarios(); 
}