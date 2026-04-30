class Rol {
  final int? id;
  final int codigo; 
  final String nombre;

  Rol({this.id, required this.codigo, required this.nombre});

  factory Rol.fromJson(Map<String, dynamic> json) => Rol(
        id: json['id'],
        codigo: json['codigo'] ?? 0,
        nombre: json['nombre'] ?? '',
      );
}
