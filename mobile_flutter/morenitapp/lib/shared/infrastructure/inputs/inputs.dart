import 'package:formz/formz.dart';

export 'dni.dart';
export 'telefono.dart';
export 'email.dart';
export 'full_name.dart';
export 'password.dart';


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