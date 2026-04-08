import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/shared/infrastructure/inputs/full_name.dart';
import 'package:morenitapp/shared/infrastructure/inputs/inputs.dart';
import 'package:morenitapp/shared/infrastructure/inputs/password.dart';
import 'package:morenitapp/shared/infrastructure/inputs/telefono.dart';

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
  final Phone telefono; // Correcto: tipo Phone

  final bool recibirNotiEmail;
  final bool recibirNotiTelefono;

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
    this.recibirNotiTelefono = false,
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
    bool? recibirNotiTelefono,
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
    recibirNotiTelefono: recibirNotiTelefono ?? this.recibirNotiTelefono,
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
    required bool recibirNotiEmail,
    required bool recibirNotiTelefono,
  }) registerUserCallback;

  // Añadimos una referencia al ref para poder limpiar errores del authProvider
  final Ref ref;

  RegisterFormNotifier({
    required this.registerUserCallback,
    required this.ref,
  }) : super(RegisterFormState());

  // Método privado para limpiar errores del servidor al empezar a escribir
  void _clearServerError() {
    if (ref.read(authProvider).errorMessage.isNotEmpty) {
      ref.read(authProvider.notifier).clearErrorMessage();
    }
  }

  onNombreChange(String value) {
    final newNombre = FullName.dirty(value);
    state = state.copyWith(
      nombre: newNombre,
      isValid: Formz.validate([newNombre, state.apellido1, state.apellido2, state.email, state.password, state.passwordConfirmation, state.telefono])
    );
  }

  onApellido1Change(String value) {
    final newApellido = FullName.dirty(value);
    state = state.copyWith(
      apellido1: newApellido,
      isValid: Formz.validate([state.nombre, newApellido, state.apellido2, state.email, state.password, state.passwordConfirmation, state.telefono])
    );
  }

  onApellido2Change(String value) {
    final newApellido = FullName.dirty(value);
    state = state.copyWith(
      apellido2: newApellido,
      isValid: Formz.validate([state.nombre, state.apellido1, newApellido, state.email, state.password, state.passwordConfirmation, state.telefono])
    );
  }

  onTelefonoChange(String value) {
    _clearServerError(); // Limpiamos error de "teléfono ya existe"
    final newTelefono = Phone.dirty(value); // CORREGIDO: Phone, no FullName
    state = state.copyWith(
      telefono: newTelefono,
      isValid: Formz.validate([state.nombre, state.apellido1, state.apellido2, state.email, state.password, state.passwordConfirmation, newTelefono])
    );
  }

  onEmailChange(String value) {
    _clearServerError(); // Limpiamos error de "email ya existe"
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: Formz.validate([newEmail, state.nombre, state.apellido1, state.apellido2, state.password, state.passwordConfirmation, state.telefono])
    );
  }

  onPasswordChange(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: Formz.validate([newPassword, state.passwordConfirmation, state.nombre, state.apellido1, state.apellido2, state.email, state.telefono])
    );
  }

  onPasswordConfirmationChange(String value) {
    final newConfirmation = Password.dirty(value);
    state = state.copyWith(
      passwordConfirmation: newConfirmation,
      isValid: Formz.validate([state.password, newConfirmation, state.nombre, state.apellido1, state.apellido2, state.email, state.telefono])
    );
  }

  onNotiEmailChange(bool value) => state = state.copyWith(recibirNotiEmail: value);
  onNotiTelefonoChange(bool value) => state = state.copyWith(recibirNotiTelefono: value);
  onTerminosChanged(bool value) => state = state.copyWith(aceptaTerminos: value);

  onFormSubmit() async {
    _touchEveryField();
    if (!state.isValid || !state.aceptaTerminos) return;
    if (state.password.value != state.passwordConfirmation.value) return;

    state = state.copyWith(isPosting: true);

    await registerUserCallback(
      email: state.email.value,
      password: state.password.value,
      nombre: state.nombre.value,
      apellido1: state.apellido1.value,
      apellido2: state.apellido2.value,
      telefono: state.telefono.value,
      recibirNotiEmail: state.recibirNotiEmail,
      recibirNotiTelefono: state.recibirNotiTelefono,
    );

    state = state.copyWith(isPosting: false);
  }

  _touchEveryField() {
    final nombre    = FullName.dirty(state.nombre.value);
    final ap1       = FullName.dirty(state.apellido1.value);
    final ap2       = FullName.dirty(state.apellido2.value);
    final email     = Email.dirty(state.email.value);
    final password  = Password.dirty(state.password.value);
    final conf      = Password.dirty(state.passwordConfirmation.value);
    final telefono  = Phone.dirty(state.telefono.value); // CORREGIDO: Phone, no FullName

    state = state.copyWith(
      isFormPosted: true,
      nombre: nombre,
      apellido1: ap1,
      apellido2: ap2,
      email: email,
      password: password,
      passwordConfirmation: conf,
      telefono: telefono,
      isValid: Formz.validate([nombre, ap1, ap2, email, password, conf, telefono])
    );
  }
}

final registerFormProvider = StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>((ref) {
  final registerUserCallback = ref.watch(authProvider.notifier).registerUser;
  // Pasamos el ref al notifier para gestionar la limpieza de errores
  return RegisterFormNotifier(
    registerUserCallback: registerUserCallback,
    ref: ref
  );
});