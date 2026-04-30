import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/panel-gestion/activity_log.dart';
import 'package:morenitapp/features/panel-gestion/activity_log_provider.dart';
import 'package:morenitapp/shared/widgets/filtro_avanzado_model.dart';
import '../../domain/entities/hermano.dart';
import '../../domain/repositories/hermano_repository.dart';
import '../../infrastructure/repositories/hermano_repository_impl.dart';

final hermanoRepositoryProvider =
    Provider<HermanoRepository>((ref) => HermanoRepositoryImpl());

class HermanosFiltersState {
  final String query;
  final List<FilterCriterion> advancedFilters;
  HermanosFiltersState({this.query = '', this.advancedFilters = const []});

  HermanosFiltersState copyWith(
      {String? query, List<FilterCriterion>? advancedFilters}) {
    return HermanosFiltersState(
      query: query ?? this.query,
      advancedFilters: advancedFilters ?? this.advancedFilters,
    );
  }
}

class HermanosFiltersNotifier extends StateNotifier<HermanosFiltersState> {
  HermanosFiltersNotifier() : super(HermanosFiltersState());
  void setQuery(String q) => state = state.copyWith(query: q);
  void setAdvancedFilters(List<FilterCriterion> filters) =>
      state = state.copyWith(advancedFilters: filters);
}

final hermanosFiltersProvider =
    StateNotifierProvider<HermanosFiltersNotifier, HermanosFiltersState>(
        (ref) => HermanosFiltersNotifier());

class HermanosListNotifier extends StateNotifier<AsyncValue<List<Hermano>>> {
  final HermanoRepository repository;
  final Ref ref;

  HermanosListNotifier({required this.repository, required this.ref})
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
      final user = ref.read(authProvider).user;
      ref.read(activityLogProvider.notifier).addLog(
            userId: user?.id.toString() ?? '',
            userName: user?.nombre ?? 'Sistema',
            action: ActionType.create,
            entityName: 'hermano ${hermano.nombre} ${hermano.apellido1}',
            detail: 'Nuevo hermano creado',
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHermano(int id, Map<String, dynamic> datos) async {
    try {
      await repository.updateHermano(id, datos);
      await getHermanos(); 
      final user = ref.read(authProvider).user;
      ref.read(activityLogProvider.notifier).addLog(
            userId: user?.id.toString() ?? '',
            userName: user?.nombre ?? 'Sistema',
            action: ActionType.update,
            entityName: 'hermano ID: $id',
            detail: 'Hermano actualizado',
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminarHermano(int id) async {
    try {
      final hermanoEliminado = state.value?.firstWhere((h) => h.id == id);
      await repository.eliminarHermano(id);
      await getHermanos();
      final user = ref.read(authProvider).user;
      ref.read(activityLogProvider.notifier).addLog(
            userId: user?.id.toString() ?? '',
            userName: user?.nombre ?? 'Sistema',
            action: ActionType.delete,
            entityName: 'hermano ${hermanoEliminado?.nombre ?? id}',
            detail: 'Hermano eliminado',
          );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final hermanosListadoProvider =
    StateNotifierProvider<HermanosListNotifier, AsyncValue<List<Hermano>>>(
        (ref) {
  final repository = ref.watch(hermanoRepositoryProvider);
  return HermanosListNotifier(repository: repository, ref: ref);
});

final hermanosActivosFiltradosProvider =
    Provider<AsyncValue<List<Hermano>>>((ref) {
  final listaAsync = ref.watch(hermanosListadoProvider);
  final filtros = ref.watch(hermanosFiltersProvider);

  return listaAsync.whenData((lista) {
    return lista.where((h) {
      if (h.estado != 'activo') return false;
      final searchLower = filtros.query.toLowerCase();
      final matchesQuery = h.nombre.toLowerCase().contains(searchLower) ||
          h.apellido1.toLowerCase().contains(searchLower) ||
          (h.dni?.toLowerCase().contains(searchLower) ?? false);
      if (!matchesQuery) return false;

      for (var f in filtros.advancedFilters) {
        final valorHermano = _obtenerValorCampo(h, f.field);
        if (!_cumpleFiltro(valorHermano, f)) return false;
      }
      return true;
    }).toList();
  });
});

dynamic _obtenerValorCampo(Hermano h, String field) {
  switch (field) {
    case 'nombre':
      return h.nombre;
    case 'apellido1':
      return h.apellido1;
    case 'dni':
      return h.dni;
    case 'codigo_hermano':
      return h.codigoHermano;
    case 'fecha_alta':
      return h.fechaAlta;
    case 'bautizado':
      return h.bautizado;
    default:
      return null;
  }
}

bool _cumpleFiltro(dynamic valor, FilterCriterion f) {
  if (valor == null) return false;
  final valorStr = valor.toString().toLowerCase();
  final filtroStr = f.value.toString().toLowerCase();

  switch (f.operator) {
    case FilterOperator.contains:
      return valorStr.contains(filtroStr);
    case FilterOperator.equals:
      return valorStr == filtroStr;
    case FilterOperator.greaterThan:
      if (valor is num) return valor > (num.tryParse(f.value.toString()) ?? 0);
      return valorStr.compareTo(filtroStr) > 0;
    case FilterOperator.lessThan:
      if (valor is num) return valor < (num.tryParse(f.value.toString()) ?? 0);
      return valorStr.compareTo(filtroStr) < 0;
    default:
      return false;
  }
}
