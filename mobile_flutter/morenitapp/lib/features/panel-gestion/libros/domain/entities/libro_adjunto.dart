class LibroAdjunto {
  final int id;
  final String nombre;
  final String? base64;

  LibroAdjunto({required this.id, required this.nombre, this.base64});

  factory LibroAdjunto.fromJson(Map<String, dynamic> json) {
    return LibroAdjunto(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nombre: json['nombre'] ?? json['name'] ?? 'Archivo sin nombre',
      base64: json['base64'] ?? json['datas'],
    );
  }
}
