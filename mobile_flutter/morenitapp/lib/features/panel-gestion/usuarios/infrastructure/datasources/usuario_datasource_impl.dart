// usuario_datasource_impl.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/domain/datasources/usuario_datasource.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:morenitapp/features/auth/infrastructure/mappers/user_mapper.dart';

class UsuarioDatasourceImpl extends UsuarioDatasource {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
  ));


  @override
  Future<List<User>> getUsuarios() async {
    try {
      final response = await dio.post('/usuarios', data: {"params": {}});
      final res = response.data['result'];

      if (res == null || res['success'] == false) {
        throw CustomError(res?['error'] ?? 'Error al obtener usuarios');
      }

      final List list = res['usuarios'] ?? [];
      return list.map((u) => User.fromJson(u)).toList();
    } catch (e) {
      if (e is DioException) throw CustomError('Error de red: ${e.message}');
      rethrow;
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
    try {
      if (datos.containsKey('hermano_id') && datos['hermano_id'] != null) {
        datos['hermano_id'] =
            int.tryParse(datos['hermano_id'].toString()) ?? datos['hermano_id'];
      }

      final payload = {"id": id, ...datos};
      debugPrint('>>> [editarUsuario] POST /usuarios/update payload=$payload');

      final response =
          await dio.post('/usuarios/update', data: {"params": payload});

      debugPrint('>>> [editarUsuario] respuesta raw: ${response.data}');

      final res = response.data['result'];

      if (res == null) {
        debugPrint('>>> [editarUsuario] ERROR: result es null');
        return false;
      }

      if (res['success'] != true) {
        debugPrint('>>> [editarUsuario] ERROR de Odoo: ${res['error'] ?? res}');
        return false;
      }

      debugPrint('>>> [editarUsuario] OK');
      return true;
    } on DioException catch (e) {
      debugPrint(
          '>>> [editarUsuario] DioException: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      debugPrint('>>> [editarUsuario] Exception inesperada: $e');
      return false;
    }
  }

  @override
  Future<bool> eliminarUsuario(int id) async {
    final response = await dio.post('/usuarios/delete', data: {
      "params": {"id": id}
    });
    return response.data['result']['success'] == true;
  }

  // ---------------- AUTH ----------------

  @override
  Future<User> checkAuthStatus(String token) async {
    try {
      // El token es el ID del usuario como String
      final int? userId = int.tryParse(token);
      if (userId == null) throw CustomError('Token inválido');

      debugPrint('>>> [checkAuthStatus] Buscando usuario id=$userId');

      final response = await dio.post('/usuarios', data: {
        "params": {
          "domain": [
            ["id", "=", userId]
          ]
        }
      });

      debugPrint('>>> [checkAuthStatus] respuesta raw: ${response.data}');

      final res = response.data['result'];

      if (res == null) throw CustomError('Respuesta vacía de Odoo');
      if (res['usuarios'] == null || (res['usuarios'] as List).isEmpty) {
        throw CustomError('Sesión no válida');
      }

      final user = UserMapper.userJsonToEntity(res['usuarios'][0]);
      debugPrint('>>> [checkAuthStatus] numeroHermano=${user.numeroHermano}');
      return user;
    } on DioException catch (e) {
      debugPrint(
          '>>> [checkAuthStatus] DioException: ${e.response?.data ?? e.message}');
      throw CustomError('Error de red');
    } catch (e) {
      debugPrint('>>> [checkAuthStatus] Exception: $e');
      rethrow;
    }
  }
}
