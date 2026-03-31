class Calle {
  final int id;
  final String nombreCalle;
  final int localidadId;
  final int codPostalId;
  final int? responsableId;

  Calle({
    required this.id,
    required this.nombreCalle,
    required this.localidadId,
    required this.codPostalId,
    this.responsableId,
  });

  factory Calle.fromJson(Map<String, dynamic> json) {
    // Función para limpiar valores de Odoo (ID o false)
    int cleanId(dynamic val) {
      if (val == null || val == false) return 0;
      if (val is List && val.isNotEmpty) return val[0] as int;
      return (val is int) ? val : 0;
    }

    return Calle(
      id: cleanId(json['id']),
      nombreCalle: json['nombreCalle'] ?? json['display_name'] ?? 'Sin nombre',
      localidadId: cleanId(json['localidad_id']),
      codPostalId: cleanId(json['codPostal_id']),
      responsableId: (json['responsable_id'] == false) ? null : cleanId(json['responsable_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'nombreCalle': nombreCalle,
    'localidad_id': localidadId,
    'codPostal_id': codPostalId,
    if (responsableId != null) 'responsable_id': responsableId,
  };
}