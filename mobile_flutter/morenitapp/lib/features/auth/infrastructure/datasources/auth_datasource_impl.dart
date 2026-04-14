import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/features/auth/domain/datasources/auth_datasource.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:morenitapp/features/auth/infrastructure/mappers/user_mapper.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

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
      final response = await dio.post('/registrar', data: {
        "params": {
          'email': email.trim(),
          'contrasena': password,
          'nombre': nombre,
          'apellido1': apellido1,
          'apellido2': apellido2,
          'telefono': telefono,
          'recibirNotiEmail': recibirNotiEmail,
          'recibirNotiTelefono': recibirNotiTelefono,
          'rol_id': 2,
        }
      });

      // Odoo suele devolver errores dentro de 'result' o directamente en la raíz
      final data = response.data;
      final result = data['result'] ?? data;

      // SI ODOO DEVUELVE SUCCESS FALSE O TIENE CAMPO ERROR
      if (result['success'] == false || data.containsKey('error')) {
        final String errorMsg = result['error']?.toString() ?? data['error']?['message']?.toString() ?? '';
        final String cleanError = errorMsg.toLowerCase();
        
        // DETECCIÓN DE CORREO DUPLICADO
        if (cleanError.contains('email') || cleanError.contains('correo')) {
          throw CustomError('El correo electrónico ya está en uso');
        }

        // DETECCIÓN DE TELÉFONO DUPLICADO (Nueva lógica)
        if (cleanError.contains('telefono') || cleanError.contains('phone') || cleanError.contains('teléfono')) {
          throw CustomError('El número de teléfono ya está registrado');
        }

        // Detección genérica de "Ya existe"
        if (cleanError.contains('already exists') || cleanError.contains('ya existe')) {
          throw CustomError('Los datos ingresados ya pertenecen a otra cuenta');
        }
        
        throw CustomError(errorMsg.isEmpty ? 'Error en el registro' : errorMsg);
      }

      return UserMapper.userJsonToEntity(result);

    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is CustomError) rethrow;
      throw CustomError('Error inesperado: $e');
    }
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dio.post('/login', data: {
        "params": {'email': email.trim(), 'contrasena': password}
      });

      final result = response.data['result'] ?? response.data;

      if (result['success'] == false) {
        throw CustomError(result['error'] ?? 'Credenciales incorrectas');
      }

      return UserMapper.userJsonToEntity(result);
    } on DioException catch (e) {
       _handleDioError(e);
       rethrow;
    } catch (e) {
      if (e is CustomError) rethrow;
      throw CustomError('Error en el login');
    }
  }

  @override
  Future<User> checkAuthStatus(String token) async {
    try {
      final response = await dio.post('/usuarios', data: {
        "params": {
          "domain": [["id", "=", int.parse(token)]]
        }
      });

      final result = response.data['result'] ?? response.data;

      if (result['success'] == false || (result['usuarios'] as List).isEmpty) {
        throw CustomError('Sesión no válida');
      }

      return UserMapper.userJsonToEntity(result['usuarios'][0]);
    } catch (e) {
      throw CustomError('No se pudo verificar la sesión');
    }
  }
@override
  Future<List<User>> getUsuarios() async {
    try {
      // Importante: usar la ruta exacta de tu controlador Odoo
      final response = await dio.post('/usuarios', data: {
        "params": {} // Odoo espera params aunque esté vacío
      });

      final result = response.data['result'] ?? response.data;

      if (result['success'] == false) {
        throw CustomError(result['error'] ?? 'Error al obtener usuarios');
      }

      final List usuariosList = result['usuarios'] ?? [];
      return usuariosList.map((u) => UserMapper.userJsonToEntity(u)).toList();
      
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw CustomError('Error al listar usuarios: $e');
    }
  }
  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) throw CustomError('Tiempo de espera agotado');
    if (e.type == DioExceptionType.connectionError) throw CustomError('Sin conexión al servidor');
    
    // Si Odoo devuelve un error 400/500, intentamos leer el mensaje
   final dynamic errorData = e.response?.data;
    final String serverMessage = (errorData?['result']?['error'] ?? errorData?['error']?['message'] ?? '').toString().toLowerCase();

    if (serverMessage.contains('unique constraint') || serverMessage.contains('already exists')) {
      if (serverMessage.contains('telefono') || serverMessage.contains('phone')) {
        throw CustomError('Este número de teléfono ya está en uso');
      }
      throw CustomError('Este correo electrónico ya está en uso');
    }

    throw CustomError('Error de servidor: $serverMessage');
  }
}