import 'package:morenitapp/features/panel-gestion/libros/domain/entities/libro_anunciante.dart';

class Libro {
  final int id;
  final String codLibro;
  final String nombre;
  final int anio;
  final String descripcion;
  final double importe;
  final String? fechaRecibo; // Cambiado para coincidir con el JSON de Odoo
  final String? textoReciboEvento;
  final String? textoAnunciante;
  final int? tipoeventoId;
  final String? tipoeventoName;
  final String? archivoLibro; 
  final List<LibroAnunciante> anunciantes;

  Libro({
    required this.id,
    required this.codLibro,
    required this.nombre,
    required this.anio,
    required this.descripcion,
    required this.importe,
    this.fechaRecibo,
    this.textoReciboEvento,
    this.textoAnunciante,
    this.tipoeventoId,
    this.tipoeventoName,
    this.archivoLibro,
    this.anunciantes = const [],
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      codLibro: json['cod_libro'] ?? '',
      nombre: json['nombre'] ?? '',
      anio: json['anio'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      importe: (json['importe'] ?? 0.0).toDouble(),
      fechaRecibo: json['fechaRecibo'],
      textoReciboEvento: json['textoReciboEvento'],
      textoAnunciante: json['textoAnunciante'],
      tipoeventoId: json['tipoevento_id'],
      tipoeventoName: json['tipoevento_name'],
      archivoLibro: json['archivoLibro'],
      anunciantes: (json['anunciantes'] as List? ?? [])
          .map((a) => LibroAnunciante.fromJson(a))
          .toList(),
    );
  }
}