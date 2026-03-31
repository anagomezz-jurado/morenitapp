import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:morenitapp/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:morenitapp/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:morenitapp/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:morenitapp/shared/infrastructure/services/key_value_storage_service_impl.dart';

// --- PROVIDER ---
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();

  return AuthNotifier(
      authRepository: authRepository,
      keyValueStorageService: keyValueStorageService
  );
});

// --- NOTIFIER ---
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;

  AuthNotifier({
    required this.authRepository,
    required this.keyValueStorageService,
  }) : super(AuthState()) {
    // Al inicializar el provider, verificamos si hay sesión previa
    checkAuthStatus();
  }

  Future<void> loginUser(String email, String password) async {
    state = state.copyWith(authStatus: AuthStatus.checking);
    try {
      final user = await authRepository.login(email, password);
      _setLoggedUser(user);
    } catch (e) {
      logout('Credenciales no válidas');
    }
  }

  Future<void> registerUser(String email, String password, String fullName) async {
    state = state.copyWith(authStatus: AuthStatus.checking);
    try {
      final user = await authRepository.register(email, password, fullName);
      _setLoggedUser(user);
    } on CustomError catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        errorMessage: 'Error no controlado',
      );
    }
  }

  /// ESTE MÉTODO ES LA CLAVE PARA QUE NO SE SALGA LA SESIÓN
  void checkAuthStatus() async {
    // 1. Buscamos el token en el almacenamiento local (SharedPrefs)
    final token = await keyValueStorageService.getValue<String>('token');
    
    // 2. Si no hay token, el estado es no autenticado
    if (token == null) {
      state = state.copyWith(authStatus: AuthStatus.notAuthenticated);
      return;
    }

    try {
      // 3. Si hay token, validamos con el backend si sigue siendo válido
      final user = await authRepository.checkAuthStatus(token);
      _setLoggedUser(user);
    } catch (e) {
      // 4. Si el token expiró o falló la red, cerramos sesión
      logout();
    }
  }

  void _setLoggedUser(User user) async {
    // PERSISTENCIA: Guardamos el token en el disco
    await keyValueStorageService.setKeyValue('token', user.token);
    
    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
    );
  }

  Future<void> logout([String? errorMessage]) async {
    // LIMPIEZA: Borramos el token del disco
    await keyValueStorageService.removeKey('token');
    
    state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        user: null,
        errorMessage: errorMessage ?? ''
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
    this.authStatus = AuthStatus.checking, // Estado inicial siempre es checking
    this.user,
    this.errorMessage = ''
  });

  AuthState copyWith({
    AuthStatus? authStatus, 
    User? user, 
    String? errorMessage
  }) => AuthState(
      authStatus: authStatus ?? this.authStatus,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage
  );
}