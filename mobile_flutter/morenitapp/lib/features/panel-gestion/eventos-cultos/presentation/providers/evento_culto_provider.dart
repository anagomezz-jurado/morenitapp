import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/notificacion.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/presentation/providers/usuarios_provider.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/organizador.dart';
import '../../infrastructure/datasources/evento_culto_datasource_impl.dart';
import '../../infrastructure/repositories/evento_culto_repository_impl.dart';

final eventoCultoRepositoryProvider = Provider((ref) {
  return EventoCultoRepositoryImpl(EventoCultoDatasourceImpl());
});

final eventosProvider =
    AsyncNotifierProvider<EventosNotifier, List<Evento>>(EventosNotifier.new);
final organizadoresProvider =
    AsyncNotifierProvider<OrganizadoresNotifier, List<Organizador>>(
        OrganizadoresNotifier.new);
final notificacionesProvider =
    AsyncNotifierProvider<NotificacionesNotifier, List<Notificacion>>(
        NotificacionesNotifier.new);

class EventosNotifier extends AsyncNotifier<List<Evento>> {
  @override
  Future<List<Evento>> build() async {
    return ref.watch(eventoCultoRepositoryProvider).getEventos();
  }

  Future<void> crear(Map<String, dynamic> datos) async {
    state = const AsyncValue.loading();
    try {
      final success =
          await ref.read(eventoCultoRepositoryProvider).crearEvento(datos);
      if (success) ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> editar(int id, Map<String, dynamic> datos) async {
    state = const AsyncValue.loading();
    try {
      final success =
          await ref.read(eventoCultoRepositoryProvider).editarEvento(id, datos);
      if (success) ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> eliminar(int id) async {
    try {
      final success =
          await ref.read(eventoCultoRepositoryProvider).eliminarEvento(id);
      if (success) ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class OrganizadoresNotifier extends AsyncNotifier<List<Organizador>> {
  @override
  Future<List<Organizador>> build() async {
    return ref.watch(eventoCultoRepositoryProvider).getOrganizadores();
  }

  Future<void> crear(Map<String, dynamic> datos) async {
    state = const AsyncValue.loading();
    try {
      final success =
          await ref.read(eventoCultoRepositoryProvider).crearOrganizador(datos);
      if (success) ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> editar(int id, Map<String, dynamic> datos) async {
    state = const AsyncValue.loading();
    try {
      final success = await ref
          .read(eventoCultoRepositoryProvider)
          .editarOrganizador(id, datos);
      if (success) ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> eliminar(int id) async {
    try {
      final success =
          await ref.read(eventoCultoRepositoryProvider).eliminarOrganizador(id);
      if (success) ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class NotificacionesNotifier extends AsyncNotifier<List<Notificacion>> {
  @override
  Future<List<Notificacion>> build() async {
    return ref.watch(eventoCultoRepositoryProvider).getNotificaciones();
  }

  Future<bool> enviar(Notificacion noti) async {
    state = const AsyncValue.loading();
    try {
      final success =
          await ref.read(eventoCultoRepositoryProvider).crearNotificacion(noti);
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
      final success = await ref
          .read(eventoCultoRepositoryProvider)
          .eliminarNotificacion(id);
      if (success) ref.invalidateSelf();
      return success;
    } catch (e) {
      return false;
    }
  }
}

final listaEventosRecientes = Provider<List<Evento>>((ref) {
  final estado = ref.watch(eventosProvider);
  return estado.maybeWhen(
    data: (lista) => lista,
    orElse: () => [],
  );
});

final usuariosConEmailProvider = Provider<List<DestinatarioInfo>>((ref) {
  // 1. Observamos el provider que ya tiene a todos los usuarios
  final usuariosAsync = ref.watch(usuariosListadoProvider);

  // 2. Extraemos los datos de forma segura cuando estén listos
  return usuariosAsync.maybeWhen(
    data: (usuarios) {
      // 3. Filtramos por 'recibirNotiEmail' que es el campo de tu entidad User
      return usuarios
          .where((u) => u.recibirNotiEmail == true) 
          .map((u) => DestinatarioInfo(
                // Convertimos el String id a int, si falla usamos 0
                id: int.tryParse(u.id) ?? 0, 
                nombre: u.fullName, 
                email: u.email,
              ))
          .toList();
    },
    // Si todavía está cargando o hay error, devolvemos lista vacía
    orElse: () => [], 
  );
});