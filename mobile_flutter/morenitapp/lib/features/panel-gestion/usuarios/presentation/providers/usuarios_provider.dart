import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/domain/entities/grupo_user.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/domain/repositories/usuario_repository.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/infrastructure/repositories/usuario_repository_impl.dart';

// --- REPOSITORIO ---
final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) {
  return UsuarioRepositoryImpl();
});

// --- USUARIOS ---

final usuariosListadoProvider =
    AsyncNotifierProvider<UsuariosNotifier, List<User>>(UsuariosNotifier.new);

class UsuariosNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    return ref.watch(usuarioRepositoryProvider).getUsuarios();
  }

  Future<bool> crear(Map<String, dynamic> datos) async {
    try {
      await ref.read(usuarioRepositoryProvider).crearUsuario(datos);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      debugPrint('Error en crearUsuario: $e');
      return false;
    }
  }

Future<bool> editar(int id, Map<String, dynamic> datos) async {
  try {
    // 1. Enviamos la actualización a Odoo
    await ref.read(usuarioRepositoryProvider).editarUsuario(id, datos);
    
    // 2. En lugar de invalidar (que rompe la UI), actualizamos los datos manualmente
    final listaActualizada = await ref.read(usuarioRepositoryProvider).getUsuarios();
    state = AsyncValue.data(listaActualizada); 

    return true;
  } catch (e) {
    debugPrint('Error en editarUsuario: $e');
    return false;
  }
}

  Future<bool> eliminar(int id) async {
    try {
      await ref.read(usuarioRepositoryProvider).eliminarUsuario(id);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      debugPrint('Error en eliminarUsuario: $e');
      return false;
    }
  }
}

// --- FILTROS ---

final usuariosFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {
      'query': '',
      'advanced': <String, dynamic>{},
    });

final usuariosFiltradosProvider = Provider<AsyncValue<List<User>>>((ref) {
  final usuariosAsync = ref.watch(usuariosListadoProvider);
  final filtros = ref.watch(usuariosFiltersProvider);
  final query = filtros['query'].toString().toLowerCase();

  return usuariosAsync.whenData((lista) {
    return lista.where((u) {
      final matchQuery = u.fullName.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query);
      return matchQuery;
    }).toList();
  });
});

// --- GRUPOS ---

final gruposProvider =
    AsyncNotifierProvider<GruposNotifier, List<Grupo>>(GruposNotifier.new);

class GruposNotifier extends AsyncNotifier<List<Grupo>> {
  @override
  Future<List<Grupo>> build() async {
    return ref.watch(usuarioRepositoryProvider).getGrupos();
  }

  Future<bool> crear(String nombre) async {
    try {
      await ref.read(usuarioRepositoryProvider).crearGrupo(nombre);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      debugPrint('Error en crearGrupo: $e');
      return false;
    }
  }

  Future<bool> editar(int id, String nombre) async {
    try {
      await ref.read(usuarioRepositoryProvider).editarGrupo(id, nombre);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      debugPrint('Error en editarGrupo: $e');
      return false;
    }
  }

  Future<bool> eliminar(int id) async {
    try {
      await ref.read(usuarioRepositoryProvider).eliminarGrupo(id);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      debugPrint('Error en eliminarGrupo: $e');
      return false;
    }
  }
}