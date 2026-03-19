import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_state.dart';
import '../services/api_service.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final ApiService apiService;

  RegisterCubit(this.apiService) : super(const RegisterState());

  // Métodos de cambio de campo
  void emailChanged(String value) => emit(state.copyWith(email: value));
  void nombreChanged(String value) => emit(state.copyWith(nombre: value));
  void apellido1Changed(String value) => emit(state.copyWith(apellido1: value));
  void apellido2Changed(String value) => emit(state.copyWith(apellido2: value));
  void passwordChanged(String value) => emit(state.copyWith(contrasena: value));
  void telefonoChanged(String value) => emit(state.copyWith(telefono: value));
  void notiEmail(bool value) => emit(state.copyWith(recibirNotiEmail: value));
  void notiTelefono(bool value) => emit(state.copyWith(recibirNotiTelefono: value));

  Future<bool> onSubmit() async {
    if (state.email.isEmpty || state.contrasena.isEmpty || state.nombre.isEmpty) {
       emit(state.copyWith(status: FormStatus.error, errorMessage: "Rellena los campos obligatorios"));
       return false;
    }

    emit(state.copyWith(status: FormStatus.posting));

    try {
      await apiService.crearUsuario(
        nombre: state.nombre,
        apellido1: state.apellido1,
        apellido2: state.apellido2,
        email: state.email,
        contrasena: state.contrasena,
        telefono: state.telefono,
        recibirNotiEmail: state.recibirNotiEmail,
        recibirNotiTelefono: state.recibirNotiTelefono,
        rol_id: 2, // Usuario Estándar
      );
      
      emit(state.copyWith(status: FormStatus.success));
      return true;
    } catch (e) {
      emit(state.copyWith(status: FormStatus.error, errorMessage: e.toString()));
      return false;
    }
  }
}