import 'package:formz/formz.dart';

// --- VALIDACIÓN DE EMAIL ---
enum EmailError { empty, format }

class Email extends FormzInput<String, EmailError> {
  static final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  const Email.pure() : super.pure('');
  const Email.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == EmailError.empty) return 'El correo es requerido';
    if (displayError == EmailError.format) return 'Formato de correo no válido';
    return null;
  }

  @override
  EmailError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return EmailError.empty;
    if (!emailRegExp.hasMatch(value)) return EmailError.format;
    return null;
  }
}

// --- VALIDACIÓN DE DNI ---
enum DniError { empty, length }

class Dni extends FormzInput<String, DniError> {
  const Dni.pure() : super.pure('');
  const Dni.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == DniError.empty) return 'El DNI es requerido';
    if (displayError == DniError.length) return 'El DNI debe tener 9 caracteres';
    return null;
  }

  @override
  DniError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return DniError.empty;
    if (value.length < 9) return DniError.length;
    return null;
  }
}

// --- VALIDACIÓN DE TEXTO GENÉRICO (Nombre, Apellidos, etc.) ---
enum GeneralTextError { empty }

class GeneralText extends FormzInput<String, GeneralTextError> {
  const GeneralText.pure() : super.pure('');
  const GeneralText.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    return 'Este campo es obligatorio';
  }

  @override
  GeneralTextError? validator(String value) {
    return (value.isEmpty || value.trim().isEmpty) ? GeneralTextError.empty : null;
  }
}