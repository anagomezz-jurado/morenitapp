import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/evento.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/organizador.dart';

abstract class EventoCultoDatasource {
  // Organizadores
  Future<List<Organizador>> getOrganizadores();
  Future<bool> crearOrganizador(Map<String, dynamic> datos);
  Future<bool> editarOrganizador(int id, Map<String, dynamic> datos);
  Future<bool> eliminarOrganizador(int id);

  // Eventos
  Future<List<Evento>> getEventos();
  Future<bool> crearEvento(Map<String, dynamic> datos);
  Future<bool> editarEvento(int id, Map<String, dynamic> datos);
  Future<bool> eliminarEvento(int id);
}