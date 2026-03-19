import 'package:equatable/equatable.dart';

enum FormStatus { invalid, valid, validating, posting, success, error }

class RegisterState extends Equatable {
  final FormStatus status;
  final String? errorMessage;
  final String nombre;
  final String apellido1;
  final String apellido2;
  final String email;
  final String contrasena; // Cambiado de 'password' a 'contrasena'
  final String telefono;
  final bool recibirNotiEmail;
  final bool recibirNotiTelefono; // Corregido: 'recibirNotiTelfono' -> 'recibirNotiTelefono'

  const RegisterState({
    this.status = FormStatus.invalid,
    this.errorMessage,
    this.nombre = '',
    this.apellido1 = '',
    this.apellido2 = '',
    this.email = '',
    this.contrasena = '',
    this.telefono = '',
    this.recibirNotiEmail = true,
    this.recibirNotiTelefono = false,
  });

  RegisterState copyWith({
    FormStatus? status,
    String? errorMessage,
    String? nombre,
    String? apellido1,
    String? apellido2,
    String? email,
    String? contrasena,
    String? telefono,
    bool? recibirNotiEmail,
    bool? recibirNotiTelefono,
  }) => RegisterState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    nombre: nombre ?? this.nombre,
    apellido1: apellido1 ?? this.apellido1,
    apellido2: apellido2 ?? this.apellido2,
    email: email ?? this.email,
    contrasena: contrasena ?? this.contrasena,
    telefono: telefono ?? this.telefono,
    recibirNotiEmail: recibirNotiEmail ?? this.recibirNotiEmail,
    recibirNotiTelefono: recibirNotiTelefono ?? this.recibirNotiTelefono,
  );

  @override
  List<Object?> get props => [status, errorMessage, nombre, apellido1, apellido2, email, contrasena, telefono, recibirNotiEmail, recibirNotiTelefono];
}