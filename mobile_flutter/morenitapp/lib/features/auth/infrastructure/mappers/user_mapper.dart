import 'package:morenitapp/features/auth/domain/entities/user.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) {
    // Si Odoo envuelve la respuesta en 'result', la extraemos
    final data = json['result'] ?? json;

    return User(
      id: (data['id'] ?? 0).toString(),
      email: data['email'] ?? '',
      fullName: data['nombre'] ?? data['fullName'] ?? '',
      token: data['token'] ?? '',
      // Mapeamos el rol_id que viene de tu base de datos de Odoo
      rolId: data['rol_id'] ?? 2, // Por defecto 2 (usuario) si viene nulo
      roles: [], // Puedes llenarlo si Odoo manda una lista de strings
    );
  }
}