

class ConnectionTimeout implements Exception {}
class InvalidToken implements Exception {}
class WrongCredentials implements Exception {}

class CustomError implements Exception {
  final String message;

  CustomError(this.message);

  @override
  String toString() => message;
}

