import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/hermano.dart';
import '../../domain/repositories/hermano_repository.dart';
import '../../infrastructure/repositories/hermano_repository_impl.dart';

final hermanoRepositoryProvider =
    Provider<HermanoRepository>((ref) => HermanoRepositoryImpl());

class HermanosListNotifier extends StateNotifier<AsyncValue<List<Hermano>>> {
  final HermanoRepository repository;

  HermanosListNotifier({required this.repository})
      : super(const AsyncValue.loading()) {
    getHermanos();
  }

  Future<void> getHermanos() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getHermanos());
  }

  Future<void> createHermano(Hermano hermano) async {
    try {
      await repository.anadirHermano(hermano);
      await getHermanos();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateHermano(int id, Map<String, dynamic> datos) async {
    try {
      await repository.updateHermano(id, datos);
      await getHermanos(); // Esto refresca la base de datos local del estado
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminarHermano(int id) async {
    try {
      await repository.eliminarHermano(id);
      await getHermanos();
    } catch (e) {
      rethrow;
    }
  }
}

// 1. Provider de datos brutos desde Odoo
final hermanosListadoProvider =
    StateNotifierProvider<HermanosListNotifier, AsyncValue<List<Hermano>>>(
        (ref) {
  final repository = ref.watch(hermanoRepositoryProvider);
  return HermanosListNotifier(repository: repository);
});

// 2. Provider para el término de búsqueda
final hermanosFiltersProvider =
    StateNotifierProvider<HermanosFiltersNotifier, String>(
        (ref) => HermanosFiltersNotifier());

class HermanosFiltersNotifier extends StateNotifier<String> {
  HermanosFiltersNotifier() : super('');
  void setQuery(String q) => state = q;
}

// --- NUEVOS PROVIDERS FILTRADOS ---

// 3. Provider de HERMANOS ACTIVOS (con buscador aplicado)
final hermanosActivosFiltradosProvider =
    Provider<AsyncValue<List<Hermano>>>((ref) {
  final hermanosAsync = ref.watch(hermanosListadoProvider);
  final query = ref.watch(hermanosFiltersProvider).toLowerCase();

  return hermanosAsync.whenData((lista) {
    // FILTRO 1: Solo activos
    final soloActivos = lista.where((h) => h.estado == 'activo').toList();

    // FILTRO 2: Buscador
    if (query.isEmpty) return soloActivos;
    return soloActivos
        .where((h) =>
            h.nombre.toLowerCase().contains(query) ||
            h.apellido1.toLowerCase().contains(query) ||
            h.dni.toLowerCase().contains(query))
        .toList();
  });
});

// 4. Provider de HERMANOS DE BAJA (con buscador aplicado)
final hermanosBajasFiltradosProvider =
    Provider<AsyncValue<List<Hermano>>>((ref) {
  final hermanosAsync = ref.watch(hermanosListadoProvider);
  final query = ref.watch(hermanosFiltersProvider).toLowerCase();

  return hermanosAsync.whenData((lista) {
    // Si la API devuelve datos de la tabla de bajas directamente:
    final soloBajas =
    lista.where((h) => h.estado == 'baja').toList();

    // FILTRO 2: Buscador
    if (query.isEmpty) return soloBajas;
    return soloBajas
        .where((h) =>
            h.nombre.toLowerCase().contains(query) ||
            h.apellido1.toLowerCase().contains(query) ||
            h.dni.toLowerCase().contains(query))
        .toList();
  });
});
