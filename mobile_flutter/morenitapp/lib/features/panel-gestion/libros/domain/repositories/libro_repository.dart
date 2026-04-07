import '../entities/libro.dart';

abstract class LibroRepository {
  
  /// Obtiene la lista completa de libros desde el servidor
  Future<List<Libro>> getLibros();

  /// Crea un nuevo libro enviando un mapa de datos (incluyendo Base64 del archivo si existe)
  /// Retorna [true] si la operación en Odoo fue exitosa
  Future<bool> crearLibro(Map<String, dynamic> datos);

  /// Elimina un libro permanentemente por su ID
  Future<bool> eliminarLibro(int id);

  /// (Opcional) Obtiene un libro específico por su ID con todo su detalle de anunciantes
  // Future<Libro> getLibroById(int id);
  
  /// (Opcional) Actualiza los datos de un libro existente
  // Future<bool> editarLibro(int id, Map<String, dynamic> datos);
}