import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:morenitapp/features/panel-gestion/libros/domain/entities/libro.dart';
import 'package:morenitapp/features/panel-gestion/libros/infrastructure/datasources/libro_datasource_impl.dart';
import 'package:morenitapp/features/panel-gestion/libros/infrastructure/repositories/libro_repository_impl.dart';

// Definición del Notifier
class LibrosNotifier extends StateNotifier<AsyncValue<List<Libro>>> {
  final LibroRepositoryImpl repository;

  LibrosNotifier({required this.repository}) : super(const AsyncValue.loading()) {
    cargarLibros();
  }

  Future<void> cargarLibros() async {
    try {
      final libros = await repository.getLibros();
      state = AsyncValue.data(libros);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await cargarLibros();
  }

  Future<bool> agregarLibro(Map<String, dynamic> datos) async {
    final success = await repository.crearLibro(datos);
    if (success) await cargarLibros();
    return success;
  }

  Future<bool> actualizarLibro(int id, Map<String, dynamic> datos) async {
  final success = await repository.editarLibro(id, datos);
  if (success) {
    await cargarLibros(); // Esto refresca la lista global
  }
  return success;
}

  Future<bool> borrarLibro(int id) async {
    final success = await repository.eliminarLibro(id);
    if (success) {
      // Optimización: eliminamos localmente el registro del estado para feedback instantáneo
      state.whenData((libros) {
        state = AsyncValue.data(libros.where((l) => l.id != id).toList());
      });
    }
    return success;
  }
}

// Providers
// Usamos un solo datasource compartido para el repositorio
final libroRepositoryProvider = Provider((ref) {
  final datasource = LibroDatasourceImpl();
  return LibroRepositoryImpl(datasource);
});

final librosProvider = StateNotifierProvider<LibrosNotifier, AsyncValue<List<Libro>>>((ref) {
  final repo = ref.watch(libroRepositoryProvider);
  return LibrosNotifier(repository: repo);
});