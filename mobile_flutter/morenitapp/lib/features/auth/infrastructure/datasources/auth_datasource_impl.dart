import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/features/auth/domain/datasources/auth_datasource.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/domain/entities/grupo_user.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:morenitapp/features/auth/infrastructure/mappers/user_mapper.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
  ));

  // ---------------- USUARIOS ----------------

  @override
  Future<List<User>> getUsuarios() async {
    try {
      final response = await dio.post('/usuarios', data: {"params": {}});
      final res = response.data['result'];

      if (res['success'] == false)
        throw CustomError(res['error'] ?? 'Error al listar');

      final List list = res['usuarios'] ?? [];
      return list.map((u) => UserMapper.userJsonToEntity(u)).toList();
    } catch (e) {
      throw CustomError('Error de conexión');
    }
  }

@override
Future<User> login(String email, String password) async {
  try {
    // IMPORTANTE: La ruta debe coincidir con @http.route de Odoo
    final response = await dio.post('/login', data: {
      "params": {
        'email': email.trim(),
        'contrasena': password.trim()
      }
    });

    final res = response.data['result'];
    if (res == null || res['success'] == false) {
      throw CustomError(res?['error'] ?? 'Credenciales incorrectas');
    }

    // El JSON ahora trae res['user'], que coincide con User.fromJson
    return User.fromJson(res['user']); 
  } on DioException catch (e) {
    throw CustomError('Error de red: ${e.message}');
  } catch (e) {
    throw CustomError('Error: $e');
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
    final response = await dio.post('/registrar', data: {
      "params": {
        'email': email,
        'contrasena': password,
        'nombre': nombre,
        'apellido1': apellido1,
        'apellido2': apellido2,
        'telefono': telefono,
        'recibirNotiEmail': recibirNotiEmail,
        'recibirNotiTelefono': recibirNotiTelefono,
      }
    });

    final res = response.data['result'];
    if (res['success'] == false)
      throw CustomError(res['error'] ?? 'Error en registro');

    return UserMapper.userJsonToEntity(res['user']);
  }
// --- AuthDataSourceImpl (Flutter) ---
@override
Future<User> checkAuthStatus(String token) async {
  try {
    final response = await dio.post('/usuarios', data: {
      "params": {
        "domain": [["id", "=", int.parse(token)]],
        // SIN "fields" — que Odoo devuelva todo
      }
    });

    final res = response.data['result'];
    if (res == null || res['success'] == false || res['usuarios'].isEmpty) {
      throw CustomError('Sesión no válida');
    }

    return UserMapper.userJsonToEntity(res['usuarios'][0]);
  } catch (e) {
    throw CustomError('Error de autenticación');
  }
}
}
