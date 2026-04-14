class Cargo {
  final String id;
  final String codCargo;
  final String nombreCargo;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int? tipoCargoId;
  final String? tipoCargoName;
  final int? direccionId;
  final String? direccionName;
  final String? puerta;
  final String? piso;
  final String? telefono;
  final String? observaciones;
  final String? motivo;
  final String? textoSaludo;
  final int? localidadId;

  Cargo({
    required this.id,
    required this.codCargo,
    required this.nombreCargo,
    required this.fechaInicio,
    this.fechaFin,
    this.tipoCargoId,
    this.tipoCargoName,
    this.direccionId,
    this.direccionName,
    this.puerta,
    this.piso,
    this.telefono,
    this.observaciones,
    this.motivo,
    this.textoSaludo,
    this.localidadId,
  });

  factory Cargo.fromJson(Map<String, dynamic> json) {
    return Cargo(
      id: json['id']?.toString() ?? '',
      codCargo: json['codCargo']?.toString() ?? '',
      nombreCargo: json['nombreCargo']?.toString() ?? '',
      fechaInicio: (json['fechaInicioCargo'] != null && json['fechaInicioCargo'] != "")
          ? DateTime.parse(json['fechaInicioCargo'])
          : DateTime.now(),
      fechaFin: (json['fechaFinCargo'] != null && json['fechaFinCargo'] != "")
          ? DateTime.parse(json['fechaFinCargo'])
          : null,
      tipoCargoId: json['tipocargo_id'] is List ? json['tipocargo_id'][0] : (json['tipocargo_id'] is int ? json['tipocargo_id'] : null),
      tipoCargoName: json['tipocargo_name']?.toString() ?? (json['tipocargo_id'] is List ? json['tipocargo_id'][1] : null),
      direccionId: json['direccion'] is List ? json['direccion'][0] : (json['direccion'] is int ? json['direccion'] : null),
      direccionName: json['direccion_name']?.toString() ?? (json['direccion'] is List ? json['direccion'][1] : null),
      puerta: json['puerta']?.toString() ?? '',
      piso: json['piso']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      observaciones: json['observaciones']?.toString() ?? '',
      motivo: json['motivo']?.toString() ?? '',
      textoSaludo: json['textoSaludo']?.toString() ?? '',
      localidadId: json['localidad_id'] is List ? json['localidad_id'][0] : (json['localidad_id'] is int ? json['localidad_id'] : null),
    );
  }
}