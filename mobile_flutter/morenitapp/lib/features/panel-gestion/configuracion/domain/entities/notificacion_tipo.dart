class NotificacionTipo {
  final int id;
  final String name;

  NotificacionTipo({required this.id, required this.name});

  factory NotificacionTipo.fromJson(Map<String, dynamic> json) {
    return NotificacionTipo(
      id: json['id'] ?? 0,
      name: json['name'] ??
          json['display_name'] ??
          json['nombre'] ??
          'Sin nombre',
    );
  }

  Map<String, dynamic> toJson() => {'name': name};
}
