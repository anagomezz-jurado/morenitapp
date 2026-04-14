import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/codigo_postal.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/direccion.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/localidad.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/provincia.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/repositories/ubicaciones_repository.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/infrastructure/repositories/ubicaciones_repository_impl.dart';

/// Provider para el repositorio de ubicaciones
final ubicacionesRepositoryProvider = Provider<UbicacionRepository>((ref) {
  return UbicacionRepositoryImpl();
});

// En tu UbicacionesProvider o similar

// --- DIRECCIONES ---

final direccionesProvider =
    StateNotifierProvider<DireccionesNotifier, AsyncValue<List<Direccion>>>(
        (ref) {
  return DireccionesNotifier();
});

class DireccionesNotifier extends StateNotifier<AsyncValue<List<Direccion>>> {
  DireccionesNotifier() : super(const AsyncValue.loading()) {
    _cargar();
  }
  void _cargar() {
    state = AsyncValue.data([
      Direccion(
          id: 1,
          calle: 'Av. Siempre Viva',
          numero: '742',
          provinciaId: 1,
          localidadId: 1,
          cpId: 1),
    ]);
  }

  Future<void> agregarDireccion(
      String calle, String numero, int provId, int locId, int cpId) async {
    final actual = state.value ?? [];
    state = AsyncValue.data([
      ...actual,
      Direccion(
          id: actual.length + 1,
          calle: calle,
          numero: numero,
          provinciaId: provId,
          localidadId: locId,
          cpId: cpId)
    ]);
  }
}

// -------------------------------------------------------------------------
// --- SECCIÓN DE PROVINCIAS ---
// -------------------------------------------------------------------------

final provinciasProvider =
    StateNotifierProvider<ProvinciasNotifier, AsyncValue<List<Provincia>>>(
        (ref) {
  final repository = ref.watch(ubicacionesRepositoryProvider);
  return ProvinciasNotifier(repository: repository, ref: ref); // Pasamos ref
});

final provinciaFiltroSeleccionadaProvider = StateProvider<int?>((ref) => null);

class ProvinciasNotifier extends StateNotifier<AsyncValue<List<Provincia>>> {
  final UbicacionRepository repository;
  final Ref ref; // Necesario para acceder a otros providers

  ProvinciasNotifier({required this.repository, required this.ref})
      : super(const AsyncValue.loading()) {
    cargarProvincias();
  }

