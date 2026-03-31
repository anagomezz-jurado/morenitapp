// dni.dart
import 'package:formz/formz.dart';

enum DniError { empty, format }

class Dni extends FormzInput<String, DniError> {
  const Dni.pure() : super.pure('');
  const Dni.dirty(String value) : super.dirty(value);

  static final RegExp dniRegExp = RegExp(r'^[0-9]{8}[A-Z]$');

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == DniError.empty) return 'El DNI es requerido';
    if (displayError == DniError.format) return 'Formato incorrecto (8 números y letra)';
    return null;
  }

  @override
  DniError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return DniError.empty;
    if (!dniRegExp.hasMatch(value.toUpperCase())) return DniError.format;
    return null;
  }
}

// iban_account.dart (Para la cuenta de 10 dígitos)
enum AccountError { empty, length }

class BankAccount extends FormzInput<String, AccountError> {
  const BankAccount.pure() : super.pure('');
  const BankAccount.dirty(String value) : super.dirty(value);

  @override
  AccountError? validator(String value) {
    if (value.isEmpty) return AccountError.empty;
    if (value.length != 10) return AccountError.length;
    return null;
  }
}