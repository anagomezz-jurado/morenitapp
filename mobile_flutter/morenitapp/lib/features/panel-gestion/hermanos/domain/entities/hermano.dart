class Hermano {
  final int? id;
  final int numeroHermano;
  final String? codigoHermano;
  final String nombre;
  final String apellido1;
  final String apellido2;
  final String dni;
  final String email;
  final String telefono;
  final String sexo;
  final String fechaAlta;
  final String fechaNacimiento;
  final String metodoPago;
  final bool bautizado;
  final String calleNombre;
  final int? calleId;
  final String? numero;
  final String? piso;
  final String? bloque;
  final String? escalera;
  final String? portal;
  final String? puerta;
  final String? observaciones;

  final String iban;
  final String banco;
  final String sucursal;
  final String numeroCuenta;
  final String estado;
  final String? fechaBaja;
  final String? motivoBaja;
  final String? fechaReactivacion;

  Hermano({
    this.id,
    required this.numeroHermano,
    this.codigoHermano,
    required this.nombre,
    required this.apellido1,
    this.apellido2 = '',
    required this.dni,
    this.email = '',
    this.telefono = '',
    required this.sexo,
    required this.fechaAlta,
    this.fechaNacimiento = '',
    required this.metodoPago,
    this.bautizado = false,
    this.calleId,
    this.calleNombre = '',
    this.numero,
    this.puerta,
    this.bloque,
    this.escalera,
    this.portal,
    this.observaciones = '',
    this.piso,
    this.iban = '',
    this.banco = '',
    this.sucursal = '',
    this.numeroCuenta = '',
    this.estado = 'activo',
    this.fechaBaja,
    this.motivoBaja,
    this.fechaReactivacion,
  });

  factory Hermano.fromJson(Map<String, dynamic> json) {
    String clean(dynamic val) {
      if (val == null ||
          val == false ||
          val == "false" ||
          val == "null" ||
          val == 0) return '';
      return val.toString();
    }

    Map<String, dynamic> bancoData = {};
    if (json['datos_banco'] != null &&
        (json['datos_banco'] as List).isNotEmpty) {
      bancoData = json['datos_banco'][0]; 
    }

    return Hermano(
      id: json['id'],
      numeroHermano: json['numero_hermano'] ?? 0,
      codigoHermano: clean(json['codigo_hermano']),
      nombre: clean(json['nombre']),
      apellido1: clean(json['apellido1']),
      apellido2: clean(json['apellido2']),
      dni: clean(json['dni']),
      email: clean(json['email']),
      telefono: clean(json['telefono']),
      sexo: clean(json['sexo']).isEmpty ? 'Hombre' : clean(json['sexo']),
      fechaAlta: clean(json['fecha_alta']),
      fechaNacimiento: clean(json['fecha_nacimiento']),
      estado: clean(json['estado']).isEmpty ? 'activo' : clean(json['estado']),
      fechaBaja: (json['fecha_baja'] == null || json['fecha_baja'] == false)
          ? null
          : json['fecha_baja'].toString(),
      motivoBaja: clean(json['motivo_baja']),
      calleId: json['calle_id'] is int ? json['calle_id'] : null,
      calleNombre: clean(json['calle_nombre']),
      numero: clean(json['numero']),
      piso: clean(json['piso']),
      puerta: clean(json['puerta']),
      bloque: clean(json['bloque']),
      escalera: clean(json['escalera']),
      portal: clean(json['portal']),
      observaciones: clean(json['observaciones']),
      metodoPago: clean(json['metodo_pago']),
      iban: clean(bancoData['iban'] ?? json['iban']),
      banco: clean(bancoData['banco'] ?? json['banco']),
      sucursal: clean(bancoData['sucursal'] ?? json['sucursal']),
      numeroCuenta: clean(bancoData['cuenta'] ?? json['numero_cuenta']),

      bautizado: json['bautizado'] == true,
      fechaReactivacion: (json['fecha_reactivacion'] == null ||
              json['fecha_reactivacion'] == false)
          ? null
          : json['fecha_reactivacion'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "numero_hermano": numeroHermano,
        "nombre": nombre,
        "apellido1": apellido1,
        "apellido2": apellido2,
        "dni": dni,
        "email": email,
        "telefono": telefono,
        "sexo": sexo,
        "fecha_alta": fechaAlta,
        "fecha_nacimiento": fechaNacimiento == null || fechaNacimiento!.isEmpty
            ? false
            : fechaNacimiento,
        "calle_id": calleId,
        "numero": numero,
        "piso": piso,
        "puerta": puerta,
        "bloque": bloque,
        "escalera": escalera,
        "portal": portal,
        "observaciones": observaciones == null || observaciones!.isEmpty
            ? false
            : observaciones,
        "metodo_pago": (metodoPago == 'Domiciliado' || metodoPago == 'banco')
            ? 'banco'
            : 'metalico',
        "bautizado": bautizado,
        "iban": iban,
        "banco": banco,
        "sucursal": sucursal,
        "numero_cuenta": numeroCuenta,
        "estado": estado,
        "fecha_baja":
            (fechaBaja == null || fechaBaja!.isEmpty) ? false : fechaBaja,
        "motivo_baja":
            (motivoBaja == null || motivoBaja!.isEmpty) ? false : motivoBaja,
        "fecha_reactivacion":
            (fechaReactivacion == null || fechaReactivacion!.isEmpty)
                ? false
                : fechaReactivacion,
      };

  Hermano copyWith({
    int? id,
    String? estado,
    String? fechaBaja,
    String? motivoBaja,
    bool? bautizado,
    String? numero,
    String? piso,
    String? puerta,
    String? bloque,
    String? escalera,
    String? portal,
    String? observaciones,
    String? fechaReactivacion,
    String? metodoPago,
    String? iban,
    String? banco,
    String? sucursal,
    String? numeroCuenta,
  }) {
    return Hermano(
      id: id ?? this.id,
      numeroHermano: numeroHermano,
      codigoHermano: codigoHermano,
      nombre: nombre,
      apellido1: apellido1,
      apellido2: apellido2,
      dni: dni,
      email: email,
      telefono: telefono,
      sexo: sexo,
      fechaAlta: fechaAlta,
      fechaNacimiento: fechaNacimiento,
      metodoPago: metodoPago ?? this.metodoPago,
      iban: iban ?? this.iban,
      calleId: calleId,
      calleNombre: calleNombre,
      bautizado: bautizado ?? this.bautizado,
      numero: numero ?? this.numero,
      piso: piso ?? this.piso,
      puerta: puerta ?? this.puerta,
      bloque: bloque ?? this.bloque,
      escalera: escalera ?? this.escalera,
      portal: portal ?? this.portal,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
      fechaBaja: fechaBaja ?? this.fechaBaja,
      motivoBaja: motivoBaja ?? this.motivoBaja,
      fechaReactivacion: fechaReactivacion ?? this.fechaReactivacion,
      banco: banco ?? this.banco,
      sucursal: sucursal ?? this.sucursal,
      numeroCuenta: numeroCuenta ?? this.numeroCuenta,
    );
  }
}
