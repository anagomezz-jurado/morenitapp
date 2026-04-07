import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/hermano.dart';
import '../../domain/repositories/hermano_repository.dart';
import '../../infrastructure/repositories/hermano_repository_impl.dart';

final hermanoRepositoryProvider = Provider<HermanoRepository>((ref) => HermanoRepositoryImpl());

class HermanosListNotifier extends StateNotifier<AsyncValue<List<Hermano>>> {
  final HermanoRepository repository;

  HermanosListNotifier({required this.repository}) : super(const AsyncValue.loading()) {
    getHermanos();
  }

  Future<void> getHermanos() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getHermanos());
  }

  Future<void> createHermano(Hermano hermano) async {
    try {
      await repository.anadirHermano(hermano);
      await getHermanos(); // Recargar lista
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateHermano(int id, Map<String, dynamic> datos) async {
    try {
      await repository.updateHermano(id, datos);
      await getHermanos();
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

// Provider principal
final hermanosListadoProvider = StateNotifierProvider<HermanosListNotifier, AsyncValue<List<Hermano>>>((ref) {
  final repository = ref.watch(hermanoRepositoryProvider);
  return HermanosListNotifier(repository: repository);
});

// Provider para el término de búsqueda
final hermanosFiltersProvider = StateNotifierProvider<HermanosFiltersNotifier, String>((ref) => HermanosFiltersNotifier());

class HermanosFiltersNotifier extends StateNotifier<String> {
  HermanosFiltersNotifier() : super('');
  void setQuery(String q) => state = q;
}

// Provider de lista filtrada
final hermanosFiltradosProvider = Provider<AsyncValue<List<Hermano>>>((ref) {
  final hermanosAsync = ref.watch(hermanosListadoProvider);
  final query = ref.watch(hermanosFiltersProvider);

  return hermanosAsync.whenData((lista) {
    if (query.isEmpty) return lista;
    return lista.where((h) => 
      h.nombre.toLowerCase().contains(query.toLowerCase()) || 
      h.apellido1.toLowerCase().contains(query.toLowerCase()) ||
      h.dni.toLowerCase().contains(query.toLowerCase())
    ).toList();
  });
});