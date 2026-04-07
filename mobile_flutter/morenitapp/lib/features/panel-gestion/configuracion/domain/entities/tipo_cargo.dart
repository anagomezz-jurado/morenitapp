class TipoCargo {
  final int? id;
  final String codigo;
  final String nombre;
  final String observaciones;

  TipoCargo({this.id, required this.codigo, required this.nombre, this.observaciones = ''});

  factory TipoCargo.fromJson(Map<String, dynamic> json) => TipoCargo(
    id: json['id'],
    codigo: json['codigo'] ?? '',
    nombre: json['nombre'] ?? '',
    observaciones: json['observaciones'] ?? '',
  );
}