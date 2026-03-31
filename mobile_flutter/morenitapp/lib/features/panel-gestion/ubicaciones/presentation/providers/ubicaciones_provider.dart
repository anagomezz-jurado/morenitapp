import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/codigo_postal.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/localidad.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/provincia.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/repositories/ubicaciones_repository.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/infrastructure/repositories/ubicaciones_repository_impl.dart';

/// Provider para el repositorio de ubicaciones
final ubicacionesRepositoryProvider = Provider<UbicacionRepository>((ref) {
  return UbicacionRepositoryImpl();
});

// -------------------------------------------------------------------------
// --- SECCIÓN DE PROVINCIAS ---
// -------------------------------------------------------------------------

final provinciasProvider = StateNotifierProvider<ProvinciasNotifier, AsyncValue<List<Provincia>>>((ref) {
  final repository = ref.watch(ubicacionesRepositoryProvider);
  return ProvinciasNotifier(repository: repository);
});

final provinciaFiltroSeleccionadaProvider = StateProvider<int?>((ref) => null);

class ProvinciasNotifier extends StateNotifier<AsyncValue<List<Provincia>>> {
  final UbicacionRepository repository;

  ProvinciasNotifier({required this.repository}) : super(const AsyncValue.loading()) {
    cargarProvincias();
  }

