class Organizador {
  final int id;
  final String cif;
  final String nombre;
  final String? telefono;
  final String? email;
  final int? direccionId;
  final String? direccionName; // Añadido para el autocompletado
  final String? piso;
  final String? puerta;
  final String? logo; 
  final String? firmaPresidente;
  final String? firmaSecretario;
  final String? firmaTesorero;

  Organizador({
    required this.id,
    required this.cif,
    required this.nombre,
    this.telefono,
    this.email,
    this.direccionId,
    this.direccionName,
    this.piso,
    this.puerta,
    this.logo,
    this.firmaPresidente,
    this.firmaSecretario,
    this.firmaTesorero,
  });

  factory Organizador.fromJson(Map<String, dynamic> json) => Organizador(
    id: json["id"],
    cif: json["cif"] ?? '',
    nombre: json["nombre"] ?? '',
    telefono: json["telefono"]?.toString(),
    email: json["email"]?.toString(),
    direccionId: json["direccion_id"] is List ? json["direccion_id"][0] : json["direccion_id"],
    direccionName: json["direccion_id"] is List ? json["direccion_id"][1] : null,
    piso: json["piso"]?.toString(),
    puerta: json["puerta"]?.toString(),
    logo: json["logo"] is String ? json["logo"] : null,
    firmaPresidente: json["firma_presidente"] is String ? json["firma_presidente"] : null,
    firmaSecretario: json["firma_secretario"] is String ? json["firma_secretario"] : null,
    firmaTesorero: json["firma_tesorero"] is String ? json["firma_tesorero"] : null,
  );
}