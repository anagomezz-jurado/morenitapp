class LibroAnunciante {
  final int? id;
  final int proveedorId;
  final String proveedorNombre;
  final double importe;
  final bool cobrado;
  final String? fechaCobro; 

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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      proveedorId: json['proveedor_id'] ?? 0,
      proveedorNombre: json['proveedor_nombre'] ?? 'Sin nombre',
      importe: (json['importe'] ?? 0.0).toDouble(),
      cobrado: json['cobrado'] ?? false,
      fechaCobro: json['fecha_cobro'],
    );
  }
}