  Future<void> cargarProvincias() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getProvincias());
  }

  Future<void> agregarProvincia(String codigo, String nombre) async {
    final nueva = Provincia(id: 0, codProvincia: codigo, nombreProvincia: nombre);
    try {
      final creada = await repository.crearProvincia(nueva);
      state.whenData((lista) => state = AsyncValue.data([...lista, creada]));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editarProvincia(int id, String nombre, String codigo) async {
    try {
      final success = await repository.editarProvincia(id, {
        'nombreProvincia': nombre, 
        'codProvincia': codigo
      });
      if (success) {
        state.whenData((lista) {
          state = AsyncValue.data([
            for (final p in lista)
              if (p.id == id) p.copyWith(nombreProvincia: nombre, codProvincia: codigo) else p
          ]);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> borrarProvincia(int id) async {
    try {
      final success = await repository.eliminarProvincia(id);
      if (success) {
        state.whenData((lista) => 
          state = AsyncValue.data(lista.where((p) => p.id != id).toList())
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

// -------------------------------------------------------------------------
// --- SECCIÓN DE LOCALIDADES ---
// -------------------------------------------------------------------------

final localidadesProvider = StateNotifierProvider<LocalidadesNotifier, AsyncValue<List<Localidad>>>((ref) {
  final repository = ref.watch(ubicacionesRepositoryProvider);
  return LocalidadesNotifier(repository: repository);
});

final localidadesFiltradasProvider = Provider<AsyncValue<List<Localidad>>>((ref) {
  final localidadesAsync = ref.watch(localidadesProvider);
  final provinciaIdFiltro = ref.watch(provinciaFiltroSeleccionadaProvider);

  return localidadesAsync.whenData((localidades) {
    if (provinciaIdFiltro == null) return localidades;
    return localidades.where((l) => l.codProvinciaId == provinciaIdFiltro).toList();
  });
});

class LocalidadesNotifier extends StateNotifier<AsyncValue<List<Localidad>>> {
  final UbicacionRepository repository;

  LocalidadesNotifier({required this.repository}) : super(const AsyncValue.loading()) {
    cargarLocalidades();
  }

  Future<void> cargarLocalidades() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getLocalidades());
  }

  Future<void> agregarLocalidad(String nombre, int provinciaId, String capital) async {
    final nueva = Localidad(id: 0, nombreLocalidad: nombre, codProvinciaId: provinciaId, nombreCapital: capital);
    try {
      final creada = await repository.crearLocalidad(nueva);
      state.whenData((lista) => state = AsyncValue.data([...lista, creada]));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editarLocalidad(int id, String nombre, int provinciaId, String capital) async {
    try {
      final success = await repository.editarLocalidad(id, {
        'nombreLocalidad': nombre,
        'codProvincia_id': provinciaId,
        'nombreCapital': capital
      });
      if (success) {
        state.whenData((lista) {
          state = AsyncValue.data([
            for (final loc in lista)
              if (loc.id == id) 
                loc.copyWith(nombreLocalidad: nombre, codProvinciaId: provinciaId, nombreCapital: capital) 
              else loc
          ]);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> borrarLocalidad(int id) async {
    try {
      final success = await repository.eliminarLocalidad(id);
      if (success) {
        state.whenData((lista) => 
          state = AsyncValue.data(lista.where((l) => l.id != id).toList())
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

// -------------------------------------------------------------------------
// --- SECCIÓN DE CÓDIGOS POSTALES ---
// -------------------------------------------------------------------------

final codigosPostalesProvider = StateNotifierProvider<CodigosPostalesNotifier, AsyncValue<List<CodigoPostal>>>((ref) {
  final repository = ref.watch(ubicacionesRepositoryProvider);
  return CodigosPostalesNotifier(repository: repository);
});

final localidadFiltroSeleccionadaProvider = StateProvider<int?>((ref) => null);

final codigosPostalesFiltradosProvider = Provider<AsyncValue<List<CodigoPostal>>>((ref) {
  final cpAsync = ref.watch(codigosPostalesProvider);
  final localidadIdFiltro = ref.watch(localidadFiltroSeleccionadaProvider);

  return cpAsync.whenData((lista) {
    if (localidadIdFiltro == null) return lista;
    return lista.where((cp) => cp.localidadId == localidadIdFiltro).toList();
  });
});

class CodigosPostalesNotifier extends StateNotifier<AsyncValue<List<CodigoPostal>>> {
  final UbicacionRepository repository;

  CodigosPostalesNotifier({required this.repository}) : super(const AsyncValue.loading()) {
    cargarCodigosPostales();
  }

  Future<void> cargarCodigosPostales() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getCodigosPostales());
  }

  Future<void> agregarCodigoPostal(String nombre, int localidadId) async {
    final nuevo = CodigoPostal(id: 0, name: nombre, localidadId: localidadId);
    try {
      final creada = await repository.crearCodigoPostal(nuevo);
      state.whenData((lista) => state = AsyncValue.data([...lista, creada]));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editarCodigoPostal(int id, String nombre, int localidadId) async {
    try {
      final success = await repository.editarCodigoPostal(id, {
        'name': nombre,
        'localidad_id': localidadId,
      });
      if (success) cargarCodigosPostales();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> borrarCodigoPostal(int id) async {
    try {
      final success = await repository.eliminarCodigoPostal(id);
      if (success) {
        state.whenData((lista) => 
          state = AsyncValue.data(lista.where((cp) => cp.id != id).toList())
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

// -------------------------------------------------------------------------
// --- SECCIÓN DE CALLES ---
// -------------------------------------------------------------------------

final callesProvider = StateNotifierProvider<CallesNotifier, AsyncValue<List<Calle>>>((ref) {
  final repository = ref.watch(ubicacionesRepositoryProvider);
  return CallesNotifier(repository: repository);
});

class CallesNotifier extends StateNotifier<AsyncValue<List<Calle>>> {
  final UbicacionRepository repository;

  CallesNotifier({required this.repository}) : super(const AsyncValue.loading()) {
    cargarCalles();
  }

  Future<void> cargarCalles() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getCalles());
  }

  Future<void> agregarCalle(String nombre, int localidadId, int cpId) async {
    final nueva = Calle(id: 0, nombreCalle: nombre, localidadId: localidadId, codPostalId: cpId);
    try {
      final creada = await repository.crearCalle(nueva);
      state.whenData((lista) => state = AsyncValue.data([...lista, creada]));
    } catch (e) {
      rethrow;
    }
  }

  /// Método añadido para soportar la edición desde la UI
  Future<void> actualizarCalle(int id, String nombre, int localidadId, int cpId) async {
    try {
      final success = await repository.editarCalle(id, {
        'nombreCalle': nombre,
        'localidad_id': localidadId,
        'codPostal_id': cpId,
      });
      
      if (success) {
        // Opción rápida: actualizar el estado local sin recargar de la API
        state.whenData((lista) {
          state = AsyncValue.data([
            for (final c in lista)
              if (c.id == id) 
                Calle(id: id, nombreCalle: nombre, localidadId: localidadId, codPostalId: cpId) 
              else c
          ]);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> borrarCalle(int id) async {
    try {
      final success = await repository.eliminarCalle(id);
      if (success) {
        state.whenData((lista) => 
          state = AsyncValue.data(lista.where((c) => c.id != id).toList())
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}