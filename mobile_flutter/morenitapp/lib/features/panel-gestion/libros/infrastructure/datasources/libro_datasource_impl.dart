import 'package:dio/dio.dart';
import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/features/panel-gestion/libros/domain/datasources/libro_datasource.dart';
import '../../domain/entities/libro.dart';

class LibroDatasourceImpl extends LibroDatasource {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    headers: {'Content-Type': 'application/json'},
  ));

  @override
  Future<List<Libro>> getLibros() async {
    try {
      final response = await dio.get('/libros');
      final List data = response.data;
      return data.map((l) => Libro.fromJson(l)).toList();
    } catch (e) {
      throw Exception('Error al obtener libros: $e');
    }
  }

  @override
  Future<bool> crearLibro(Map<String, dynamic> datos) async {
    try {
      final response = await dio.post('/libros', data: datos);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> eliminarLibro(int id) async {
    try {
      final response = await dio.delete('/libros/$id');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}