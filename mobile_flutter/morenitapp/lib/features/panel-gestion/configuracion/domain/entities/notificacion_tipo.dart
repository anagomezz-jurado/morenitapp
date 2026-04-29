class NotificacionTipo {
  final int id;
  final String name;

  NotificacionTipo({required this.id, required this.name});

  factory NotificacionTipo.fromJson(Map<String, dynamic> json) {
    return NotificacionTipo(
      id: json['id'] ?? 0,
      // Intentamos leer 'name', si no existe probamos con 'display_name', 
      // y si no, con 'nombre'. Si todo falla, ponemos 'Sin nombre'.
      name: json['name'] ?? json['display_name'] ?? json['nombre'] ?? 'Sin nombre',
    );
  }

  Map<String, dynamic> toJson() => {'name': name};
}