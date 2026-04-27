class Grupo {
  final int id;
  final String nombre;

  Grupo({required this.id, required this.nombre});

  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
}