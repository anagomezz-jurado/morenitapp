class Provincia {
  final int id;
  final String codProvincia;
  final String nombreProvincia;

  Provincia({
    required this.id,
    required this.codProvincia,
    required this.nombreProvincia,
  });

  factory Provincia.fromJson(Map<String, dynamic> json) {
    return Provincia(
      id: json['id'] ?? 0,
      codProvincia: json['codProvincia'] ?? '',
      nombreProvincia: json['nombreProvincia'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, // Es buena práctica incluir el ID en el JSON si existe
    'codProvincia': codProvincia,
    'nombreProvincia': nombreProvincia,
  };

  // Implementación correcta de copyWith
  Provincia copyWith({
    int? id,
    String? codProvincia,
    String? nombreProvincia,
  }) {
    return Provincia(
      id: id ?? this.id,
      codProvincia: codProvincia ?? this.codProvincia,
      nombreProvincia: nombreProvincia ?? this.nombreProvincia,
    );
  }
}