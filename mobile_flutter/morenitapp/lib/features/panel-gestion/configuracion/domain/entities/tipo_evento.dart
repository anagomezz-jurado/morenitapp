import 'package:flutter/material.dart';

class TipoEvento {
  final int? id;
  final String codigo;
  final String nombre;
  final String color; 

  TipoEvento({
    this.id,
    required this.codigo,
    required this.nombre,
    this.color = '#FFFFFF',
  });

  Color get toColor {
    String hex = color.replaceAll('#', '');
    if (hex.isEmpty) return Colors.grey;
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  factory TipoEvento.fromJson(Map<String, dynamic> json) => TipoEvento(
        id: json['id'],
        codigo: json['codigo'] ?? json['cod_tipo_evento'] ?? '',
        nombre: json['nombre'] ?? json['nombre_tipo_evento'] ?? '',
        color: json['color'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cod_tipo_evento": codigo,
        "nombre_tipo_evento": nombre,
        "color": color,
      };
}
