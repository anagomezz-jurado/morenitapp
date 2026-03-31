class Localidad {
  final int id;
  final String nombreLocalidad;
  final int codProvinciaId;
  final String nombreCapital;

  Localidad({
    this.id = 0,
    required this.nombreLocalidad,
    required this.codProvinciaId,
    required this.nombreCapital,
  });

  factory Localidad.fromJson(Map<String, dynamic> json) {
    return Localidad(
      id: json['id'] ?? 0,
      nombreLocalidad: json['nombreLocalidad'] ?? '',
      nombreCapital: json['nombreCapital'] ?? '',
      codProvinciaId: json['codProvincia_id'] is List 
          ? json['codProvincia_id'][0] 
          : (json['codProvincia_id'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'nombreLocalidad': nombreLocalidad,
    'codProvincia_id': codProvinciaId,
    'nombreCapital': nombreCapital,
  };

  Localidad copyWith({
    int? id,
    String? nombreLocalidad,
    int? codProvinciaId,
    String? nombreCapital,
  }) {
    return Localidad(
      id: id ?? this.id,
      nombreLocalidad: nombreLocalidad ?? this.nombreLocalidad,
      codProvinciaId: codProvinciaId ?? this.codProvinciaId,
      nombreCapital: nombreCapital ?? this.nombreCapital,
    );
  }
}