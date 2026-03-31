import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
// Asegúrate de tener estas clases de validación en tu carpeta shared/infrastructure/inputs
import 'package:morenitapp/shared/infrastructure/inputs/email.dart';
import 'package:morenitapp/shared/infrastructure/inputs/full_name.dart';
import 'package:morenitapp/shared/infrastructure/inputs/password.dart'; 

//! 1. State del Provider
class RegisterFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final FullName fullName; // Validación para el nombre
  final Email email;
  final Password password;

  RegisterFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.fullName = const FullName.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
  });

  RegisterFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    FullName? fullName,
    Email? email,
    Password? password,
  }) => RegisterFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    password: password ?? this.password,
  );
}

//! 2. Notifier - Lógica
class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  
  final Function(String, String, String) registerUserCallback;

  RegisterFormNotifier({
    required this.registerUserCallback,
  }): super( RegisterFormState() );

  onFullNameChange( String value ) {
    final newFullName = FullName.dirty(value);
    state = state.copyWith(
      fullName: newFullName,
      isValid: Formz.validate([ newFullName, state.email, state.password ])
    );
  }

  onEmailChange( String value ) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: Formz.validate([ newEmail, state.fullName, state.password ])
    );
  }

  onPasswordChange( String value ) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: Formz.validate([ newPassword, state.fullName, state.email ])
    );
  }

  onFormSubmit() async {
    _touchEveryField();
    if ( !state.isValid ) return;

    state = state.copyWith(isPosting: true);

    // Llamamos al método registerUser del authProvider
    await registerUserCallback( 
      state.email.value, 
      state.password.value, 
      state.fullName.value 
    );

    state = state.copyWith(isPosting: false);
  }

  _touchEveryField() {
    final fullName = FullName.dirty(state.fullName.value);
    final email    = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
      isFormPosted: true,
      fullName: fullName,
      email: email,
      password: password,
      isValid: Formz.validate([ fullName, email, password ])
    );
  }
}

//! 3. Provider - Consumo
final registerFormProvider = StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>((ref) {
  
  // Obtenemos la función de registro del authProvider
  final registerUserCallback = ref.watch(authProvider.notifier).registerUser;

  return RegisterFormNotifier(
    registerUserCallback: registerUserCallback
  );
});