import 'package:morenitapp/features/panel-gestion/libros/domain/repositories/libro_repository.dart';
import '../../domain/datasources/libro_datasource.dart';
import '../../domain/entities/libro.dart';

class LibroRepositoryImpl extends LibroRepository {
  final LibroDatasource datasource;

  LibroRepositoryImpl(this.datasource);

  @override
  Future<List<Libro>> getLibros() => datasource.getLibros();

  @override
  Future<bool> crearLibro(Map<String, dynamic> datos) =>
      datasource.crearLibro(datos);

  @override
  Future<bool> eliminarLibro(int id) => datasource.eliminarLibro(id);

  @override
  Future<bool> editarLibro(int id, Map<String, dynamic> datos) =>
      datasource.editarLibro(id, datos);
}
