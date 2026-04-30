class Organizador {
  final int id;
  final String cif;
  final String nombre;
  final String? telefono;
  final String? email;

  final int? calleId;
  final String calleName;
  final String numero;
  final String piso;
  final String puerta;
  final String escalera;
  final String bloque;
  final String portal;

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
    this.calleId,
    required this.calleName,
    required this.numero,
    required this.piso,
    required this.puerta,
    required this.escalera,
    required this.bloque,
    required this.portal,
    this.logo,
    this.firmaPresidente,
    this.firmaSecretario,
    this.firmaTesorero,
  });

  factory Organizador.fromJson(Map<String, dynamic> json) {
    return Organizador(
      id: json["id"],
      cif: json["cif"] ?? "",
      nombre: json["nombre"] ?? "",
      telefono: json["telefono"],
      email: json["email"],
      calleId: json["calle_id"],
      calleName: json["calle_name"] ?? "",
      numero: json["numero"] ?? "",
      piso: json["piso"] ?? "",
      puerta: json["puerta"] ?? "",
      escalera: json["escalera"] ?? "",
      bloque: json["bloque"] ?? "",
      portal: json["portal"] ?? "",
      logo: json["logo"],
      firmaPresidente: json["firma_presidente"],
      firmaSecretario: json["firma_secretario"],
      firmaTesorero: json["firma_tesorero"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "cif": cif,
      "nombre": nombre,
      "telefono": telefono,
      "email": email,
      "calle_id": calleId,
      "numero": numero,
      "piso": piso,
      "puerta": puerta,
      "escalera": escalera,
      "bloque": bloque,
      "portal": portal,
      "logo": logo,
      "firma_presidente": firmaPresidente,
      "firma_secretario": firmaSecretario,
      "firma_tesorero": firmaTesorero,
    };
  }
}
