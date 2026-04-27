import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/features/auth/domain/datasources/auth_datasource.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/domain/datasources/usuario_datasource.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/domain/entities/grupo_user.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:morenitapp/features/auth/infrastructure/mappers/user_mapper.dart';

class UsuarioDatasourceImpl extends UsuarioDatasource {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
  ));

  // ---------------- USUARIOS ----------------

 @override
Future<List<User>> getUsuarios() async {
  try {
    // IMPORTANTE: Asegúrate de que la ruta en Odoo sea /api/usuarios
    final response = await dio.post('/usuarios', data: {"params": {}});
    
    // Odoo responde con { "result": { "success": true, "usuarios": [...] } }
    final res = response.data['result'];

    if (res == null || res['success'] == false) {
      throw CustomError(res?['error'] ?? 'Error al obtener usuarios');
    }

    final List list = res['usuarios'] ?? [];
    return list.map((u) => User.fromJson(u)).toList();
  } catch (e) {
    if (e is DioException) throw CustomError('Error de red: ${e.message}');
    throw CustomError('Error: $e');
  }
}

  @override
  Future<bool> crearUsuario(Map<String, dynamic> datos) async {
    final response =
        await dio.post('/usuarios/create', data: {"params": datos});
    return response.data['result']['success'] == true;
  }

  @override
  Future<bool> editarUsuario(int id, Map<String, dynamic> datos) async {
    // Añadimos el ID al cuerpo de los parámetros
    final Map<String, dynamic> params = {...datos, "id": id};
    final response =
        await dio.post('/usuarios/update', data: {"params": params});
    return response.data['result']['success'] == true;
  }

  @override
  Future<bool> eliminarUsuario(int id) async {
    final response = await dio.post('/usuarios/delete', data: {
      "params": {"id": id}
    });
    return response.data['result']['success'] == true;
  }

  // ---------------- GRUPOS ----------------

  @override
  Future<List<Grupo>> getGrupos() async {
    final response = await dio.post('/grupos', data: {"params": {}});
    final List list = response.data['result']['grupos'] ?? [];
    return list.map((g) => Grupo.fromJson(g)).toList();
  }

  @override
  Future<void> crearGrupo(String nombre) async {
    await dio.post('/grupos/create', data: {
      "params": {"nombre": nombre}
    });
  }

  @override
  Future<void> editarGrupo(int id, String nombre) async {
    await dio.post('/grupos/update', data: {
      "params": {"id": id, "nombre": nombre}
    });
  }

  @override
  Future<void> eliminarGrupo(int id) async {
    await dio.post('/grupos/delete', data: {
      "params": {"id": id}
    });
  }


  @override
  Future<User> checkAuthStatus(String token) async {
    try {
      // Si tu token es un UUID (String), no puedes hacer int.parse(token)
      // Deberías buscar por una columna 'token' en tu modelo de Odoo,
      // o si el token es el ID, enviarlo como entero desde el origen.

      final response = await dio.post('/usuarios', data: {
        "params": {
          "domain": [
            ["id", "=", token]
          ] // Removido int.parse si el ID viene ya como int o si usas UUID
        }
      });

      final res = response.data['result'];
      if (res == null || res['usuarios'].isEmpty)
        throw CustomError('Sesión no válida');

      return UserMapper.userJsonToEntity(res['usuarios'][0]);
    } catch (e) {
      throw CustomError('Error de autenticación');
    }
  }
  
}
