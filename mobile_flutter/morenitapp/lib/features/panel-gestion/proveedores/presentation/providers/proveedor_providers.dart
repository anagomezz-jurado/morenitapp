import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/proveedor.dart';
import '../../infrastructure/datasources/proveedor_datasource_impl.dart';
import '../../infrastructure/repositories/proveedor_repository_impl.dart';

// 1. Repositorio Provider
final proveedorRepositoryProvider = Provider((ref) {
  return ProveedorRepositoryImpl(ProveedorDatasourceImpl());
});

// 2. Notifier Principal (Usa AsyncNotifier para manejo de estados asíncronos)
final proveedoresProvider = AsyncNotifierProvider<ProveedoresNotifier, List<Proveedor>>(ProveedoresNotifier.new);

class ProveedoresNotifier extends AsyncNotifier<List<Proveedor>> {
  
  @override
  Future<List<Proveedor>> build() async {
    return ref.watch(proveedorRepositoryProvider).getProveedores();
  }

  Future<void> crear({
    required String codigo, 
    required String nombre, 
    String? contacto,
    String? telefono,
    String? email,
    String? direccion,
    bool esAnunciante = false,
    int? grupoId
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(proveedorRepositoryProvider).crearProveedor({
        'cod_proveedor': codigo,
        'nombre': nombre,
        'contacto': contacto,
        'telefono': telefono,
        'email': email,
        'direccion': direccion,
        'anunciante': esAnunciante,
        'grupo_id': grupoId,
      });
      ref.invalidateSelf();
    } catch (e, stack) { 
      state = AsyncValue.error(e, stack); 
    }
  }

  Future<void> editar({
    required String id,
    required String codigo,
    required String nombre,
    String? contacto,
    String? telefono,
    String? email,
    String? direccion,
    required bool esAnunciante,
    int? grupoId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final success = await ref.read(proveedorRepositoryProvider).editarProveedor(int.parse(id), {
        'cod_proveedor': codigo,
        'nombre': nombre,
        'contacto': contacto,
        'telefono': telefono,
        'email': email,
        'direccion': direccion,
        'anunciante': esAnunciante,
        'grupo_id': grupoId,
      });
      if (success) ref.invalidateSelf();
    } catch (e, stack) { 
      state = AsyncValue.error(e, stack); 
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await ref.read(proveedorRepositoryProvider).eliminarProveedor(id);
      ref.invalidateSelf();
    } catch (e) {
      // Manejo de error
    }
  }
}

// --- PROVIDERS FILTRADOS ---

// FILTRO: Solo anunciantes (true)
final listaSoloAnunciantes = Provider<List<Proveedor>>((ref) {
  final estadoProveedores = ref.watch(proveedoresProvider);
  return estadoProveedores.maybeWhen(
    data: (listado) => listado.where((p) => p.anunciante == true).toList(),
    orElse: () => [],
  );
});

// FILTRO: Todos (Proveedores + Anunciantes)
final listaTodosLosProveedores = Provider<List<Proveedor>>((ref) {
  final estadoProveedores = ref.watch(proveedoresProvider);
  return estadoProveedores.maybeWhen(
    data: (listado) => listado,
    orElse: () => [],
  );
});