class Cargo {
  final String id;
  final String codCargo;
  final String nombreCargo;

  final int? tipoCargoId;
  final String tipoCargoName;

  final DateTime fechaInicio;
  final DateTime? fechaFin;

  final int? calleId;
  final String calleNombre;

  final String numero;
  final String piso;
  final String puerta;
  final String bloque;
  final String escalera;
  final String portal;

  final String telefono;
  final String observaciones;
  final String motivo;
  final String textoSaludo;

  Cargo({
    required this.id,
    required this.codCargo,
    required this.nombreCargo,
    required this.tipoCargoId,
    required this.tipoCargoName,
    required this.fechaInicio,
    required this.fechaFin,
    required this.calleId,
    required this.calleNombre,
    required this.numero,
    required this.piso,
    required this.puerta,
    required this.bloque,
    required this.escalera,
    required this.portal,
    required this.telefono,
    required this.observaciones,
    required this.motivo,
    required this.textoSaludo,
  });

  static String clean(v) =>
      (v == null || v == "" || v == false) ? "" : v.toString();


  String get fechaInicioStr => fechaInicio.toString().split(" ")[0];

  String get fechaFinStr => fechaFin?.toString().split(" ")[0] ?? "";

  String get direccionCompleta {
    final base = "$calleNombre $numero";
    final extras = [
      if (piso.isNotEmpty) "Piso $piso",
      if (puerta.isNotEmpty) "Puerta $puerta",
      if (bloque.isNotEmpty) "Bloque $bloque",
      if (escalera.isNotEmpty) "Esc. $escalera",
      if (portal.isNotEmpty) "Portal $portal",
    ];
    final extrasStr = extras.isEmpty ? "" : " (${extras.join(", ")})";
    return base + extrasStr;
  }

  factory Cargo.fromJson(Map<String, dynamic> json) {
    final dir = json["direccion"] ?? {};

    return Cargo(
      id: clean(json["id"]),
      codCargo: clean(json["codCargo"]),
      nombreCargo: clean(json["nombreCargo"]),
      tipoCargoId: json["tipocargo_id"],
      tipoCargoName: clean(json["tipocargo_name"]),
      fechaInicio:
          DateTime.tryParse(clean(json["fechaInicioCargo"])) ?? DateTime.now(),
      fechaFin: json["fechaFinCargo"] != null
          ? DateTime.tryParse(json["fechaFinCargo"])
          : null,
      calleId: dir["calle_id"],
      calleNombre: clean(dir["calle_name"]),
      numero: clean(dir["numero"]),
      piso: clean(dir["piso"]),
      puerta: clean(dir["puerta"]),
      bloque: clean(dir["bloque"]),
      escalera: clean(dir["escalera"]),
      portal: clean(dir["portal"]),
      telefono: clean(json["telefono"]),
      observaciones: clean(json["observaciones"]),
      motivo: clean(json["motivo"]),
      textoSaludo: clean(json["textoSaludo"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "codCargo": codCargo,
      "nombreCargo": nombreCargo,
      "tipocargo_id": tipoCargoId,
      "fechaInicioCargo": fechaInicioStr,
      "fechaFinCargo": fechaFinStr.isEmpty ? null : fechaFinStr,
      "calle_id": calleId,
      "numero": numero,
      "piso": piso,
      "puerta": puerta,
      "bloque": bloque,
      "escalera": escalera,
      "portal": portal,
      "telefono": telefono,
      "observaciones": observaciones,
      "motivo": motivo,
      "textoSaludo": textoSaludo,
    };
  }

  Cargo copyWith({
    String? id,
    String? codCargo,
    String? nombreCargo,
    int? tipoCargoId,
    String? tipoCargoName,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? calleId,
    String? calleNombre,
    String? numero,
    String? piso,
    String? puerta,
    String? bloque,
    String? escalera,
    String? portal,
    String? telefono,
    String? observaciones,
    String? motivo,
    String? textoSaludo,
  }) {
    return Cargo(
      id: id ?? this.id,
      codCargo: codCargo ?? this.codCargo,
      nombreCargo: nombreCargo ?? this.nombreCargo,
      tipoCargoId: tipoCargoId ?? this.tipoCargoId,
      tipoCargoName: tipoCargoName ?? this.tipoCargoName,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      calleId: calleId ?? this.calleId,
      calleNombre: calleNombre ?? this.calleNombre,
      numero: numero ?? this.numero,
      piso: piso ?? this.piso,
      puerta: puerta ?? this.puerta,
      bloque: bloque ?? this.bloque,
      escalera: escalera ?? this.escalera,
      portal: portal ?? this.portal,
      telefono: telefono ?? this.telefono,
      observaciones: observaciones ?? this.observaciones,
      motivo: motivo ?? this.motivo,
      textoSaludo: textoSaludo ?? this.textoSaludo,
    );
  }

  @override
  String toString() {
    return "Cargo($codCargo - $nombreCargo, tipo=$tipoCargoName, fechaInicio=$fechaInicioStr)";
  }
}
