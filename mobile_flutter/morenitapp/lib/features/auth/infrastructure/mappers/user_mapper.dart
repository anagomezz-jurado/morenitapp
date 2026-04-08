import 'package:morenitapp/features/auth/domain/entities/user.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) {
    // Si viene de Odoo 'result', lo extraemos
    final data = json['result'] ?? json;

    return User(
      id: (data['id'] ?? 0).toString(),
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? data['name'] ?? '',
      apellido1: data['apellido1'] ?? '',
      apellido2: data['apellido2'] ?? '',
      telefono: data['telefono'] ?? '',
      rolId: _parseRol(data['rol_id']),
      roles: (data['roles'] != null) 
          ? List<String>.from(data['roles']) 
          : [_getRoleName(_parseRol(data['rol_id']))],
      token: (data['token'] ?? data['id'] ?? '').toString(),
      recibirNotiEmail: _parseBool(data['recibirNotiEmail'], defaultValue: true),
      recibirNotiTelefono: _parseBool(data['recibirNotiTelefono'], defaultValue: false),
    );
  }

  static int _parseRol(dynamic rol) {
    if (rol is int) return rol;
    if (rol is List && rol.isNotEmpty) return rol[0] as int;
    return 2;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    return defaultValue;
  }

  static String _getRoleName(int id) => (id == 1) ? 'admin' : 'user';
}