import 'libro_anunciante.dart';
import 'libro_adjunto.dart';


class Libro {
  final int id;
  final String codLibro;
  final String nombre;
  final int anio;
  final String descripcion;
  final double importe;
  final String? fechaRecibo;
  final int? tipoeventoId;
  final double totalAnunciantes;
  final List<LibroAnunciante> anunciantes;
  final List<LibroAdjunto> archivos;
  final String? textoReciboEvento;
  final String? textoAnunciante;

  Libro({
    required this.id,
    required this.codLibro,
    required this.nombre,
    required this.anio,
    required this.descripcion,
    required this.importe,
    this.fechaRecibo,
    this.tipoeventoId,
    this.totalAnunciantes = 0.0,
    this.anunciantes = const [],
    this.archivos = const [],
    this.textoAnunciante,
    this.textoReciboEvento,
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      codLibro: json['cod_libro'] ?? '',
      nombre: json['nombre'] ?? '',
      anio: json['anio'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      importe: (json['importe'] ?? 0.0).toDouble(),
      fechaRecibo: json['fecha_recibo'],
      textoReciboEvento: json['texto_recibo_evento'],
      textoAnunciante: json['texto_anunciante'],
      tipoeventoId: json['tipoevento_id'],
      totalAnunciantes: (json['total_anunciantes'] ?? 0.0).toDouble(),
      anunciantes: (json['anunciantes'] as List? ?? [])
          .map((a) => LibroAnunciante.fromJson(a))
          .toList(),
      archivos: (json['archivos'] as List? ?? [])
          .map((f) => LibroAdjunto.fromJson(f))
          .toList(),
    );
  }
}
