import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/autoridad.dart';
import '../../domain/entities/cargo.dart';
import '../../domain/entities/cofradia.dart';
import '../../domain/repositories/secretaria_repository.dart';
// IMPORTANTE: Solo importa la implementación del DS y del REPO una vez
import '../../infrastructure/datasources/secretaria_datasource_impl.dart';
import '../../infrastructure/repositories/secretaria_repository_impl.dart';

// 1. Providers de Infraestructura
final secretariaDatasourceProvider = Provider<SecretariaDatasourceImpl>((ref) {
  return SecretariaDatasourceImpl();
});

final secretariaRepositoryProvider = Provider<SecretariaRepository>((ref) {
  final datasource = ref.watch(secretariaDatasourceProvider);
  return SecretariaRepositoryImpl(datasource); // Ahora sí lo encontrará
});

// ... resto del código del notifier que ya tenías

// --- 2. NOTIFIER GENÉRICO ---

class SecretariaNotifier<T> extends StateNotifier<AsyncValue<List<T>>> {
  final Future<List<T>> Function() fetch;
  final Future<void> Function(Map<String, dynamic> data) save;
  final Future<void> Function(int id) delete;

  SecretariaNotifier({
    required this.fetch,
    required this.save,
    required this.delete,
  }) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    // Si ya tenemos datos y hay un error previo, limpiamos el error con loading
    if (state.hasError) state = const AsyncValue.loading();
    
    // AsyncValue.guard captura automáticamente errores de red
    state = await AsyncValue.guard(() => fetch());
  }

  Future<void> guardar(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => save(data));
    
    // Si la operación fue exitosa, refrescamos la lista
    result.when(
      data: (_) => refresh(),
      error: (e, st) => state = AsyncValue.error(e, st),
      loading: () => state = const AsyncValue.loading(),
    );
  }

  Future<void> eliminar(int id) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => delete(id));
    
    result.when(
      data: (_) => refresh(),
      error: (e, st) => state = AsyncValue.error(e, st),
      loading: () => state = const AsyncValue.loading(),
    );
  }
}


// --- 3. STATE NOTIFIER PROVIDERS ---

// Nota: He añadido los tipos explícitos <Notifier, Estado> para evitar errores de compilación
final autoridadesProvider = StateNotifierProvider<SecretariaNotifier<Autoridad>, AsyncValue<List<Autoridad>>>((ref) {
  final repository = ref.watch(secretariaRepositoryProvider);
  return SecretariaNotifier<Autoridad>(
    fetch: repository.getAutoridades,
    save: repository.upsertAutoridad,
    delete: (id) => repository.deleteRegistro('morenitapp.autoridad', id),
  );
});

final cargosProvider = StateNotifierProvider<SecretariaNotifier<Cargo>, AsyncValue<List<Cargo>>>((ref) {
  final repository = ref.watch(secretariaRepositoryProvider);
  return SecretariaNotifier<Cargo>(
    fetch: repository.getCargos,
    save: repository.upsertCargo,
    delete: (id) => repository.deleteRegistro('morenitapp.cargo', id),
  );
});

final cofradiasProvider = StateNotifierProvider<SecretariaNotifier<Cofradia>, AsyncValue<List<Cofradia>>>((ref) {
  final repository = ref.watch(secretariaRepositoryProvider);
  return SecretariaNotifier<Cofradia>(
    fetch: repository.getCofradias,
    save: repository.upsertCofradia,
    delete: (id) => repository.deleteRegistro('morenitapp.cofradia', id),
  );
});