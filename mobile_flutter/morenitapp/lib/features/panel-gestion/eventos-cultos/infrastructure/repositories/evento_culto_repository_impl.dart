import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/datasources/evento_culto_datasource.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/evento.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/organizador.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/repositories/evento_culto_repository.dart';

class EventoCultoRepositoryImpl extends EventoCultoRepository {
  final EventoCultoDatasource datasource;

  EventoCultoRepositoryImpl(this.datasource);

  @override
  Future<List<Evento>> getEventos() => datasource.getEventos();

  @override
  Future<bool> crearEvento(Map<String, dynamic> datos) => datasource.crearEvento(datos);

  @override
  Future<bool> editarEvento(int id, Map<String, dynamic> datos) => datasource.editarEvento(id, datos);

  @override
  Future<bool> eliminarEvento(int id) => datasource.eliminarEvento(id);

  @override
  Future<List<Organizador>> getOrganizadores() => datasource.getOrganizadores();

  @override
  Future<bool> crearOrganizador(Map<String, dynamic> datos) => datasource.crearOrganizador(datos);

  @override
  Future<bool> editarOrganizador(int id, Map<String, dynamic> datos) => datasource.editarOrganizador(id, datos);

  @override
  Future<bool> eliminarOrganizador(int id) => datasource.eliminarOrganizador(id);
}