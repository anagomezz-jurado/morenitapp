import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/organizador.dart';
import '../../infrastructure/datasources/evento_culto_datasource_impl.dart';
import '../../infrastructure/repositories/evento_culto_repository_impl.dart';

// 1. Repositorio Provider
final eventoCultoRepositoryProvider = Provider((ref) {
  // Instanciamos el datasource que ya tiene su configuración de Dio interna
  return EventoCultoRepositoryImpl(EventoCultoDatasourceImpl());
});

// 2. Notifiers Principales
final eventosProvider = AsyncNotifierProvider<EventosNotifier, List<Evento>>(EventosNotifier.new);
final organizadoresProvider = AsyncNotifierProvider<OrganizadoresNotifier, List<Organizador>>(OrganizadoresNotifier.new);

// --- NOTIFIER DE EVENTOS ---
class EventosNotifier extends AsyncNotifier<List<Evento>> {
  
  @override
  Future<List<Evento>> build() async {
    return ref.watch(eventoCultoRepositoryProvider).getEventos();
  }

  Future<void> crear(Map<String, dynamic> datos) async {
    state = const AsyncValue.loading();
    try {
      final success = await ref.read(eventoCultoRepositoryProvider).crearEvento(datos);
      if (success) ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> editar(int id, Map<String, dynamic> datos) async {
    state = const AsyncValue.loading();
    try {
      final success = await ref.read(eventoCultoRepositoryProvider).editarEvento(id, datos);
      if (success) ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> eliminar(int id) async {
    try {
      final success = await ref.read(eventoCultoRepositoryProvider).eliminarEvento(id);
      if (success) ref.invalidateSelf();
    } catch (e) {
      // Manejo opcional de error silencioso o state = AsyncError
    }
  }
}

// --- NOTIFIER DE ORGANIZADORES ---
class OrganizadoresNotifier extends AsyncNotifier<List<Organizador>> {
  
  @override
  Future<List<Organizador>> build() async {
    return ref.watch(eventoCultoRepositoryProvider).getOrganizadores();
  }

  Future<void> crear(Map<String, dynamic> datos) async {
    state = const AsyncValue.loading();
    try {
      final success = await ref.read(eventoCultoRepositoryProvider).crearOrganizador(datos);
      if (success) ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> editar(int id, Map<String, dynamic> datos) async {
    state = const AsyncValue.loading();
    try {
      final success = await ref.read(eventoCultoRepositoryProvider).editarOrganizador(id, datos);
      if (success) ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> eliminar(int id) async {
    try {
      final success = await ref.read(eventoCultoRepositoryProvider).eliminarOrganizador(id);
      if (success) ref.invalidateSelf();
    } catch (e) {
      // Manejo de error
    }
  }
}

// --- PROVIDERS DE APOYO (Ejemplo de filtros) ---

final listaEventosRecientes = Provider<List<Evento>>((ref) {
  final estado = ref.watch(eventosProvider);
  return estado.maybeWhen(
    data: (listado) => listado, // Aquí podrías aplicar un .sort o .take(5)
    orElse: () => [],
  );
});