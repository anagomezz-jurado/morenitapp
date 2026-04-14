// usuarios_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';

final usuariosProvider = AsyncNotifierProvider<UsuariosNotifier, List<User>>(UsuariosNotifier.new);

class UsuariosNotifier extends AsyncNotifier<List<User>> {

  @override
  Future<List<User>> build() async {
    // CAMBIO: Usar authRepositoryProvider que es donde implementamos getUsuarios()
    final repo = ref.watch(authRepositoryProvider);
  return repo.getUsuarios();
  }

  Future<void> crear(String nombre, String email, String password, {int rolId = 2}) async {
    state = const AsyncValue.loading();
    try {
      // Aquí puedes seguir usando tu lógica de creación
      // Si el repositorio de configuración funciona para crear, déjalo, 
      // pero asegúrate de invalidar para que el build() de arriba vuelva a llamar a Odoo
      final datos = {
        'nombre': nombre,
        'email': email,
        'contrasena': password,
        'rol_id': rolId,
      };
      
      // Ajusta esto según donde tengas la lógica de "crear" (si en Auth o Config)
      // Pero lo importante es ref.invalidateSelf();
      ref.invalidateSelf();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> editar(String id, String nombre, String email, {int rolId = 2}) async {
    state = const AsyncValue.loading();
    final datos = {
      'nombre': nombre,
      'email': email,
      'rol_id': rolId, // <--- También permitimos cambiar el rol al editar
    };
    
    final success = await ref.read(configuracionRepositoryProvider).editarUsuario(int.parse(id), datos);
    if (success) ref.invalidateSelf();
  }

  // Eliminar usuario
  Future<void> eliminar(String id) async {
    state = const AsyncValue.loading();
    final success = await ref.read(configuracionRepositoryProvider).eliminarUsuario(int.parse(id));
    if (success) ref.invalidateSelf();
  }
}