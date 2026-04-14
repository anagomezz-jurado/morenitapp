import '../entities/libro.dart';

abstract class LibroRepository {
  Future<List<Libro>> getLibros();
  Future<bool> crearLibro(Map<String, dynamic> datos);
  Future<bool> editarLibro(int id, Map<String, dynamic> datos); // <-- AÑADIR ESTA LÍNEA
  Future<bool> eliminarLibro(int id);
}