class LibroAnunciante {
  final int? id;
  final int proveedorId;
  final String proveedorNombre;
  final double importe;
  final bool cobrado;
  final String? fechaCobro; // Usamos String para simplificar el transporte con Odoo

  LibroAnunciante({
    this.id,
    required this.proveedorId,
    required this.proveedorNombre,
    required this.importe,
    this.cobrado = false,
    this.fechaCobro,
  });

  factory LibroAnunciante.fromJson(Map<String, dynamic> json) {
    return LibroAnunciante(
      id: json['id'],
      proveedorId: json['proveedor_id'] ?? 0,
      proveedorNombre: json['proveedor_nombre'] ?? '',
      importe: (json['importe'] ?? 0.0).toDouble(),
      cobrado: json['cobrado'] ?? false,
      fechaCobro: json['fecha_cobro'],
    );
  }
}