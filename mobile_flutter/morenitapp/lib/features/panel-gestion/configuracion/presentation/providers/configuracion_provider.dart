import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/grupo_proveedor.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/notificacion_tipo.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_autoridad.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_cargo.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_evento.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_rol.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/repositories/configuracion_repository.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/infrastructure/repositories/configuracion_repository_impl.dart';
import '../../infrastructure/datasources/configuracion_datasource_impl.dart';

// --- REPOSITORY PROVIDER ---
final configuracionRepositoryProvider =
    Provider<ConfiguracionRepository>((ref) {
  final datasource = ConfiguracionDatasourceImpl();
  return ConfiguracionRepositoryImpl(datasource);
});

// --- LISTADO PROVIDERS (AsyncNotifier) ---
final tiposEventoProvider =
    AsyncNotifierProvider<TiposEventoNotifier, List<TipoEvento>>(
        TiposEventoNotifier.new);
final tiposCargoProvider =
    AsyncNotifierProvider<TiposCargoNotifier, List<TipoCargo>>(
        TiposCargoNotifier.new);
final tiposAutoridadProvider =
    AsyncNotifierProvider<TiposAutoridadNotifier, List<TipoAutoridad>>(
        TiposAutoridadNotifier.new);
final rolesProvider =
    AsyncNotifierProvider<RolesNotifier, List<Rol>>(RolesNotifier.new);
final gruposProveedorProvider =
    AsyncNotifierProvider<GruposProveedorNotifier, List<GrupoProveedor>>(
        GruposProveedorNotifier.new);

// --- NOTIFIER PARA EVENTOS ---
class TiposEventoNotifier extends AsyncNotifier<List<TipoEvento>> {
  @override
  Future<List<TipoEvento>> build() async {
    return await ref.read(configuracionRepositoryProvider).getTiposEvento();
  }

  Future<void> crear(String codigo, String nombre, String color) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(configuracionRepositoryProvider)
          .crearTipoEvento(codigo, nombre, color);
      ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> editar(
      int id, String codigo, String nombre, String color) async {
    state = const AsyncValue.loading();
    await ref
        .read(configuracionRepositoryProvider)
        .editarTipoEvento(id, codigo, nombre, color);
    ref.invalidateSelf();
  }

  Future<void> eliminar(int id) async {
    state = const AsyncValue.loading();
    await ref.read(configuracionRepositoryProvider).eliminarTipoEvento(id);
    ref.invalidateSelf();
  }
}

// --- NOTIFIER PARA CARGOS ---
class TiposCargoNotifier extends AsyncNotifier<List<TipoCargo>> {
  @override
  Future<List<TipoCargo>> build() async {
    return ref.watch(configuracionRepositoryProvider).getTiposCargo();
  }

  Future<void> crear(String codigo, String nombre, String observaciones) async {
    state = const AsyncValue.loading();
    await ref
        .read(configuracionRepositoryProvider)
        .crearTipoCargo(codigo, nombre, observaciones);
    ref.invalidateSelf();
  }

  Future<void> editar(
      int id, String codigo, String nombre, String observaciones) async {
    state = const AsyncValue.loading();
    await ref
        .read(configuracionRepositoryProvider)
        .editarTipoCargo(id, codigo, nombre, observaciones);
    ref.invalidateSelf();
  }

  Future<void> eliminar(int id) async {
    state = const AsyncValue.loading();
    await ref.read(configuracionRepositoryProvider).eliminarTipoCargo(id);
    ref.invalidateSelf();
  }
}

// --- NOTIFIER PARA AUTORIDADES ---
class TiposAutoridadNotifier extends AsyncNotifier<List<TipoAutoridad>> {
  @override
  Future<List<TipoAutoridad>> build() async {
    return ref.watch(configuracionRepositoryProvider).getTiposAutoridad();
  }

