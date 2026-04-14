class Autoridad {
  final String id;
  final String codAutoridad;
  final String nombreAutoridad;
  final String nombreSaluda;
  final String cargo;
  final String direccion;
  final String telefono;
  final String email;
  final String observaciones;
  final int? tipoautoridadId;
  final String tipoautoridadName;
  final int? localidadId;
  final String localidadName;

  Autoridad({
    required this.id,
    required this.codAutoridad,
    required this.nombreAutoridad,
    required this.nombreSaluda,
    required this.cargo,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.observaciones,
    this.tipoautoridadId,
    this.tipoautoridadName = '',
    this.localidadId,
    this.localidadName = '',
  });

  factory Autoridad.fromJson(Map<String, dynamic> json) => Autoridad(
    id: json["id"].toString(),
    codAutoridad: json["codAutoridad"] ?? '',
    nombreAutoridad: json["nombreAutoridad"] ?? '',
    nombreSaluda: json["nombreSaluda"] ?? '',
    cargo: json["cargo"] ?? '',
    direccion: json["direccion"] ?? '',
    telefono: json["telefono"] ?? '',
    email: json["correoElectronico"] ?? '', // Mapeo del nombre de Odoo
    observaciones: json["observaciones"] ?? '',
    tipoautoridadId: json["tipoautoridad_id"],
    tipoautoridadName: json["tipoautoridad_name"] ?? '',
    localidadId: json["localidad_id"],
    localidadName: json["localidad_name"] ?? '',
  );
}