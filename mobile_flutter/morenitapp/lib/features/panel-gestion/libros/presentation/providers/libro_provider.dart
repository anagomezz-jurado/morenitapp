import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../infrastructure/datasources/libro_datasource_impl.dart';
import '../../infrastructure/repositories/libro_repository_impl.dart';
import '../../domain/entities/libro.dart';

// 1. El repositorio provider
final libroRepositoryProvider = Provider((ref) {
  return LibroRepositoryImpl(LibroDatasourceImpl());
});

// 2. El StateNotifier para manejar la lista
class LibrosNotifier extends StateNotifier<List<Libro>> {
  final LibroRepositoryImpl repository;

  LibrosNotifier({required this.repository}) : super([]) {
    cargarLibros();
  }

  Future<void> cargarLibros() async {
    try {
      final libros = await repository.getLibros();
      state = libros;
    } catch (e) {
      print("Error cargando libros: $e");
    }
  }

  Future<bool> agregarLibro(Map<String, dynamic> datos) async {
    final success = await repository.crearLibro(datos);
    if (success) await cargarLibros(); // Refrescar lista
    return success;
  }

  Future<bool> borrarLibro(int id) async {
    final success = await repository.eliminarLibro(id);
    if (success) {
      state = state.where((l) => l.id != id).toList();
    }
    return success;
  }
}

// 3. El provider que usará la UI
final librosProvider = StateNotifierProvider<LibrosNotifier, List<Libro>>((ref) {
  final repo = ref.watch(libroRepositoryProvider);
  return LibrosNotifier(repository: repo);
});