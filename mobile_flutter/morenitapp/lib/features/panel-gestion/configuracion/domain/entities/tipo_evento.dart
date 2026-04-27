class TipoEvento {
  final int? id;
  final String codigo;
  final String nombre;
  final String color; 

  TipoEvento({this.id, required this.codigo, required this.nombre, this.color = '#3498db'});

  factory TipoEvento.fromJson(Map<String, dynamic> json) => TipoEvento(
    id: json['id'],
    codigo: json['codigo'] ?? '',
    nombre: json['nombre'] ?? '',
    color: json['color'] ?? '#3498db', 
  );
}