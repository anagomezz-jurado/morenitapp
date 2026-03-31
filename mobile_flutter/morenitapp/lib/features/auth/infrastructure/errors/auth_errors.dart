

class ConnectionTimeout implements Exception {}
class InvalidToken implements Exception {}
class WrongCredentials implements Exception {}

class CustomError implements Exception {
  final String message;
  // final int? statusCode; // opcional

  CustomError(this.message);

  @override
  String toString() => message; // Esto hace que al hacer e.toString() salga el texto y no "Instance of..."
}

