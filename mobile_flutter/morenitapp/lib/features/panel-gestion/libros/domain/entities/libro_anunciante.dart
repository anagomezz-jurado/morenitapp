class LibroAnunciante {
  final int id;
  final String proveedorNombre;
  final double importe;
  final bool cobrado;
  final DateTime? fechaCobro;

  LibroAnunciante({
    required this.id,
    required this.proveedorNombre,
    required this.importe,
    required this.cobrado,
    this.fechaCobro,
  });

  factory LibroAnunciante.fromJson(Map<String, dynamic> json) => LibroAnunciante(
    id: json["id"],
    proveedorNombre: json["proveedor_nombre"] ?? '',
    importe: (json["importe"] as num).toDouble(),
    cobrado: json["cobrado"] ?? false,
    fechaCobro: json["fecha_cobro"] != null ? DateTime.parse(json["fecha_cobro"]) : null,
  );
}