  Future<void> crear(String codigo, String nombre) async {
    state = const AsyncValue.loading();
    await ref
        .read(configuracionRepositoryProvider)
        .crearTipoAutoridad(codigo, nombre);
    ref.invalidateSelf();
  }

  Future<void> editar(int id, String codigo, String nombre) async {
    state = const AsyncValue.loading();
    await ref
        .read(configuracionRepositoryProvider)
        .editarTipoAutoridad(id, codigo, nombre);
    ref.invalidateSelf();
  }

  Future<void> eliminar(int id) async {
    state = const AsyncValue.loading();
    await ref.read(configuracionRepositoryProvider).eliminarTipoAutoridad(id);
    ref.invalidateSelf();
  }
}

// --- NOTIFIER PARA ROLES ---
class RolesNotifier extends AsyncNotifier<List<Rol>> {
  @override
  Future<List<Rol>> build() async {
    return ref.watch(configuracionRepositoryProvider).getRoles();
  }

  Future<void> crear(int codigo, String nombre) async {
    state = const AsyncValue.loading();
    await ref.read(configuracionRepositoryProvider).crearRol(codigo, nombre);
    ref.invalidateSelf();
  }

  Future<void> editar(int id, int codigo, String nombre) async {
    state = const AsyncValue.loading();
    await ref
        .read(configuracionRepositoryProvider)
        .editarRol(id, codigo, nombre);
    ref.invalidateSelf();
  }

  Future<void> eliminar(int id) async {
    state = const AsyncValue.loading();
    await ref.read(configuracionRepositoryProvider).eliminarRol(id);
    ref.invalidateSelf();
  }
}

// --- NOTIFIER PARA GRUPOS PROVEEDOR ---
class GruposProveedorNotifier extends AsyncNotifier<List<GrupoProveedor>> {
  @override
  Future<List<GrupoProveedor>> build() async {
    return ref.watch(configuracionRepositoryProvider).getGruposProveedor();
  }

  Future<void> crear(String codigo, String nombre) async {
    state = const AsyncValue.loading();
    await ref
        .read(configuracionRepositoryProvider)
        .crearGrupoProveedor(codigo, nombre);
    ref.invalidateSelf();
  }

  Future<void> editar(int id, String codigo, String nombre) async {
    state = const AsyncValue.loading();
    await ref
        .read(configuracionRepositoryProvider)
        .editarGrupoProveedor(id, codigo, nombre);
    ref.invalidateSelf();
  }

  Future<void> eliminar(int id) async {
    state = const AsyncValue.loading();
    await ref.read(configuracionRepositoryProvider).eliminarGrupoProveedor(id);
    ref.invalidateSelf();
  }
}

final notificacionTiposProvider =
    AsyncNotifierProvider<NotificacionTiposNotifier, List<NotificacionTipo>>(
  NotificacionTiposNotifier.new,
);

class NotificacionTiposNotifier extends AsyncNotifier<List<NotificacionTipo>> {
  @override
  Future<List<NotificacionTipo>> build() async {
    return ref.watch(configuracionRepositoryProvider).getNotificacionTipos();
  }

  Future<bool> crear(String nombre) async {
    try {
      await ref
          .read(configuracionRepositoryProvider)
          .crearNotificacionTipo(nombre);
      ref.invalidateSelf();
      return true; 
    } catch (e) {
      debugPrint('Error al crear: $e');
      return false;
    }
  }

  Future<bool> editar(int id, String nombre) async {
    try {
      await ref
          .read(configuracionRepositoryProvider)
          .editarNotificacionTipo(id, nombre);
      ref.invalidateSelf(); 
      return true; 
    } catch (e) {
      debugPrint('Error al editar: $e');
      return false; 
    }
  }

  Future<bool> eliminar(int id) async {
    try {
      await ref
          .read(configuracionRepositoryProvider)
          .eliminarNotificacionTipo(id);

      ref.invalidateSelf();

      return true; 
    } catch (e) {
      debugPrint('Error al eliminar: $e');
      return false; 
    }
  }
}
