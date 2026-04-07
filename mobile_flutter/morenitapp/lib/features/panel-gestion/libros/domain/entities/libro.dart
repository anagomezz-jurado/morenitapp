import 'libro_anunciante.dart';

class Libro {
  final int id;
  final String codLibro;
  final String nombre;
  final int anio;
  final String descripcion;
  final double importe;
  final DateTime? fechaRecibo;
  final String textoReciboEvento;
  final String textoAnunciante;
  final double totalAnunciantes;
  final List<dynamic>? tipoEvento; // [id, nombre]
  final String? archivoLibro; // Base64
  final List<LibroAnunciante> anunciantes;

  Libro({
    required this.id,
    required this.codLibro,
    required this.nombre,
    required this.anio,
    this.descripcion = '',
    this.importe = 0.0,
    this.fechaRecibo,
    this.textoReciboEvento = '',
    this.textoAnunciante = '',
    this.totalAnunciantes = 0.0,
    this.tipoEvento,
    this.archivoLibro,
    this.anunciantes = const [],
  });

  factory Libro.fromJson(Map<String, dynamic> json) => Libro(
    id: json["id"],
    codLibro: json["cod_libro"] ?? '',
    nombre: json["nombre"] ?? '',
    anio: json["anio"] ?? 0,
    descripcion: json["descripcion"] ?? '',
    importe: (json["importe"] as num).toDouble(),
    fechaRecibo: json["fechaRecibo"] != null ? DateTime.parse(json["fechaRecibo"]) : null,
    textoReciboEvento: json["textoReciboEvento"] ?? '',
    textoAnunciante: json["textoAnunciante"] ?? '',
    totalAnunciantes: (json["total_anunciantes"] as num).toDouble(),
    tipoEvento: json["tipoevento_id"],
    archivoLibro: json["archivoLibro"],
    anunciantes: json["anunciantes"] != null 
      ? List<LibroAnunciante>.from(json["anunciantes"].map((x) => LibroAnunciante.fromJson(x)))
      : [],
  );
}