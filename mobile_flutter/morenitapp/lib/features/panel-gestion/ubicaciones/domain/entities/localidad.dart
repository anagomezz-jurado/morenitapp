class Localidad {
  final int id;
  final String nombreLocalidad;
  final int codProvinciaId;

  Localidad({
    this.id = 0,
    required this.nombreLocalidad,
    required this.codProvinciaId,
  });

  factory Localidad.fromJson(Map<String, dynamic> json) {
  return Localidad(
    id: json['id'] ?? 0,
    nombreLocalidad: json['nombreLocalidad'] is String ? json['nombreLocalidad'] : '',
    codProvinciaId: json['codProvincia_id'] is List
        ? json['codProvincia_id'][0]
        : (json['codProvincia_id'] ?? 0),
  );
}

  Map<String, dynamic> toJson() => {
        'nombreLocalidad': nombreLocalidad,
        'codProvincia_id': codProvinciaId,
      };

  Localidad copyWith({
    int? id,
    String? nombreLocalidad,
    int? codProvinciaId,
  }) {
    return Localidad(
      id: id ?? this.id,
      nombreLocalidad: nombreLocalidad ?? this.nombreLocalidad,
      codProvinciaId: codProvinciaId ?? this.codProvinciaId,
    );
  }
}
