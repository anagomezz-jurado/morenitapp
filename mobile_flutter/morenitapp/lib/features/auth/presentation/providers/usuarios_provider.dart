// usuarios_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';

// Provider que observa la lista de usuarios
final usuariosProvider = AsyncNotifierProvider<UsuariosNotifier, List<User>>(UsuariosNotifier.new);

class UsuariosNotifier extends AsyncNotifier<List<User>> {


  @override
  Future<List<User>> build() async {
    return ref.watch(configuracionRepositoryProvider).getUsers();
  }

  Future<void> crear(String nombre, String email, String password, {int rolId = 2}) async {
    state = const AsyncValue.loading();
    final datos = {
      'nombre': nombre,
      'email': email,
      'contrasena': password,
      'rol_id': rolId, // <--- Ahora usa el valor del selector
    };
    
    final success = await ref.read(configuracionRepositoryProvider).crearUsuario(datos);
    if (success) ref.invalidateSelf();
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