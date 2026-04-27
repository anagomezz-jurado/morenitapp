import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/domain/entities/grupo_user.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/domain/repositories/usuario_repository.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/infrastructure/repositories/usuario_repository_impl.dart';
// ... tus imports ...

// 1. Estandarizamos el nombre a usuariosListadoProvider
final usuariosListadoProvider =
    AsyncNotifierProvider<UsuariosNotifier, List<User>>(UsuariosNotifier.new);

// 2. Filtros (Estado simple para la búsqueda y filtros avanzados)
final usuariosFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'query': '',
  'advanced': <String, dynamic>{},
});

// 3. Provider filtrado que la UI realmente escucha
final usuariosFiltradosProvider = Provider<AsyncValue<List<User>>>((ref) {
  final usuariosAsync = ref.watch(usuariosListadoProvider);
  final filtros = ref.watch(usuariosFiltersProvider);
  final query = filtros['query'].toString().toLowerCase();

  return usuariosAsync.whenData((lista) {
    return lista.where((u) {
      final matchQuery = u.fullName.toLowerCase().contains(query) || 
                         u.email.toLowerCase().contains(query);
      // Aquí podrías añadir lógica para los filtros avanzados (rol, etc.)
      return matchQuery;
    }).toList();
  });
});

final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) {
  return UsuarioRepositoryImpl();
});

class UsuariosNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    return ref.watch(usuarioRepositoryProvider).getUsuarios(); 
  }

  // Métodos de acción...
  Future<void> crear(Map<String, dynamic> datos) async {
    state = const AsyncLoading();
    try {
      await ref.read(usuarioRepositoryProvider).crearUsuario(datos);
      ref.invalidateSelf(); 
    } catch (e, st) { state = AsyncError(e, st); }
  }

  Future<void> editar(int id, Map<String, dynamic> datos) async {
    state = const AsyncLoading();
    try {
      await ref.read(usuarioRepositoryProvider).editarUsuario(id, datos);
      ref.invalidateSelf();
    } catch (e, st) { state = AsyncError(e, st); }
  }

  Future<void> eliminar(int id) async {
    state = const AsyncLoading();
    try {
      await ref.read(usuarioRepositoryProvider).eliminarUsuario(id);
      ref.invalidateSelf();
    } catch (e, st) { state = AsyncError(e, st); }
  }
}

final gruposProvider =
    AsyncNotifierProvider<GruposNotifier, List<Grupo>>(GruposNotifier.new);

class GruposNotifier extends AsyncNotifier<List<Grupo>> {
  @override
  Future<List<Grupo>> build() async {
    // Usamos el repositorio especializado en usuarios/grupos
    return ref.watch(usuarioRepositoryProvider).getGrupos();
  }

  Future<void> crear(String nombre) async {
    state = const AsyncLoading();
    try {
      await ref.read(usuarioRepositoryProvider).crearGrupo(nombre);
      ref.invalidateSelf();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> editar(int id, String nombre) async {
    state = const AsyncLoading();
    try {
      await ref.read(usuarioRepositoryProvider).editarGrupo(id, nombre);
      ref.invalidateSelf();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> eliminar(int id) async {
    state = const AsyncLoading();
    try {
      await ref.read(usuarioRepositoryProvider).eliminarGrupo(id);
      ref.invalidateSelf();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}