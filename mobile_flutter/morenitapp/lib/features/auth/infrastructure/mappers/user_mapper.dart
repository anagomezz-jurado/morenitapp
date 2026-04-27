import 'package:morenitapp/features/auth/domain/entities/user.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) {
    // Si la respuesta viene de Odoo JSON-RPC, suele estar en 'user' o directamente en el body
    final data = json['user'] ?? json;

    // Función robusta para extraer IDs de Odoo (Many2one)
    int getOdooId(dynamic field) {
      if (field == null || field == false) return 0;
      if (field is int) return field;
      if (field is List && field.isNotEmpty) return field[0] as int;
      return int.tryParse(field.toString()) ?? 0;
    }

    return User(
      id: (data['id'] ?? 0).toString(),
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      apellido1: data['apellido1'] ?? '',
      apellido2: data['apellido2'] ?? '',
      telefono: data['telefono'] ?? '',
      token: (data['token'] ?? data['id'] ?? '').toString(),
      
      // Mapeamos los IDs técnicos que usaremos para la lógica isAdmin
      rolId: data['rol_id'] is List ? data['rol_id'][0] : (data['rol_id'] ?? 2),
      grupoId: getOdooId(data['grupo_id']),

      roles: (data['roles'] != null) ? List<String>.from(data['roles']) : [],
      recibirNotiEmail: data['recibirNotiEmail'] ?? true,
      recibirNotiTelefono: data['recibirNotiTelefono'] ?? false, rolName: '', grupoName: '',
    );
  }
}