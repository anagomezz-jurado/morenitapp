import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/features/auth/domain/datasources/auth_datasource.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:morenitapp/features/auth/infrastructure/mappers/user_mapper.dart';

class AuthDataSourceImpl extends AuthDataSource {
  
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    // Aumentamos los tiempos de espera para evitar errores de red prematuros
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  @override
  Future<User> register(String email, String password, String fullName) async {
    try {
      // NOTA: Odoo con type='json' espera que los datos vayan dentro de un objeto "params"
      final response = await dio.post('/registrar', data: {
        "params": {
          'email': email.trim(),
          'contrasena': password,
          'nombre': fullName.trim(),
          'rol_id': 2,
        }
      });

      // Extraemos la data de Odoo (Odoo mete todo en 'result')
      final responseData = response.data['result'] ?? response.data;

      if (responseData['success'] == false) {
        throw CustomError(responseData['error'] ?? 'Error en el registro');
      }

      return UserMapper.userJsonToEntity(responseData);
      
    } on DioException catch (e) {
      // Debug detallado para que veas el error en la consola
      print('--- ERROR DE RED ---');
      print('Status Code: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout) throw CustomError('Servidor no responde (Timeout)');
      if (e.type == DioExceptionType.connectionError) throw CustomError('No se pudo conectar al servidor. Revisa la IP.');
      
      throw CustomError('Error de red: ${e.message}');
    } catch (e) {
      throw CustomError('Error inesperado: $e');
    }
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dio.post('/login', data: {
        "params": {
          'email': email.trim(), 
          'contrasena': password
        }
      });

      final responseData = response.data['result'] ?? response.data;

      if (responseData['success'] == false) {
        throw CustomError(responseData['error'] ?? 'Credenciales incorrectas');
      }

      return UserMapper.userJsonToEntity(responseData);

    } on DioException {
      throw CustomError('Error de conexión con Odoo');
    } catch (e) {
      throw CustomError('Error en el login');
    }
  }
  @override
  Future<User> checkAuthStatus(String token) async {
    try {
      // Usamos el endpoint de listado filtrando por ID (que es nuestro token)
      final response = await dio.post('/usuarios', data: {
        "params": {
          "domain": [["id", "=", int.parse(token)]]
        }
      });

      final responseData = response.data['result'] ?? response.data;
      
      if (responseData['success'] == false || (responseData['usuarios'] as List).isEmpty) {
        throw CustomError('Sesión no válida');
      }

      // Mapeamos el primer usuario encontrado
      return UserMapper.userJsonToEntity(responseData['usuarios'][0]);

    } catch (e) {
      throw CustomError('No se pudo verificar la sesión');
    }
  }
}