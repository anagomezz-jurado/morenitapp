class Autoridad {
  final String id;
  final String codAutoridad;
  final String nombreAutoridad;
  final String nombreSaluda;
  final String cargo;
  final String telefono;
  final String email;
  final String observaciones;

  final int? tipoautoridadId;
  final String tipoautoridadName;

  final int? calleId;
  final String calleNombre;
  final String numero;
  final String piso;
  final String puerta;
  final String bloque;
  final String escalera;
  final String portal;

  Autoridad({
    required this.id,
    required this.codAutoridad,
    required this.nombreAutoridad,
    required this.nombreSaluda,
    required this.cargo,
    required this.telefono,
    required this.email,
    required this.observaciones,
    required this.tipoautoridadId,
    required this.tipoautoridadName,
    required this.calleId,
    required this.calleNombre,
    required this.numero,
    required this.piso,
    required this.puerta,
    required this.bloque,
    required this.escalera,
    required this.portal,
  });

  static String clean(dynamic v) {
    if (v == null || v == "" || v == false) return "";
    return v.toString();
  }

  factory Autoridad.fromJson(Map<String, dynamic> json) {
    final dir = json["direccion"] ?? {};

    return Autoridad(
      id: clean(json["id"]),
      codAutoridad: clean(json["codAutoridad"]),
      nombreAutoridad: clean(json["nombreAutoridad"]),
      nombreSaluda: clean(json["nombreSaluda"]),
      cargo: clean(json["cargo"]),
      telefono: clean(json["telefono"]),
      email: clean(json["correoElectronico"]),

      observaciones: clean(json["observaciones"]),

      tipoautoridadId: json["tipoautoridad_id"],
      tipoautoridadName: clean(json["tipoautoridad_name"]),

      calleId: dir["calle_id"],
      calleNombre: clean(dir["calle_name"]),
      numero: clean(dir["numero"]),
      piso: clean(dir["piso"]),
      puerta: clean(dir["puerta"]),
      bloque: clean(dir["bloque"]),
      escalera: clean(dir["escalera"]),
      portal: clean(dir["portal"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "codAutoridad": codAutoridad,
      "nombreAutoridad": nombreAutoridad,
      "nombreSaluda": nombreSaluda,
      "cargo": cargo,
      "telefono": telefono,
      "correoElectronico": email,

      "observaciones": observaciones.isEmpty ? false : observaciones,

      "tipoautoridad_id": tipoautoridadId,
      "calle_id": calleId,
      "numero": numero,
      "piso": piso,
      "puerta": puerta,
      "bloque": bloque,
      "escalera": escalera,
      "portal": portal,
    };
  }
}
