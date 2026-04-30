import 'package:flutter/material.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) {
    final data = json['user'] ?? json;

    // Esta función es CRÍTICA: convierte los 'false' de Odoo en Strings vacíos
    String odooString(dynamic val) {
      if (val == null || val == false || val.toString() == 'false') return '';
      if (val is List && val.length > 1)
        return val[1].toString(); // Para campos Many2one
      return val.toString();
    }

    int getOdooId(dynamic field) {
      if (field == null || field == false) return 0;
      if (field is int) return field;
      if (field is List && field.isNotEmpty) return field[0] as int;
      return int.tryParse(field.toString()) ?? 0;
    }

    return User(
      id: (data['id'] ?? 0).toString(),
      nombre: odooString(data['nombre']),
      apellido1: odooString(data['apellido1']),
      apellido2: odooString(data['apellido2']),
      email: odooString(data['email']),
      telefono: odooString(data['telefono']),
      token: (data['token'] ?? data['id'] ?? '').toString(),

      // Vinculación de hermano
      hermanoId: getOdooId(data['hermano_id']),
      numeroHermano: () {
        final raw = data['numero_hermano'];
        debugPrint(
            '>>> numero_hermano raw desde Odoo: $raw'); // Quitar tras depurar
        if (raw == null ||
            raw == false ||
            raw.toString() == 'false' ||
            raw.toString().isEmpty) {
          return 'No vinculado';
        }
        return raw.toString();
      }(),

      rolId: data['rol_id'] is List ? data['rol_id'][0] : (data['rol_id'] ?? 2),
      rolName: odooString(data['rol_name'] ?? 'Usuario'),
      grupoId: getOdooId(data['grupo_id']),
      grupoName: odooString(data['grupo_name'] ?? 'Sin grupo'),
      roles: (data['roles'] != null) ? List<String>.from(data['roles']) : [],
      recibirNotiEmail: data['recibirNotiEmail'] ?? true,
    );
  }
}
