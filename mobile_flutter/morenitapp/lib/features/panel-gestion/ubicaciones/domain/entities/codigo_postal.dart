class CodigoPostal {
  final int id;
  final String name; 
  final int? localidadId;

  CodigoPostal({
    required this.id,
    required this.name,
    this.localidadId,
  });

  factory CodigoPostal.fromJson(Map<String, dynamic> json) {
    return CodigoPostal(
      id: json['id'] ?? 0,
      // Forzamos toString() para evitar el error de subtype 'bool' o 'int'
      name: json['name']?.toString() ?? '', 
      localidadId: (json['localidad_id'] is List && (json['localidad_id'] as List).isNotEmpty)
          ? json['localidad_id'][0] 
          : json['localidad_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'localidad_id': localidadId,
  };

 CodigoPostal copyWith({int? id, String? name, int? localidadId}) {
  return CodigoPostal(
    id: id ?? this.id,
    name: name ?? this.name,
    localidadId: localidadId ?? this.localidadId,
  );
}
}