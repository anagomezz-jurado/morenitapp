import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/organizador.dart';
import '../../infrastructure/datasources/evento_culto_datasource_impl.dart';
import '../../infrastructure/repositories/evento_culto_repository_impl.dart';

// --- 1. REPOSITORIO PROVIDER ---
// Centralizamos la instancia del repositorio para que todos los notifiers la usen.
final eventoCultoRepositoryProvider = Provider((ref) {
  return EventoCultoRepositoryImpl(EventoCultoDatasourceImpl());
});

// --- 2. NOTIFIERS PRINCIPALES ---

// Provider para la lista de Eventos
final eventosProvider = AsyncNotifierProvider<EventosNotifier, List<Evento>>(EventosNotifier.new);

// Provider para la lista de Organizadores
final organizadoresProvider = AsyncNotifierProvider<OrganizadoresNotifier, List<Organizador>>(OrganizadoresNotifier.new);

// Alias para mantener compatibilidad con código antiguo si es necesario
final eventoCultoProvider = eventosProvider; 


// --- 3. CLASE EVENTOS NOTIFIER ---
class EventosNotifier extends AsyncNotifier<List<Evento>> {
  
  @override
  Future<List<Evento>> build() async {
    // Escuchamos el repositorio. Si por alguna razón cambia, se refresca la lista.
    return ref.watch(eventoCultoRepositoryProvider).getEventos();
  }

  Future<void> crear(Map<String, dynamic> datos) async {
    state = const AsyncValue.loading();
    try {
      final success = await ref.read(eventoCultoRepositoryProvider).crearEvento(datos);
      // Si la creación en Odoo fue exitosa, invalidamos el estado para forzar un re-fetch automático
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
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// --- 4. CLASE ORGANIZADORES NOTIFIER ---
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
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// --- 5. PROVIDERS DE APOYO (SÍNCRONOS) ---

// Este provider es útil para obtener la lista actual de eventos sin manejar estados de carga/error
final listaEventosRecientes = Provider<List<Evento>>((ref) {
  final estado = ref.watch(eventosProvider);
  return estado.maybeWhen(
    data: (listado) => listado,
    orElse: () => [],
  );
});