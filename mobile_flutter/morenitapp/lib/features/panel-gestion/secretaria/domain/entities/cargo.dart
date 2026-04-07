class Cargo {
  final String id;
  final String codCargo;
  final String nombreCargo;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int? tipoCargoId;

  Cargo({
    required this.id,
    required this.codCargo,
    required this.nombreCargo,
    required this.fechaInicio,
    this.fechaFin,
    this.tipoCargoId,
  });

  factory Cargo.fromJson(Map<String, dynamic> json) {
    return Cargo(
      id: json['id']?.toString() ?? '',
      codCargo: json['codCargo']?.toString() ?? '',
      nombreCargo: json['nombreCargo']?.toString() ?? '',
      // Validar que la fecha sea un String antes de parsear
      fechaInicio: (json['fechaInicio'] is String) 
          ? DateTime.parse(json['fechaInicio']) 
          : DateTime.now(),
      fechaFin: (json['fechaFin'] is String) 
          ? DateTime.parse(json['fechaFin']) 
          : null,
      tipoCargoId: (json['tipo_id'] is int) ? json['tipo_id'] : null,
    );
  }
}