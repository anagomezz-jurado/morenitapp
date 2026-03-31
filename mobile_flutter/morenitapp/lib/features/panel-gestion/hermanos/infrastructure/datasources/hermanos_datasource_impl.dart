import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/datasources/hermano_datasource.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';

class HermanosDatasourceImpl extends HermanoDatasource {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    },
  ));

  @override
Future<List<Hermano>> getHermanos({int limit = 10, int offset = 0}) async {
  try {
    final response = await dio.get('/hermanos');
    print(response.data); // <-- Mira qué llega exactamente en la consola de debug
    
    final List<dynamic> data = response.data;
    return data.map((hermanoJson) => Hermano.fromJson(hermanoJson)).toList();
  } on DioException catch (e) {
    // Esto te dará más detalles del error real del servidor
    print("DATA ERROR: ${e.response?.data}"); 
    throw CustomError('Error 500: ${e.response?.data['message'] ?? 'Error interno'}');
  }
}

  @override
  Future<Hermano> anadirHermano(Hermano hermano) async {
    try {
      final response = await dio.post('/hermanos', data: jsonEncode(hermano.toJson()));
      
      final res = (response.data is String) ? jsonDecode(response.data) : response.data;

      if (res['status'] == 'success') {
        // Devolvemos el hermano con los datos reales que asignó el servidor
        return Hermano.fromJson({
          ...hermano.toJson(),
          'id': res['id'],
          'codigo_hermano': res['codigo'],
        });
      }
      throw CustomError(res['message'] ?? 'Error del servidor');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Error 500';
      throw CustomError(msg);
    }
  }

  @override
  Future<bool> bajaHermano(String id) async => throw UnimplementedError();
  @override
  Future<Hermano> getHermanoByDni(String dni) async => throw UnimplementedError();
}