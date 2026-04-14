class Cofradia {
  final String id;
  final String cif;
  final String nombre;
  final int fundacion;
  final String email;
  final String telefono;
  final String web;
  final String observaciones;
  final int? direccionId;
  final String? direccionName;
  final String puerta;
  final String piso;
  final int? localidadId;

  Cofradia({
    required this.id,
    required this.cif,
    required this.nombre,
    required this.fundacion,
    required this.email,
    required this.telefono,
    required this.web,
    required this.observaciones,
    this.direccionId,
    this.direccionName,
    required this.puerta,
    required this.piso,
    this.localidadId,
  });

  factory Cofradia.fromJson(Map<String, dynamic> json) {
    return Cofradia(
      id: json['id']?.toString() ?? '',
      cif: json['cifCofradia']?.toString() ?? '',
      nombre: json['nombreCofradia']?.toString() ?? '',
      fundacion: json['antiguedadCofradia'] is int ? json['antiguedadCofradia'] : 0,
      email: json['emailCofradia']?.toString() ?? '',
      telefono: json['telefonoCofradia']?.toString() ?? '',
      web: json['paginaWeb']?.toString() ?? '',
      observaciones: json['observaciones']?.toString() ?? '',
      direccionId: json['direccion_id'] is int ? json['direccion_id'] : null,
      direccionName: json['direccion_name']?.toString() ?? '',
      puerta: json['puerta']?.toString() ?? '',
      piso: json['piso']?.toString() ?? '',
      localidadId: json['localidad_id'] is int ? json['localidad_id'] : null,
    );
  }
}