import 'package:morenitapp/features/panel-gestion/libros/domain/entities/libro.dart';

abstract class LibroDatasource {
  Future<List<Libro>> getLibros();
  Future<bool> crearLibro(Map<String, dynamic> datos);
  Future<bool> eliminarLibro(int id);
}