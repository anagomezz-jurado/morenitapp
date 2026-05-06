import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:morenitapp/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:morenitapp/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/presentation/providers/usuarios_provider.dart';
import 'package:morenitapp/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:morenitapp/shared/infrastructure/services/key_value_storage_service_impl.dart';

// --- PROVIDER ---
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();

  return AuthNotifier(
      ref: ref,
      authRepository: authRepository,
      keyValueStorageService: keyValueStorageService);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// --- NOTIFIER ---
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;

  AuthNotifier({
    required this.ref,
    required this.authRepository,
    required this.keyValueStorageService,
  }) : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    await checkAuthStatus();
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '');
  }

  Future<void> loginUser(String email, String password) async {
    state = state.copyWith(authStatus: AuthStatus.checking, errorMessage: '');
    try {
      final user = await authRepository.login(email, password);
      _setLoggedUser(user);
    } catch (e) {
      logout('Credenciales no válidas');
    }
  }
// --- AÑADE ESTO DENTRO DE TU CLASE AuthNotifier ---

  Future<void> loginAsGuest() async {
    // Ponemos el estado en checking un momento para limpiar errores previos
    state = state.copyWith(authStatus: AuthStatus.checking);

    // Simulamos un usuario con ID 0 y rol de invitado
    final guestUser = User(
      id: '0',
      nombre: 'Invitado',
      apellido1: '',
      apellido2: '',
      email: 'invitado@morenitapp.com',
      telefono: '',
      rolId: 3, // Asumiendo que 3 es el ID de Invitado en tu sistema
      rolName: 'Invitado',
      grupoName: 'Público',
      recibirNotiEmail: false,
      token: 'guest_token_session',
    );

    // Guardamos un token ficticio para que el sistema crea que hay sesión
    await keyValueStorageService.setKey<String>('token', guestUser.token);

    state = state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: guestUser,
      errorMessage: '',
    );
  }
  /// Actualiza el perfil en el servidor y actualiza el estado local inmediatamente
  Future<bool> updatePerfil(Map<String, dynamic> data) async {
    try {
      final user = state.user;
      if (user == null) return false;

      final userId = int.tryParse(user.id);
      if (userId == null) return false;

      // Llamamos al provider de usuarios para hacer el PUT en Odoo
      final success = await ref.read(usuariosListadoProvider.notifier).editar(userId, data);

      if (!success) return false;

      // IMPORTANTE: Actualizamos el usuario localmente sin cambiar el authStatus
      // Esto hace que la UI se refresque sin que el Router te eche.
      final updatedUser = user.copyWith(
        nombre: data['nombre'] ?? user.nombre,
        apellido1: data['apellido1'] ?? user.apellido1,
        apellido2: data['apellido2'] ?? user.apellido2,
        email: data['email'] ?? user.email,
        telefono: data['telefono'] ?? user.telefono,
        recibirNotiEmail: data['recibirNotiEmail'] ?? user.recibirNotiEmail,
      );

      state = state.copyWith(user: updatedUser, authStatus: AuthStatus.authenticated);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Refresca los datos del usuario desde el servidor sin mostrar pantallas de carga
  Future<void> refreshUser() async {
    try {
      // Obtenemos el token guardado
      final token = await keyValueStorageService.getValue<String>('token');
      if (token == null) return;

      // Pedimos a Odoo los datos actualizados
      final user = await authRepository.checkAuthStatus(token);

      // Actualizamos el estado de forma silenciosa
      state = state.copyWith(
        user: user,
        authStatus: AuthStatus.authenticated, // Mantener authenticated para evitar saltos del Router
      );
    } catch (e) {
      // En refresco silencioso no hacemos logout para no molestar al usuario si falla el internet
      print('Error en refresco silencioso: $e');
    }
  }

  Future<void> checkAuthStatus() async {
    final token = await keyValueStorageService.getValue<String>('token');

    if (token == null || token.isEmpty) {
      return logout(null); // Logout sin mensaje para el inicio
    }

    try {
      final user = await authRepository.checkAuthStatus(token);

      state = state.copyWith(
        user: user,
        authStatus: AuthStatus.authenticated,
      );
    } catch (e) {
      await logout('Sesión expirada');
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String nombre,
    required String apellido1,
    required String apellido2,
    required String telefono,
    bool recibirNotiEmail = true,
  }) async {
    state = state.copyWith(authStatus: AuthStatus.checking, errorMessage: '');
    try {
      final user = await authRepository.register(
        email: email,
        password: password,
        nombre: nombre,
        apellido1: apellido1,
        apellido2: apellido2,
        telefono: telefono,
        recibirNotiEmail: recibirNotiEmail,
      );
      _setLoggedUser(user);
    } on CustomError catch (e) {
      state = state.copyWith(authStatus: AuthStatus.notAuthenticated, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(authStatus: AuthStatus.notAuthenticated, errorMessage: 'Error en el registro');
    }
  }

  Future<void> _setLoggedUser(User user) async {
    try {
      await keyValueStorageService.setKey<String>('token', user.token);
      state = state.copyWith(
        user: user,
        authStatus: AuthStatus.authenticated,
        errorMessage: '',
      );
    } catch (e) {
      logout('Error al guardar sesión');
    }
  }

  Future<void> logout([String? message]) async {
    await keyValueStorageService.removeKey('token');
    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: null,
      errorMessage: message ?? '',
    );
  }
}

// --- ESTADOS ---
enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessage = '',
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
  }) =>
      AuthState(
        authStatus: authStatus ?? this.authStatus,
        user: user ?? this.user,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}