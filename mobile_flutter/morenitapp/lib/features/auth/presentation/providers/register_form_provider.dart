import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/shared/infrastructure/inputs/inputs.dart';

//! 1. State del Provider
class RegisterFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final bool aceptaTerminos;

  final FullName nombre;
  final FullName apellido1;
  final FullName apellido2;
  final Email email;
  final Password password;
  final Password passwordConfirmation;
  final Phone telefono;

  final bool recibirNotiEmail;

  RegisterFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.aceptaTerminos = false,
    this.nombre = const FullName.pure(),
    this.apellido1 = const FullName.pure(),
    this.apellido2 = const FullName.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.passwordConfirmation = const Password.pure(),
    this.telefono = const Phone.pure(),
    this.recibirNotiEmail = true,
  });

  RegisterFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    bool? aceptaTerminos,
    FullName? nombre,
    FullName? apellido1,
    FullName? apellido2,
    Email? email,
    Password? password,
    Password? passwordConfirmation,
    Phone? telefono,
    bool? recibirNotiEmail,
  }) => RegisterFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    aceptaTerminos: aceptaTerminos ?? this.aceptaTerminos,
    nombre: nombre ?? this.nombre,
    apellido1: apellido1 ?? this.apellido1,
    apellido2: apellido2 ?? this.apellido2,
    email: email ?? this.email,
    password: password ?? this.password,
    passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
    telefono: telefono ?? this.telefono,
    recibirNotiEmail: recibirNotiEmail ?? this.recibirNotiEmail,
  );
}

//! 2. Notifier
class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  
  final Function({
    required String email,
    required String password,
    required String nombre,
    required String apellido1,
    required String apellido2,
    required String telefono,
    required bool recibirNotiEmail,  }) registerUserCallback;

  final Ref ref;

  RegisterFormNotifier({
    required this.registerUserCallback,
    required this.ref,
  }) : super(RegisterFormState());

  void _clearServerError() {
    if (ref.read(authProvider).errorMessage.isNotEmpty) {
      ref.read(authProvider.notifier).clearErrorMessage();
    }
  }

  // --- Manejadores de cambios ---

  onNombreChange(String value) {
    final newNombre = FullName.dirty(value);
    state = state.copyWith(
      nombre: newNombre,
      isValid: _validateForm(nombre: newNombre)
    );
  }

  onApellido1Change(String value) {
    final newApellido = FullName.dirty(value);
    state = state.copyWith(
      apellido1: newApellido,
      isValid: _validateForm(apellido1: newApellido)
    );
  }

  onApellido2Change(String value) {
    final newApellido = FullName.dirty(value);
    state = state.copyWith(
      apellido2: newApellido,
      isValid: _validateForm(apellido2: newApellido)
    );
  }

  onTelefonoChange(String value) {
    _clearServerError(); 
    final newTelefono = Phone.dirty(value);
    state = state.copyWith(
      telefono: newTelefono,
      isValid: _validateForm(telefono: newTelefono)
    );
  }

  onEmailChange(String value) {
    _clearServerError();
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: _validateForm(email: newEmail)
    );
  }

  onPasswordChange(String value) {
    final newPassword = Password.dirty(value);
    // Al cambiar la contraseña, debemos re-validar la confirmación también
    state = state.copyWith(
      password: newPassword,
      isValid: _validateForm(password: newPassword)
    );
  }

  onPasswordConfirmationChange(String value) {
    final newConfirmation = Password.dirty(value);
    state = state.copyWith(
      passwordConfirmation: newConfirmation,
      isValid: _validateForm(passwordConfirmation: newConfirmation)
    );
  }

  // Helper para no repetir la lista de Formz.validate en cada método
  bool _validateForm({
    FullName? nombre,
    FullName? apellido1,
    FullName? apellido2,
    Email? email,
    Password? password,
    Password? passwordConfirmation,
    Phone? telefono,
  }) {
    // Validamos que todos los campos sean correctos según sus reglas individuales
    final isFieldsValid = Formz.validate([
      nombre ?? state.nombre,
      apellido1 ?? state.apellido1,
      apellido2 ?? state.apellido2,
      email ?? state.email,
      password ?? state.password,
      passwordConfirmation ?? state.passwordConfirmation,
      telefono ?? state.telefono,
    ]);

    // Lógica extra: Las contraseñas deben ser idénticas
    final doPasswordsMatch = (password ?? state.password).value == 
                             (passwordConfirmation ?? state.passwordConfirmation).value;

    return isFieldsValid && doPasswordsMatch;
  }

  onNotiEmailChange(bool value) => state = state.copyWith(recibirNotiEmail: value);
  onTerminosChanged(bool value) {
    state = state.copyWith(
      aceptaTerminos: value,
      isValid: _validateForm() // Revalidamos el formulario total
    );
  }

  // --- Submit ---

  onFormSubmit() async {
    _touchEveryField();
    
    // Verificación final de seguridad
    if (!state.isValid || !state.aceptaTerminos) return;
    if (state.password.value != state.passwordConfirmation.value) {
       // Aquí podrías lanzar un error visual de "Contraseñas no coinciden"
       return;
    }

    state = state.copyWith(isPosting: true);

    await registerUserCallback(
      email: state.email.value,
      password: state.password.value,
      nombre: state.nombre.value,
      apellido1: state.apellido1.value,
      apellido2: state.apellido2.value,
      telefono: state.telefono.value,
      recibirNotiEmail: state.recibirNotiEmail,
    );

    state = state.copyWith(isPosting: false);
  }

  _touchEveryField() {
    final nombre   = FullName.dirty(state.nombre.value);
    final ap1      = FullName.dirty(state.apellido1.value);
    final ap2      = FullName.dirty(state.apellido2.value);
    final email    = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    final conf     = Password.dirty(state.passwordConfirmation.value);
    final telefono = Phone.dirty(state.telefono.value);

    state = state.copyWith(
      isFormPosted: true,
      nombre: nombre,
      apellido1: ap1,
      apellido2: ap2,
      email: email,
      password: password,
      passwordConfirmation: conf,
      telefono: telefono,
      isValid: _validateForm(
        nombre: nombre, 
        apellido1: ap1, 
        apellido2: ap2, 
        email: email, 
        password: password, 
        passwordConfirmation: conf, 
        telefono: telefono
      )
    );
  }
}

final registerFormProvider = StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>((ref) {
  final registerUserCallback = ref.watch(authProvider.notifier).registerUser;
  return RegisterFormNotifier(
    registerUserCallback: registerUserCallback,
    ref: ref
  );
});