import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:morenitapp/shared/widgets/filtro_avanzado_model.dart';
import '../../domain/entities/hermano.dart';
import '../../domain/repositories/hermano_repository.dart';
import '../../infrastructure/repositories/hermano_repository_impl.dart';

final hermanoRepositoryProvider = Provider<HermanoRepository>((ref) => HermanoRepositoryImpl());

// 2. MODELO DE ESTADO PARA FILTROS
class HermanosFiltersState {
  final String query;
  final List<FilterCriterion> advancedFilters;

  HermanosFiltersState({this.query = '', this.advancedFilters = const []});

  HermanosFiltersState copyWith({String? query, List<FilterCriterion>? advancedFilters}) {
    return HermanosFiltersState(
      query: query ?? this.query,
      advancedFilters: advancedFilters ?? this.advancedFilters,
    );
  }
}

// 3. NOTIFIER PARA FILTROS
class HermanosFiltersNotifier extends StateNotifier<HermanosFiltersState> {
  HermanosFiltersNotifier() : super(HermanosFiltersState());

  void setQuery(String q) => state = state.copyWith(query: q);
  
  void setAdvancedFilters(List<FilterCriterion> filters) {
    state = state.copyWith(advancedFilters: filters);
  }
}

final hermanosFiltersProvider = StateNotifierProvider<HermanosFiltersNotifier, HermanosFiltersState>((ref) {
  return HermanosFiltersNotifier();
});

class HermanosListNotifier extends StateNotifier<AsyncValue<List<Hermano>>> {
  final HermanoRepository repository;

  HermanosListNotifier({required this.repository}) : super(const AsyncValue.loading()) {
    getHermanos();
  }

  Future<void> getHermanos() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getHermanos());
  }
Future<void> updateHermano(int id, Map<String, dynamic> datos) async {
  try {
    // 1. Ejecutar actualización en servidor (Odoo/API)
    await repository.updateHermano(id, datos);
    
    // 2. ACTUALIZACIÓN LOCAL INMEDIATA
    if (state.hasValue) {
      final listaActualizada = state.value!.map((h) {
        if (h.id == id) {
          // Creamos una copia del hermano con los nuevos datos
          // Si tu clase Hermano no tiene copyWith, asegúrate de que 
          // los campos en la entidad sean mutables o añade el método.
          return h.copyWith(
            estado: datos['estado'] ?? h.estado,
            fechaBaja: datos['fecha_baja'] ?? h.fechaBaja,
            motivoBaja: datos['motivo_baja'] ?? h.motivoBaja,
          );
        }
        return h;
      }).toList();
      
      state = AsyncValue.data(listaActualizada);
    }
    
    // 3. Recargamos del servidor por si acaso hubo cambios en Odoo (opcional)
    // await getHermanos(); 
  } catch (e) {
    state = AsyncValue.error(e, StackTrace.current);
    rethrow;
  }
}

  Future<void> eliminarHermano(int id) async {
    try {
      await repository.eliminarHermano(id);
      state.whenData((lista) {
        state = AsyncValue.data(lista.where((h) => h.id != id).toList());
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  Future<void> createHermano(Hermano hermano) async {
    try {
      await repository.anadirHermano(hermano);
      await getHermanos(); 
    } catch (e) {
      throw 'Error en el servidor: $e';
    }
  }

}
final hermanosListadoProvider = StateNotifierProvider<HermanosListNotifier, AsyncValue<List<Hermano>>>((ref) {
  final repository = ref.watch(hermanoRepositoryProvider);
  return HermanosListNotifier(repository: repository);
});

// 5. PROVIDER DE FILTRADO FINAL (EL QUE USA LA UI)
final hermanosActivosFiltradosProvider = Provider<AsyncValue<List<Hermano>>>((ref) {
  final listaAsync = ref.watch(hermanosListadoProvider);
  final filtros = ref.watch(hermanosFiltersProvider);

  return listaAsync.whenData((lista) {
    // Filtramos solo los que están activos primero, y luego aplicamos filtros de búsqueda
    return lista.where((h) {
      // Solo hermanos activos (asumiendo que tienes un campo estado)
      // if (h.estado != 'activo') return false; 
      if (h.estado != 'activo') return false;
      // 1. Filtro por búsqueda rápida
      final searchLower = filtros.query.toLowerCase();
      final matchesQuery = h.nombre.toLowerCase().contains(searchLower) ||
                           h.apellido1.toLowerCase().contains(searchLower) ||
                           (h.dni?.toLowerCase().contains(searchLower) ?? false);
      
      if (!matchesQuery) return false;

      // 2. Filtro Avanzado (Odoo Style)
      for (var f in filtros.advancedFilters) {
        final valorHermano = _obtenerValorCampo(h, f.field);
        if (!_cumpleFiltro(valorHermano, f)) return false;
      }

      return true;
    }).toList();
  });
});

// --- FUNCIONES AUXILIARES DE LÓGICA DE FILTRADO ---

dynamic _obtenerValorCampo(Hermano h, String field) {
  switch (field) {
    case 'nombre': return h.nombre;
    case 'apellido1': return h.apellido1;
    case 'dni': return h.dni;
    case 'codigo_hermano': return h.codigoHermano;
    case 'fecha_alta': return h.fechaAlta;
    default: return null;
  }
}
// Actualiza la función de cumplimiento de filtro
bool _cumpleFiltro(dynamic valor, FilterCriterion f) {
  if (valor == null || valor.toString().isEmpty) return false;

  // LÓGICA PARA FECHAS
  if (f.type == 'date') {
    try {
      // Intentamos parsear ambas fechas (la del hermano y la del filtro)
      DateTime fechaValor = DateTime.parse(valor.toString());
      DateTime fechaFiltro = DateTime.parse(f.value.toString());

      switch (f.operator) {
        case FilterOperator.equals:
          return fechaValor.isAtSameMomentAs(fechaFiltro);
        case FilterOperator.greaterThan:
          return fechaValor.isAfter(fechaFiltro);
        case FilterOperator.lessThan:
          return fechaValor.isBefore(fechaFiltro);
        default:
          return valor.toString().contains(f.value.toString());
      }
    } catch (e) {
      debugPrint("Error comparando fechas: $e");
      return false;
    }
  }

  // LÓGICA PARA TEXTO Y NÚMEROS (Se mantiene igual)
  final valorStr = valor.toString().toLowerCase();
  final filtroStr = f.value.toString().toLowerCase();

  switch (f.operator) {
    case FilterOperator.contains:
      return valorStr.contains(filtroStr);
    case FilterOperator.equals:
      return valorStr == filtroStr;
    case FilterOperator.greaterThan:
      if (valor is num) return valor > (num.tryParse(f.value) ?? 0);
      return valorStr.compareTo(filtroStr) > 0;
    case FilterOperator.lessThan:
      if (valor is num) return valor < (num.tryParse(f.value) ?? 0);
      return valorStr.compareTo(filtroStr) < 0;
  }

}