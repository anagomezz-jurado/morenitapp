class Proveedor {
  final String id;
  final String codProveedor;
  final String nombre;
  final String? contacto;
  final String? telefono;
  final String? email;
  final int? grupoId;
  final String? grupoNombre;
  final String? observaciones;
  final bool anunciante;
  final int? calleId;
  final String? calleNombre; 
  final String? numero;
  final String? escalera;
  final String? bloque;
  final String? portal;
  final String? piso;
  final String? puerta;

  Proveedor({
    required this.id,
    required this.codProveedor,
    required this.nombre,
    this.contacto,
    this.telefono,
    this.email,
    this.grupoId,
    this.grupoNombre,
    this.observaciones,
    this.anunciante = false,
    this.calleId,
    this.calleNombre,
    this.numero,
    this.escalera,
    this.bloque,
    this.portal,
    this.piso,
    this.puerta,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'].toString(),
      codProveedor: json['cod_proveedor'] ?? '',
      nombre: json['nombre'] ?? '',
      contacto: (json['contacto'] is bool) ? null : json['contacto'],
      telefono: (json['telefono'] is bool) ? null : json['telefono'],
      email: (json['email'] is bool) ? null : json['email'],
      grupoId: json['grupo_id'],
      grupoNombre: json['grupo_nombre'],
      observaciones:
          (json['observaciones'] is bool) ? null : json['observaciones'],
      anunciante: json['anunciante'] ?? false,
      calleId: json['calle_id'],
      calleNombre: json['calle_nombre'],
      numero: (json['numero'] is bool) ? null : json['numero'],
      escalera: (json['escalera'] is bool) ? null : json['escalera'],
      bloque: (json['bloque'] is bool) ? null : json['bloque'],
      portal: (json['portal'] is bool) ? null : json['portal'],
      piso: (json['piso'] is bool) ? null : json['piso'],
      puerta: (json['puerta'] is bool) ? null : json['puerta'],
    );
  }
}
