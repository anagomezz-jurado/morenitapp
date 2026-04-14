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
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});
// --- NOTIFIER ---
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;

  AuthNotifier({
    required this.authRepository,
    required this.keyValueStorageService,
  }) : super(AuthState()) {
    checkAuthStatus();
  }

  // Limpiar mensajes de error manualmente si es necesario
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

  Future<void> registerUser({
    required String email,
    required String password,
    required String nombre,
    required String apellido1,
    required String apellido2,
    required String telefono,
    bool recibirNotiEmail = true,
    bool recibirNotiTelefono = false,
  }) async {
    // Resetear estado de error antes de intentar
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
        recibirNotiTelefono: recibirNotiTelefono,
      );
      
      _setLoggedUser(user);
      
    } on CustomError catch (e) {
      // Aquí es donde capturamos el error "Email already exists" del Repositorio
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        errorMessage: e.message, // Ejemplo: "El correo ya está en uso"
      );
    } catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        errorMessage: 'Error no controlado durante el registro',
      );
    }
  }

  void checkAuthStatus() async {
    final token = await keyValueStorageService.getValue<String>('token');
    if (token == null) {
      state = state.copyWith(authStatus: AuthStatus.notAuthenticated);
      return;
    }

    try {
      final user = await authRepository.checkAuthStatus(token);
      _setLoggedUser(user);
    } catch (e) {
      logout();
    }
  }

  void _setLoggedUser(User user) async {
    await keyValueStorageService.setKeyValue('token', user.token);
    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
    );
  }

  Future<void> logout([String? errorMessage]) async {
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