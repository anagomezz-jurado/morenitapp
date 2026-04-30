import '../entities/libro.dart';

abstract class LibroDatasource {
  Future<List<Libro>> getLibros();
  Future<bool> crearLibro(Map<String, dynamic> datos);
  Future<bool> editarLibro(int id, Map<String, dynamic> datos);
  Future<bool> eliminarLibro(int id);
}