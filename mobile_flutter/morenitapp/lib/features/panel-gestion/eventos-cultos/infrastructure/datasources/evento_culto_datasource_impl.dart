import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/notificacion.dart';
import '../../domain/datasources/evento_culto_datasource.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/organizador.dart';

class EventoCultoDatasourceImpl extends EventoCultoDatasource {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    connectTimeout: const Duration(seconds: 7),
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  Future<dynamic> _get(String path) async {
    final response = await dio.get(path);
    return response.data;
  }

  // --- EVENTOS ---
  @override
  Future<List<Evento>> getEventos() async {
    try {

      final response = await dio.get('/eventos');
      if (response.data == null) {
        return [];
      }

      final List<dynamic> data = response.data;

      final lista = data
          .map((json) {
            try {
              return Evento.fromJson(json);
            } catch (e) {
              return null;
            }
          })
          .whereType<Evento>()
          .toList();

      return lista;
    } on DioException catch (e) {
      print('DioError getEventos: ${e.requestOptions.uri}');
      rethrow;
    } catch (e) {
      print('!!! ERROR INESPERADO: $e');
      rethrow;
    }
  }

  @override
  Future<bool> crearEvento(Map<String, dynamic> datos) async {
    try {
      final response = await dio.post('/eventos', data: datos);
      return response.data['success'] == true;
    } catch (e) {
      print('Error crearEvento: $e');
      return false;
    }
  }

  @override
  Future<bool> editarEvento(int id, Map<String, dynamic> datos) async {
    try {
      final response = await dio.put('/eventos/$id', data: datos);
      return response.data['success'] == true;
    } catch (e) {
      print('Error editarEvento: $e');
      return false;
    }
  }

  @override
  Future<bool> eliminarEvento(int id) async {
    try {
      final response = await dio.delete('/eventos/$id');
      return response.data['success'] == true;
    } catch (e) {
      print('Error eliminarEvento: $e');
      return false;
    }
  }

  // --- ORGANIZADORES ---
  @override
  Future<List<Organizador>> getOrganizadores() async {
    try {
      final result = await _get('/organizadores');

      final List data = result is List ? result : [];

      return data.map((o) => Organizador.fromJson(o)).toList();
    } on DioException catch (e) {
      print('DioError Organizadores: ${e.requestOptions.uri}');
      throw Exception('Error de conexión con organizadores');
    } catch (e) {
      throw Exception('Error al obtener organizadores: $e');
    }
  }

  @override
  Future<bool> crearOrganizador(Map<String, dynamic> datos) async {
    try {
      final response = await dio.post('/organizadores', data: datos);
      return response.data['success'] == true;
    } on DioException catch (e) {
      print('Error al crear organizador: ${e.response?.data}');
      return false;
    }
  }

  @override
  Future<bool> editarOrganizador(int id, Map<String, dynamic> datos) async {
    try {
      final response = await dio.put('/organizadores/$id', data: datos);
      return response.data['success'] == true;
    } on DioException catch (e) {
      print('Error al editar organizador: ${e.response?.data}');
      return false;
    }
  }

  @override
  Future<bool> eliminarOrganizador(int id) async {
    try {
      final response = await dio.delete('/organizadores/$id');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // --- NOTIFICACIONES ---
  @override
  Future<List<Notificacion>> getNotificaciones() async {
    try {
      final response = await dio.get('/notificaciones');
      final dynamic raw = response.data;
      print(
          '*** URL notificaciones: ${dio.options.baseUrl}/notificaciones ***');
      List<dynamic> data;
      if (raw is List) {
        data = raw;
      } else if (raw is Map && raw.containsKey('result')) {
        data = raw['result'] as List<dynamic>;
      } else {
        print('Formato inesperado en notificaciones: $raw');
        return [];
      }

      return data.map((json) => Notificacion.fromJson(json)).toList();
    } catch (e) {
      print('Error getNotificaciones: $e');
      return [];
    }
  }

  @override
  Future<bool> crearNotificacion(Notificacion noti) async {
    try {
      final response = await dio.post('/notificaciones', data: noti.toJson());
      return response.statusCode == 200;
    } catch (e) {
      print('Error crearNotificacion: $e');
      return false;
    }
  }

  @override
  Future<bool> eliminarNotificacion(int id) async {
    try {
      final response = await dio.delete('/notificaciones/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<DestinatarioInfo>> getUsuariosConEmail() async {
    try {
      final response = await dio.post('/usuarios', data: {"params": {}});

      final res = response.data['result'];
      if (res == null || res['success'] == false) return [];

      final List list = res['usuarios'] ?? [];

      return list
          .where((u) =>
              u['recibirNotiEmail'] == true &&
              u['email'] != null &&
              u['email'].toString().isNotEmpty)
          .map((u) => DestinatarioInfo(
                id: u['id'] is int
                    ? u['id']
                    : int.tryParse(u['id'].toString()) ?? 0,
                nombre: u['nombre'] ?? '',
                email: u['email'] ?? '',
              ))
          .toList();
    } catch (e) {
      print('Error getUsuariosConEmail: $e');
      return [];
    }
  }
}
