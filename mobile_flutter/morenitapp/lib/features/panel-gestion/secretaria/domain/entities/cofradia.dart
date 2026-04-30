class Cofradia {
  final String id;
  final String cif;
  final String nombre;
  final int fundacion;
  final String email;
  final String telefono;
  final String web;
  final String observaciones;

  final int? calleId;
  final String calleNombre;
  final String numero;
  final String piso;
  final String puerta;
  final String bloque;
  final String escalera;
  final String portal;

  Cofradia({
    required this.id,
    required this.cif,
    required this.nombre,
    required this.fundacion,
    required this.email,
    required this.telefono,
    required this.web,
    required this.observaciones,
    required this.calleId,
    required this.calleNombre,
    required this.numero,
    required this.piso,
    required this.puerta,
    required this.bloque,
    required this.escalera,
    required this.portal,
  });

  static String clean(v) => (v == null || v == "" || v == false) ? "" : v.toString();

  factory Cofradia.fromJson(Map<String, dynamic> json) {
    final dir = json["direccion"] ?? {};

    return Cofradia(
      id: clean(json["id"]),
      cif: clean(json["cifCofradia"]),
      nombre: clean(json["nombreCofradia"]),
      fundacion: json["antiguedadCofradia"] is int ? json["antiguedadCofradia"] : 0,
      email: clean(json["emailCofradia"]),
      telefono: clean(json["telefonoCofradia"]),
      web: clean(json["paginaWeb"]),
      observaciones: clean(json["observaciones"]),

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
      "cifCofradia": cif,
      "nombreCofradia": nombre,
      "antiguedadCofradia": fundacion,
      "emailCofradia": email,
      "telefonoCofradia": telefono,
      "paginaWeb": web,
      "observaciones": observaciones,

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
