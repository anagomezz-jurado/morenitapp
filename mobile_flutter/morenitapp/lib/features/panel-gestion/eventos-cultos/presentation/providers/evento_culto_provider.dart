import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/notificacion.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/organizador.dart';
import '../../infrastructure/datasources/evento_culto_datasource_impl.dart';
import '../../infrastructure/repositories/evento_culto_repository_impl.dart';

// --- 1. REPOSITORIO PROVIDER ---
final eventoCultoRepositoryProvider = Provider((ref) {
  return EventoCultoRepositoryImpl(EventoCultoDatasourceImpl());
});

// --- 2. PROVIDERS PRINCIPALES ---
final eventosProvider = AsyncNotifierProvider<EventosNotifier, List<Evento>>(EventosNotifier.new);
final organizadoresProvider = AsyncNotifierProvider<OrganizadoresNotifier, List<Organizador>>(OrganizadoresNotifier.new);
final notificacionesProvider = AsyncNotifierProvider<NotificacionesNotifier, List<Notificacion>>(NotificacionesNotifier.new);



// --- 4. EVENTOS NOTIFIER ---
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
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// --- 5. ORGANIZADORES NOTIFIER ---
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

// --- 6. NOTIFICACIONES NOTIFIER ---
class NotificacionesNotifier extends AsyncNotifier<List<Notificacion>> {
  @override
  Future<List<Notificacion>> build() async {
    return ref.watch(eventoCultoRepositoryProvider).getNotificaciones();
  }

  Future<bool> enviar(Notificacion noti) async {
    state = const AsyncValue.loading();
    try {
      final success = await ref.read(eventoCultoRepositoryProvider).crearNotificacion(noti);
      if (success) {
        ref.invalidateSelf();
        return true;
      }
      return false;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> eliminar(int id) async {
    try {
      final success = await ref.read(eventoCultoRepositoryProvider).eliminarNotificacion(id);
      if (success) ref.invalidateSelf();
      return success;
    } catch (e) {
      return false;
    }
  }
}

// --- 7. PROVIDER AUXILIAR ---
final listaEventosRecientes = Provider<List<Evento>>((ref) {
  final estado = ref.watch(eventosProvider);
  return estado.maybeWhen(
    data: (lista) => lista,
    orElse: () => [],
  );
});

// En vez de llamar a un endpoint nuevo, extraemos los destinatarios
// directamente de las notificaciones ya cargadas
final usuariosConEmailProvider = FutureProvider<List<DestinatarioInfo>>((ref) async {
  // Llamamos directamente al datasource que ya tenemos
  final datasource = EventoCultoDatasourceImpl();
  return datasource.getUsuariosConEmail();
});