class Calle {
  final int id;
  final String nombreCalle;
  final int localidadId;
  final String nombreLocalidad;
  final int codPostalId;
  final String nombreCP;
  final int? responsableId;

  Calle({
    required this.id,
    required this.nombreCalle,
    required this.localidadId,
    required this.nombreLocalidad,
    required this.codPostalId,
    required this.nombreCP,
    this.responsableId,
  });

  factory Calle.fromJson(Map<String, dynamic> json) {
    int cleanId(dynamic val) {
      if (val == null || val == false) return 0;
      if (val is List && val.isNotEmpty) return val[0] as int;
      return (val is int) ? val : 0;
    }

    String cleanName(dynamic val, String fallback) {
      if (val == null || val == false) return fallback;
      if (val is List && val.length > 1) return val[1].toString();
      if (val is String) return val;
      return fallback;
    }

    final rawLoc = json['localidad_id'] ?? json['localidadId'];
    final rawCP =
        json['codPostal_id'] ?? json['codPostalId'] ?? json['cod_postal_id'];

    return Calle(
      id: cleanId(json['id']),
      nombreCalle: (json['nombreCalle'] ?? json['display_name'] ?? 'Sin nombre')
          .toString(),
      localidadId: cleanId(rawLoc),
      nombreLocalidad: cleanName(rawLoc, 'Localidad no encontrada'),
      codPostalId: cleanId(rawCP),
      nombreCP: cleanName(rawCP, 'CP no encontrado'),
      responsableId: (json['responsable_id'] == false)
          ? null
          : cleanId(json['responsable_id']),
    );
  }

  Map<String, dynamic> toJson() => {
        'nombreCalle': nombreCalle,
        'localidad_id': localidadId,
        'codPostal_id': codPostalId,
        if (responsableId != null) 'responsable_id': responsableId,
      };
}
