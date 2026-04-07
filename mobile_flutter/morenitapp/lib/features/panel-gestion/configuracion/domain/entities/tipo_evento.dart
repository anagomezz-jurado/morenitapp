class TipoEvento {
  final int? id;
  final String codigo;
  final String nombre;

  TipoEvento({this.id, required this.codigo, required this.nombre});

  factory TipoEvento.fromJson(Map<String, dynamic> json) => TipoEvento(
    id: json['id'],
    codigo: json['codigo'] ?? '',
    nombre: json['nombre'] ?? '',
  );
}