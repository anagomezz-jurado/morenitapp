// shared/infrastructure/inputs/email.dart
import 'package:formz/formz.dart';

enum EmailError { empty, format, alreadyInUse }

class Email extends FormzInput<String, EmailError> {
  static final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  
  final bool alreadyExists;

  const Email.pure() : alreadyExists = false, super.pure('');
  const Email.dirty(String value, {this.alreadyExists = false}) : super.dirty(value);

  String? get errorMessage {
    if (isPure) return null;
    if (alreadyExists) return 'Este correo ya está registrado'; 
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