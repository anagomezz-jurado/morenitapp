import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/autoridad.dart';
import '../../domain/entities/cargo.dart';
import '../../domain/entities/cofradia.dart';
import '../../domain/repositories/secretaria_repository.dart';
import '../../infrastructure/datasources/secretaria_datasource_impl.dart';
import '../../infrastructure/repositories/secretaria_repository_impl.dart';

final secretariaDatasourceProvider = Provider((ref) => SecretariaDatasourceImpl());

final secretariaRepositoryProvider = Provider<SecretariaRepository>((ref) {
  final datasource = ref.watch(secretariaDatasourceProvider);
  return SecretariaRepositoryImpl(datasource);
});

// Providers para Selectores
final tipoCargoProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await ref.watch(secretariaRepositoryProvider).getTiposCargos();
});

// Notifier genérico para CRUD
class SecretariaNotifier<T> extends StateNotifier<AsyncValue<List<T>>> {
  final Future<List<T>> Function() fetch;
  final Future<void> Function(Map<String, dynamic> data) save;
  final Future<void> Function(int id) delete;

  SecretariaNotifier({
    required this.fetch,
    required this.save,
    required this.delete,
  }) : super(const AsyncLoading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => fetch());
  }

  Future<void> guardar(Map<String, dynamic> data) async {
    final result = await AsyncValue.guard(() => save(data));
    if (!result.hasError) await refresh();
  }

  Future<void> eliminar(int id) async {
    final result = await AsyncValue.guard(() => delete(id));
    if (!result.hasError) await refresh();
  }
}

// --- Providers de Estado ---

final autoridadesProvider = StateNotifierProvider<SecretariaNotifier<Autoridad>, AsyncValue<List<Autoridad>>>((ref) {
  final repo = ref.watch(secretariaRepositoryProvider);
  return SecretariaNotifier<Autoridad>(
    fetch: repo.getAutoridades,
    save: repo.upsertAutoridad,
    delete: (id) => repo.deleteRegistro('autoridad', id),
  );
});

final cargosProvider = StateNotifierProvider<SecretariaNotifier<Cargo>, AsyncValue<List<Cargo>>>((ref) {
  final repo = ref.watch(secretariaRepositoryProvider);
  return SecretariaNotifier<Cargo>(
    fetch: repo.getCargos,
    save: repo.upsertCargo,
    delete: (id) => repo.deleteRegistro('cargo', id),
  );
});

final cofradiasProvider = StateNotifierProvider<SecretariaNotifier<Cofradia>, AsyncValue<List<Cofradia>>>((ref) {
  final repo = ref.watch(secretariaRepositoryProvider);
  return SecretariaNotifier<Cofradia>(
    fetch: repo.getCofradias,
    save: repo.upsertCofradia,
    delete: (id) => repo.deleteRegistro('cofradia', id),
  );
});