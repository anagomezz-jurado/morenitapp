import 'dart:ui';

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
  final String? organizadorNombre; 
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

  Color get colorVisual {
    String hex = color.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] ?? 0,
      codEvento: json['cod_evento'] ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'],
      fechaInicio: DateTime.parse(json['fecha_inicio'].replaceFirst(' ', 'T')),
      fechaFin: DateTime.parse(json['fecha_fin'].replaceFirst(' ', 'T')),
      lugar: json['lugar'],
      anio: json['anio'] is int
          ? json['anio']
          : int.tryParse(json['anio'].toString()) ?? 0,
      color: json['color'] ?? "#3498db",
      tipoNombre: json['tipo_nombre'] ?? "General",
      organizadorId:
          (json['organizador_id'] is List) ? json['organizador_id'][0] : null,
      organizadorNombre: (json['organizador_id'] is List)
          ? json['organizador_id'][1]
          : 'Propio',
      tipoEventoId:
          (json['tipoevento_id'] is List) ? json['tipoevento_id'][0] : null,
    );
  }
}
