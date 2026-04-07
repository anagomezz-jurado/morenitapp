import 'package:morenitapp/features/auth/domain/entities/user.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) {
    // 1. Extraemos la data real. 
    // Si viene de una lista (Panel Admin), el objeto ya es el usuario.
    // Si viene del Login, viene envuelto en 'result'.
    final data = json['result'] ?? json;

    return User(
      // Nos aseguramos que el ID siempre sea String, aunque Odoo mande int
      id: (data['id'] ?? 0).toString(),
      email: data['email'] ?? '',
      // Mapeamos 'nombre' (tu modelo) o 'name' (estándar Odoo)
      fullName: data['nombre'] ?? data['name'] ?? 'Sin Nombre',
      // Usamos el ID como token de respaldo si no viene uno explícito
      token: data['token'] ?? (data['id'] ?? '').toString(),
      // El rolId es vital para tu lógica de isAdmin
      rolId: _parseRol(data['rol_id']), 
      roles: (data['roles'] != null) ? List<String>.from(data['roles']) : [],
    );
  }

  // Helper para limpiar el rol_id (Odoo a veces manda [1, "Admin"] en Many2one)
  static int _parseRol(dynamic rol) {
    if (rol is int) return rol;
    if (rol is List && rol.isNotEmpty) return rol[0] as int;
    return 2; // Default User
  }
}