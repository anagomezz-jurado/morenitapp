import '../entities/evento.dart';
import '../entities/organizador.dart';

abstract class EventoCultoRepository {
  
  // --- MÉTODOS PARA ORGANIZADORES ---
  
  /// Obtiene la lista completa de organizadores desde el servidor
  Future<List<Organizador>> getOrganizadores();

  /// Crea un nuevo organizador. Recibe un mapa con los campos técnicos de Odoo
  Future<bool> crearOrganizador(Map<String, dynamic> datos);

  /// Actualiza un organizador existente por su ID
  Future<bool> editarOrganizador(int id, Map<String, dynamic> datos);

  /// Elimina un organizador por su ID
  Future<bool> eliminarOrganizador(int id);


  // --- MÉTODOS PARA EVENTOS ---

  /// Obtiene la lista de todos los eventos programados
  Future<List<Evento>> getEventos();

  /// Crea un evento (Culto, Procesión, etc.)
  Future<bool> crearEvento(Map<String, dynamic> datos);

  /// Edita los detalles de un evento
  Future<bool> editarEvento(int id, Map<String, dynamic> datos);

  /// Elimina un evento del sistema
  Future<bool> eliminarEvento(int id);
}