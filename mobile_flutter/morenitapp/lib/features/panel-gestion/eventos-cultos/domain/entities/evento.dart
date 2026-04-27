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
  final String? organizadorNombre; // Añadido para la UI
  final int? tipoEventoId;
  final String color;
  final String tipoNombre;

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
    this.organizadorNombre,
    required this.color,
    required this.tipoNombre,
    this.tipoEventoId,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] ?? 0,
      codEvento: json['cod_evento'] ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'],
      fechaInicio: DateTime.parse(json['fecha_inicio'].replaceFirst(' ', 'T')),
fechaFin: DateTime.parse(json['fecha_fin'].replaceFirst(' ', 'T')),
      lugar: json['lugar'],
      anio: json['anio'] is int ? json['anio'] : int.tryParse(json['anio'].toString()) ?? 0,
      color: json['color'] ?? "#3498db",
      tipoNombre: json['tipo_nombre'] ?? "General",
      // Manejo de Many2one de Odoo [id, "nombre"]
      organizadorId: (json['organizador_id'] is List) ? json['organizador_id'][0] : null,
      organizadorNombre: (json['organizador_id'] is List) ? json['organizador_id'][1] : 'Propio',
      tipoEventoId: (json['tipoevento_id'] is List) ? json['tipoevento_id'][0] : null,
    );
  }
}