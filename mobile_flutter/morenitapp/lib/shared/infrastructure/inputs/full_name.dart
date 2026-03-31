// lib/features/shared/infrastructure/inputs/full_name.dart
import 'package:formz/formz.dart';

enum FullNameError { empty, length }

class FullName extends FormzInput<String, FullNameError> {
  const FullName.pure() : super.pure('');
  const FullName.dirty( String value ) : super.dirty(value);

  String? get errorMessage {
    if ( isValid || isPure ) return null;
    if ( displayError == FullNameError.empty ) return 'El nombre es requerido';
    if ( displayError == FullNameError.length ) return 'Nombre demasiado corto';
    return null;
  }

  @override
  FullNameError? validator(String value) {
    if ( value.isEmpty || value.trim().isEmpty ) return FullNameError.empty;
    if ( value.length < 2 ) return FullNameError.length;
    return null;
  }
}