  Future<void> cargarProvincias() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getProvincias());
  }

  Future<void> agregarProvincia(String codigo, String nombre) async {
    final nueva =
        Provincia(id: 0, codProvincia: codigo, nombreProvincia: nombre);
    try {
      final creada = await repository.crearProvincia(nueva);
      state.whenData((lista) => state = AsyncValue.data([...lista, creada]));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editarProvincia(int id, String nombre, String codigo) async {
    try {
      final success = await repository.editarProvincia(
          id, {'nombreProvincia': nombre, 'codProvincia': codigo});
      if (success) {
        state.whenData((lista) {
          state = AsyncValue.data([
            for (final p in lista)
              if (p.id == id)
                p.copyWith(nombreProvincia: nombre, codProvincia: codigo)
              else
                p
          ]);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> borrarProvincia(int id) async {
    try {
      // VALIDACIÓN: Verificamos si existen localidades vinculadas
      final localidades = ref.read(localidadesProvider).value ?? [];
      final tieneDependencias =
          localidades.any((loc) => loc.codProvinciaId == id);

      if (tieneDependencias) {
        throw 'No se puede eliminar: Esta provincia tiene localidades vinculadas.';
      }

      final success = await repository.eliminarProvincia(id);
      if (success) {
        state.whenData((lista) =>
            state = AsyncValue.data(lista.where((p) => p.id != id).toList()));
      }
    } catch (e) {
      rethrow;
    }
  }
}

// -------------------------------------------------------------------------
// --- SECCIÓN DE LOCALIDADES ---
// -------------------------------------------------------------------------

final localidadesProvider =
    StateNotifierProvider<LocalidadesNotifier, AsyncValue<List<Localidad>>>(
        (ref) {
  final repository = ref.watch(ubicacionesRepositoryProvider);
  return LocalidadesNotifier(repository: repository, ref: ref);
});

final localidadesFiltradasProvider =
    Provider<AsyncValue<List<Localidad>>>((ref) {
  final localidadesAsync = ref.watch(localidadesProvider);
  final provinciaIdFiltro = ref.watch(provinciaFiltroSeleccionadaProvider);

  return localidadesAsync.whenData((localidades) {
    if (provinciaIdFiltro == null) return localidades;
    return localidades
        .where((l) => l.codProvinciaId == provinciaIdFiltro)
        .toList();
  });
});

class LocalidadesNotifier extends StateNotifier<AsyncValue<List<Localidad>>> {
  final UbicacionRepository repository;
  final Ref ref;

  LocalidadesNotifier({required this.repository, required this.ref})
      : super(const AsyncValue.loading()) {
    cargarLocalidades();
  }

  Future<void> cargarLocalidades() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getLocalidades());
  }

  Future<void> agregarLocalidad(
      String nombre, int provinciaId, String capital) async {
    final nueva = Localidad(
        id: 0,
        nombreLocalidad: nombre,
        codProvinciaId: provinciaId,
        nombreCapital: capital);
    try {
      final creada = await repository.crearLocalidad(nueva);
      state.whenData((lista) => state = AsyncValue.data([...lista, creada]));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editarLocalidad(
      int id, String nombre, int provinciaId, String capital) async {
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
                loc.copyWith(
                    nombreLocalidad: nombre,
                    codProvinciaId: provinciaId,
                    nombreCapital: capital)
              else
                loc
          ]);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> borrarLocalidad(int id) async {
    try {
      // VALIDACIÓN: Verificamos si existen CPs vinculados
      final cps = ref.read(codigosPostalesProvider).value ?? [];
      final tieneDependencias = cps.any((cp) => cp.localidadId == id);

      if (tieneDependencias) {
        throw 'No se puede eliminar: Esta localidad tiene códigos postales vinculados.';
      }

      final success = await repository.eliminarLocalidad(id);
      if (success) {
        state.whenData((lista) =>
            state = AsyncValue.data(lista.where((l) => l.id != id).toList()));
      }
    } catch (e) {
      rethrow;
    }
  }
}

// -------------------------------------------------------------------------
// --- SECCIÓN DE CÓDIGOS POSTALES ---
// -------------------------------------------------------------------------

final codigosPostalesProvider = StateNotifierProvider<CodigosPostalesNotifier,
    AsyncValue<List<CodigoPostal>>>((ref) {
  final repository = ref.watch(ubicacionesRepositoryProvider);
  return CodigosPostalesNotifier(repository: repository, ref: ref);
});

final localidadFiltroSeleccionadaProvider = StateProvider<int?>((ref) => null);

final codigosPostalesFiltradosProvider =
    Provider<AsyncValue<List<CodigoPostal>>>((ref) {
  final cpAsync = ref.watch(codigosPostalesProvider);
  final localidadIdFiltro = ref.watch(localidadFiltroSeleccionadaProvider);

  return cpAsync.whenData((lista) {
    if (localidadIdFiltro == null) return lista;
    return lista.where((cp) => cp.localidadId == localidadIdFiltro).toList();
  });
});

class CodigosPostalesNotifier
    extends StateNotifier<AsyncValue<List<CodigoPostal>>> {
  final UbicacionRepository repository;
  final Ref ref;

  CodigosPostalesNotifier({required this.repository, required this.ref})
      : super(const AsyncValue.loading()) {
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

  Future<void> editarCodigoPostal(
      int id, String nombre, int localidadId) async {
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
      // 1. Validación local (Preventiva)
      final calles = ref.read(callesProvider).value ?? [];
      if (calles.any((c) => c.codPostalId == id)) {
        throw 'No eliminar: tiene calles vinculadas a este código postal.';
      }

      // 2. Intento de borrado en servidor
      final success = await repository.eliminarCodigoPostal(id);

      if (success) {
        state.whenData((lista) =>
            state = AsyncValue.data(lista.where((cp) => cp.id != id).toList()));
      }
    } on DioException catch (e) {
      // 3. Captura específica del error 500 que mencionas
      if (e.response?.statusCode == 500) {
        throw 'Error del servidor: Es posible que este CP todavía tenga registros asociados en la base de datos.';
      }
      throw 'Error de red al intentar eliminar.';
    } catch (e) {
      rethrow;
    }
  }
}

// -------------------------------------------------------------------------
// --- SECCIÓN DE CALLES ---
// -------------------------------------------------------------------------

final callesProvider =
    StateNotifierProvider<CallesNotifier, AsyncValue<List<Calle>>>((ref) {
  final repository = ref.watch(ubicacionesRepositoryProvider);
  return CallesNotifier(repository: repository);
});

class CallesNotifier extends StateNotifier<AsyncValue<List<Calle>>> {
  final UbicacionRepository repository;

  CallesNotifier({required this.repository})
      : super(const AsyncValue.loading()) {
    cargarCalles();
  }

  Future<void> cargarCalles() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getCalles());
  }

  Future<void> agregarCalle(String nombre, int localidadId, int cpId) async {
  final nueva = Calle(
      id: 0,
      nombreCalle: nombre,
      localidadId: localidadId,
      codPostalId: cpId);
  try {
    // 1. Enviamos a Odoo
    final creada = await repository.crearCalle(nueva);
    
    // 2. Actualizamos el estado local con la calle que Odoo nos devuelve (ya trae su ID real)
    state.whenData((lista) {
      state = AsyncValue.data([...lista, creada]);
    });
    
    // 3. (Opcional) Recargar todo para estar seguros
    await cargarCalles();
  } catch (e) {
    rethrow;
  }
}

  Future<void> actualizarCalle(
      int id, String nombre, int localidadId, int cpId) async {
    try {
      final success = await repository.editarCalle(id, {
        'nombreCalle': nombre,
        'localidad_id': localidadId,
        'codPostal_id': cpId,
      });

      if (success) {
        state.whenData((lista) {
          state = AsyncValue.data([
            for (final c in lista)
              if (c.id == id)
                Calle(
                    id: id,
                    nombreCalle: nombre,
                    localidadId: localidadId,
                    codPostalId: cpId)
              else
                c
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
            state = AsyncValue.data(lista.where((c) => c.id != id).toList()));
      }
    } catch (e) {
      rethrow;
    }
  }
}
