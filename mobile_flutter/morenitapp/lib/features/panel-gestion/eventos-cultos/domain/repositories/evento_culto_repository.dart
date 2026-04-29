import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/notificacion.dart';
import '../entities/evento.dart';
import '../entities/organizador.dart';

abstract class EventoCultoRepository {
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

  // Notificaciones
  Future<List<Notificacion>> getNotificaciones();
  Future<bool> crearNotificacion(Notificacion noti);
  Future<bool> eliminarNotificacion(int id);

  // Usuarios con email OK
  Future<List<DestinatarioInfo>> getUsuariosConEmail();
}