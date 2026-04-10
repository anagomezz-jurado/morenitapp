import 'package:flutter_riverpod/flutter_riverpod.dart';
// Borramos el import de legacy si no es estrictamente necesario para otras partes
import '../../domain/entities/evento.dart';
import '../../domain/entities/organizador.dart';
import '../../infrastructure/datasources/evento_culto_datasource_impl.dart';
import '../../infrastructure/repositories/evento_culto_repository_impl.dart';

// --- 1. REPOSITORIO PROVIDER ---
final eventoCultoRepositoryProvider = Provider((ref) {
  return EventoCultoRepositoryImpl(EventoCultoDatasourceImpl());
});

// --- 2. NOTIFIERS PRINCIPALES ---

// Correcto: AsyncNotifierProvider para clases AsyncNotifier
final eventosProvider = AsyncNotifierProvider<EventosNotifier, List<Evento>>(EventosNotifier.new);

final organizadoresProvider = AsyncNotifierProvider<OrganizadoresNotifier, List<Organizador>>(OrganizadoresNotifier.new);

// NOTA: 'eventoCultoProvider' sobraba porque duplicaba a 'eventosProvider' de forma incorrecta.
// Si necesitas mantener el nombre por compatibilidad, úsalo como un alias:
final eventoCultoProvider = eventosProvider; 


// --- 3. CLASE EVENTOS NOTIFIER ---
class EventosNotifier extends AsyncNotifier<List<Evento>> {
  
  @override
  Future<List<Evento>> build() async {
    // Usamos watch para que si el repositorio cambia (raro), se reconstruya
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
    // No ponemos loading aquí para no congelar la UI si es un borrado rápido, 
    // pero invalidamos al terminar.
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

// --- 5. PROVIDERS DE APOYO ---

final listaEventosRecientes = Provider<List<Evento>>((ref) {
  final estado = ref.watch(eventosProvider);
  return estado.maybeWhen(
    data: (listado) => listado,
    orElse: () => [],
  );
});