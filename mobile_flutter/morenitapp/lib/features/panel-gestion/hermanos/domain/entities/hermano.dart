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
  final bool responsable;
  final List<Map<String, dynamic>> callesAsignadas; // Lista de {id, nombre}
  final int? calleId;
  final String calleNombre;
  final String? piso;
  final String? puerta;
  final String iban;
  final String estado;
  final String? fechaBaja;
  final String? motivoBaja;

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
    this.responsable = false,
    this.callesAsignadas = const [],
    this.calleId,
    this.calleNombre = '',
    this.piso,
    this.puerta,
    this.iban = '',
    this.estado = 'activo',
    this.fechaBaja,
    this.motivoBaja,
  });

  factory Hermano.fromJson(Map<String, dynamic> json) {
    String clean(dynamic val) {
      if (val == null || val == false || val == "false" || val == "null") return '';
      return val.toString();
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
      fechaBaja: clean(json['fecha_baja']).isEmpty ? null : clean(json['fecha_baja']),
      motivoBaja: clean(json['motivo_baja']),
      calleId: json['calle_id'] is int ? json['calle_id'] : null,
      calleNombre: clean(json['calle_nombre']),
      piso: clean(json['piso']),
      puerta: clean(json['puerta']),
      metodoPago: clean(json['metodo_pago']),
      iban: clean(json['iban']),
      responsable: json['responsable'] == true,
      callesAsignadas: List<Map<String, dynamic>>.from(json['calles_asignadas'] ?? []),
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
        "fecha_nacimiento": fechaNacimiento.isEmpty ? false : fechaNacimiento,
        "calle_id": calleId,
        "metodo_pago": (metodoPago == 'Domiciliado' || metodoPago == 'banco') ? 'banco' : 'metalico',
        "responsable": responsable,
        "piso": piso,
        "puerta": puerta,
        "iban": iban,
        "estado": estado,
        "fecha_baja": (fechaBaja == null || fechaBaja!.isEmpty) ? false : fechaBaja,
        "motivo_baja": motivoBaja,
      };

  Hermano copyWith({
    int? id,
    String? estado,
    String? fechaBaja,
    String? motivoBaja,
    bool? responsable,
    List<Map<String, dynamic>>? callesAsignadas,
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
      metodoPago: metodoPago,
      responsable: responsable ?? this.responsable,
      callesAsignadas: callesAsignadas ?? this.callesAsignadas,
      calleId: calleId,
      calleNombre: calleNombre,
      piso: piso,
      puerta: puerta,
      iban: iban,
      estado: estado ?? this.estado,
      fechaBaja: fechaBaja ?? this.fechaBaja,
      motivoBaja: motivoBaja ?? this.motivoBaja,
    );
  }
}