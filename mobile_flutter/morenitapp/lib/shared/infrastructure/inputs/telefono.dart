import 'package:formz/formz.dart';

enum PhoneError { empty, format, alreadyInUse }

class Phone extends FormzInput<String, PhoneError> {

  final bool alreadyExists;

  static final RegExp phoneRegExp = RegExp(r'^[0-9+]{9,15}$');

  // PURE
  const Phone.pure()
      : alreadyExists = false,
        super.pure('');

  // DIRTY (IMPORTANTE 👇)
  const Phone.dirty(
    String value, {
    this.alreadyExists = false,
  }) : super.dirty(value);

  // ERROR MESSAGE
  String? get errorMessage {
    if (isPure) return null;

    if (alreadyExists) return 'Este número ya está registrado';

    if (displayError == PhoneError.empty) return 'El teléfono es requerido';
    if (displayError == PhoneError.format) return 'Número de teléfono no válido';

    return null;
  }

  // VALIDATOR
  @override
  PhoneError? validator(String value) {
    if (value.trim().isEmpty) return PhoneError.empty;
    if (!phoneRegExp.hasMatch(value)) return PhoneError.format;
    return null;
  }
}