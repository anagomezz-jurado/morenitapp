class Evento {
  final int id;
  final String codEvento;
  final String nombre;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? lugar;
  final int? anio;
  final int? organizadorId;
  final int? tipoEventoId;

  Evento({
    required this.id,
    required this.codEvento,
    required this.nombre,
    this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    this.lugar,
    this.anio,
    this.organizadorId,
    this.tipoEventoId,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] ?? 0,
      codEvento: json['cod_evento'] ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'],
      // DateTime.tryParse evita que la app truene si la fecha viene mal
      fechaInicio: DateTime.tryParse(json['fecha_inicio'] ?? '') ?? DateTime.now(),
      fechaFin: DateTime.tryParse(json['fecha_fin'] ?? '') ?? DateTime.now(),
      lugar: json['lugar'],
      anio: json['anio'] is int ? json['anio'] : int.tryParse(json['anio'].toString()) ?? 0,
      // Odoo envía Many2one como [id, "nombre"], aquí extraemos solo el ID
      organizadorId: (json['organizador_id'] is List) ? json['organizador_id'][0] : null,
      tipoEventoId: (json['tipoevento_id'] is List) ? json['tipoevento_id'][0] : null,
    );
  }
}