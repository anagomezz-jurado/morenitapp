import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/proveedor.dart';
import '../../infrastructure/datasources/proveedor_datasource_impl.dart';
import '../../infrastructure/repositories/proveedor_repository_impl.dart';

// 1. Repositorio Provider
final proveedorRepositoryProvider = Provider((ref) {
  return ProveedorRepositoryImpl(ProveedorDatasourceImpl());
});

// 2. Notifier Principal
final proveedoresProvider =
    AsyncNotifierProvider<ProveedoresNotifier, List<Proveedor>>(
        ProveedoresNotifier.new);

class ProveedoresNotifier extends AsyncNotifier<List<Proveedor>> {
  @override
  Future<List<Proveedor>> build() async {
    return ref.watch(proveedorRepositoryProvider).getProveedores();
  }

  Future<bool> crear(Map<String, dynamic> datos) async {
    state = const AsyncValue.loading();
    try {
      final success =
          await ref.read(proveedorRepositoryProvider).crearProveedor(datos);
      if (success) {
        ref.invalidateSelf();
        return true;
      }
      return false;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> actualizar(Map<String, dynamic> datos) async {
    state = const AsyncValue.loading();
    try {
      final id = int.parse(datos['id'].toString());
      final success = await ref
          .read(proveedorRepositoryProvider)
          .editarProveedor(id, datos);
      if (success) {
        ref.invalidateSelf();
        return true;
      }
      return false;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await ref.read(proveedorRepositoryProvider).eliminarProveedor(id);
      ref.invalidateSelf();
    } catch (e) {
    }
  }
}

// --- PROVIDERS FILTRADOS ---
final listaSoloAnunciantes = Provider<List<Proveedor>>((ref) {
  final estadoProveedores = ref.watch(proveedoresProvider);
  return estadoProveedores.maybeWhen(
    data: (listado) => listado.where((p) => p.anunciante).toList(),
    orElse: () => [],
  );
});

final listaTodosLosProveedores = Provider<List<Proveedor>>((ref) {
  final estadoProveedores = ref.watch(proveedoresProvider);
  return estadoProveedores.maybeWhen(
    data: (listado) => listado,
    orElse: () => [],
  );
});
