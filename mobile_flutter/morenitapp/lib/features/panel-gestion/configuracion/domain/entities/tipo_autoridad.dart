class TipoAutoridad {
  final int? id;
  final String codigo;
  final String nombre;

  TipoAutoridad({this.id, required this.codigo, required this.nombre});

  factory TipoAutoridad.fromJson(Map<String, dynamic> json) => TipoAutoridad(
    id: json['id'],
    codigo: json['codigo'] ?? '',
    nombre: json['nombre'] ?? '',
  );
}