import 'package:dio/dio.dart';

// Config & Constants
import 'package:morenitapp/config/constants/environment.dart';

// Domain (Entities & Datasources)
import 'package:morenitapp/features/auth/domain/datasources/auth_datasource.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';

// Infrastructure (Errors & Mappers)
import 'package:morenitapp/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:morenitapp/features/auth/infrastructure/mappers/user_mapper.dart';

class AuthDataSourceImpl extends AuthDataSource {
  
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
  ));

  // AUTHENTICATION METHODS
  @override
  Future<User> login(String email, String password) async {
    try {
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

      return User.fromJson(res['user']); 
    } on DioException catch (e) {
      throw CustomError('Error de red: ${e.message}');
    } catch (e) {
      if (e is CustomError) rethrow;
      throw CustomError('Error inesperado en login: $e');
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
  }) async {
    try {
      final response = await dio.post('/registrar', data: {
        "params": {
          'email': email,
          'contrasena': password,
          'nombre': nombre,
          'apellido1': apellido1,
          'apellido2': apellido2,
          'telefono': telefono,
          'recibirNotiEmail': recibirNotiEmail,
        }
      });

      final res = response.data['result'];
      
      if (res['success'] == false) {
        throw CustomError(res['error'] ?? 'Error en registro');
      }

      return UserMapper.userJsonToEntity(res['user']);
    } on DioException catch (e) {
      throw CustomError('Error de red: ${e.message}');
    } catch (e) {
      throw CustomError('Error en el proceso de registro');
    }
  }

  @override
  Future<User> checkAuthStatus(String token) async {
    try {
      final response = await dio.post('/usuarios', data: {
        "params": {
          "domain": [["id", "=", int.parse(token)]],
        }
      });

      final res = response.data['result'];
      
      if (res == null || res['success'] == false || (res['usuarios'] as List).isEmpty) {
        throw CustomError('Sesión no válida');
      }

      return UserMapper.userJsonToEntity(res['usuarios'][0]);
    } catch (e) {
      throw CustomError('Error de verificación de token');
    }
  }

  // USER MANAGEMENT METHODS
  @override
  Future<List<User>> getUsuarios() async {
    try {
      final response = await dio.post('/usuarios', data: {"params": {}});
      final res = response.data['result'];

      if (res['success'] == false) {
        throw CustomError(res['error'] ?? 'Error al listar usuarios');
      }

      final List list = res['usuarios'] ?? [];
      return list.map((u) => UserMapper.userJsonToEntity(u)).toList();
    } on DioException catch (_) {
      throw CustomError('Error de conexión al servidor');
    } catch (e) {
      throw CustomError('Error al obtener la lista de usuarios');
    }
  }
}