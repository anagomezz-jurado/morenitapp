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
      await getHermanos(); 
    } catch (e) {
      throw 'Error en el servidor: $e';
    }
  }
  // En hermanos_provider.dart
Future<void> eliminarHermano(int id) async {
  await repository.eliminarHermano(id); // Llama al repositorio
  // Actualiza el estado local para que desaparezca de la lista sin recargar
  state = state.whenData(
    (hermanos) => hermanos.where((h) => h.id != id).toList()
  );
}

  Future<void> updateHermano(int id, Map<String, dynamic> datos) async {
    try {
      await repository.updateHermano(id, datos);
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

// Provider para el buscador
final hermanosFiltersProvider = StateNotifierProvider<HermanosFiltersNotifier, String>((ref) => HermanosFiltersNotifier());

class HermanosFiltersNotifier extends StateNotifier<String> {
  HermanosFiltersNotifier() : super('');
  void setQuery(String q) => state = q;
}

// PROVIDER DE FILTRADO (Consumir en la UI)
final hermanosActivosFiltradosProvider = Provider<AsyncValue<List<Hermano>>>((ref) {
  final hermanosAsync = ref.watch(hermanosListadoProvider);
  final query = ref.watch(hermanosFiltersProvider).toLowerCase();

  return hermanosAsync.whenData((lista) {
    // 1. Filtrar Activos
    final soloActivos = lista.where((h) => h.estado == 'activo').toList();

    // 2. Filtrar por texto (Nombre, Apellidos o DNI)
    if (query.isEmpty) return soloActivos;
    
    return soloActivos.where((h) {
      final nombreCompleto = "${h.nombre} ${h.apellido1} ${h.apellido2}".toLowerCase();
      final dni = h.dni.toLowerCase();
      final nHermano = h.numeroHermano.toString();
      
      return nombreCompleto.contains(query) || 
             dni.contains(query) || 
             nHermano.contains(query);
    }).toList();
  });
});