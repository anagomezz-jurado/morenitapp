import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/repositories/hermano_repository.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/infrastructure/repositories/hermano_repository_impl.dart';

// --- 1. REPOSITORIO ---
final hermanoRepositoryProvider = Provider<HermanoRepository>((ref) {
  return HermanoRepositoryImpl();
});

// --- 2. MODELO DE FILTROS ---
class HermanosFilters {
  final String query;
  final bool soloMayores18;
  final bool soloElCarpio;

  HermanosFilters({
    this.query = '',
    this.soloMayores18 = false,
    this.soloElCarpio = false,
  });

  HermanosFilters copyWith({
    String? query,
    bool? soloMayores18,
    bool? soloElCarpio,
  }) {
    return HermanosFilters(
      query: query ?? this.query,
      soloMayores18: soloMayores18 ?? this.soloMayores18,
      soloElCarpio: soloElCarpio ?? this.soloElCarpio,
    );
  }
}

// --- 3. NOTIFIER DE FILTROS ---
class HermanosFiltersNotifier extends StateNotifier<HermanosFilters> {
  HermanosFiltersNotifier() : super(HermanosFilters());

  void setQuery(String query) => state = state.copyWith(query: query);
  
  void toggleMayores18() => 
      state = state.copyWith(soloMayores18: !state.soloMayores18);
      
  void toggleElCarpio() => 
      state = state.copyWith(soloElCarpio: !state.soloElCarpio);
}

final hermanosFiltersProvider =
    StateNotifierProvider<HermanosFiltersNotifier, HermanosFilters>((ref) {
  return HermanosFiltersNotifier();
});

// --- 4. NOTIFIER DEL LISTADO PRINCIPAL ---
class HermanosListNotifier extends StateNotifier<AsyncValue<List<Hermano>>> {
  final HermanoRepository repository;

  HermanosListNotifier({required this.repository}) : super(const AsyncValue.loading()) {
    getHermanos();
  }

  Future<void> getHermanos() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getHermanos());
  }

  Future<void> createHermano(Map<String, dynamic> map) async {
    final nuevoHermano = Hermano(
      numeroHermano: int.parse(map['numero_hermano'].toString()),
      nombre: map['nombre'],
      apellido1: map['apellido1'],
      apellido2: map['apellido2'] ?? '',
      dni: map['dni'],
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      sexo: map['sexo'],
      fechaAlta: map['fecha_alta'],
      fechaNacimiento: map['fecha_nacimiento'] ?? '',
      metodoPago: map['metodo_pago'],
      responsable: map['responsable'] ?? false,
      calleId: map['calle_id'],
      piso: map['piso'],
      puerta: map['puerta'],
    );

    try {
      final result = await repository.anadirHermano(nuevoHermano);
      
      // Actualizamos el estado local añadiendo el nuevo hermano a la lista existente
      state.whenData((listaActual) {
        state = AsyncValue.data([...listaActual, result]);
      });
    } catch (e) {
      // Re-lanzamos el error para que la UI pueda mostrar un SnackBar
      rethrow; 
    }
  }
}

final hermanosListadoProvider = StateNotifierProvider<HermanosListNotifier, AsyncValue<List<Hermano>>>((ref) {
  final repository = ref.watch(hermanoRepositoryProvider);
  return HermanosListNotifier(repository: repository);
});

// --- 5. EL FILTRADOR (Lógica combinada) ---
final hermanosFiltradosProvider = Provider<AsyncValue<List<Hermano>>>((ref) {
  // Observamos tanto la lista completa como los filtros
  final hermanosAsync = ref.watch(hermanosListadoProvider);
  final filtros = ref.watch(hermanosFiltersProvider);

  return hermanosAsync.whenData((lista) {
    return lista.where((h) {
      // Filtro por texto (Nombre o DNI)
      final matchesQuery = h.nombre.toLowerCase().contains(filtros.query.toLowerCase()) ||
                           h.apellido1.toLowerCase().contains(filtros.query.toLowerCase()) ||
                           h.dni.toLowerCase().contains(filtros.query.toLowerCase());

      // Filtro por El Carpio (opcional según tu lógica)
      final matchesCarpio = !filtros.soloElCarpio || 
                            h.calleNombre.toLowerCase().contains('carpio');

      return matchesQuery && matchesCarpio;
    }).toList();
  });
});