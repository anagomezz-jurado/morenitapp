class Autoridad {
  final String id;
  final String codAutoridad;
  final String nombreAutoridad;
  final String cargo;
  final String email;
  final String telefono;
  final int? tipoAutoridadId;
  final String nombreSaluda;

  Autoridad({
    required this.id,
    required this.codAutoridad,
    required this.nombreAutoridad,
    required this.cargo,
    required this.email,
    required this.telefono,
    this.tipoAutoridadId,
    required this.nombreSaluda,
  });

  factory Autoridad.fromJson(Map<String, dynamic> json) {
    return Autoridad(
      id: json['id']?.toString() ?? '',
      codAutoridad: json['codAutoridad']?.toString() ?? '',
      nombreAutoridad: json['nombreAutoridad']?.toString() ?? '',
      cargo: json['cargo']?.toString() ?? '',
      // Odoo envía 'false' (bool) si el string está vacío
      email: (json['email'] is String) ? json['email'] : '',
      telefono: (json['telefono'] is String) ? json['telefono'] : '',
      tipoAutoridadId: (json['tipo_id'] is int) ? json['tipo_id'] : null,
      nombreSaluda: json['nombreSaluda']?.toString() ?? '',
    );
  }
}