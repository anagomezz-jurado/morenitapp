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
  final int? calleId;
  final String calleNombre;
  final String? piso;
  final String? puerta;
  final String iban;

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
    this.calleId,
    this.calleNombre = '',
    this.piso,
    this.puerta,
    this.iban = '',
  });

  factory Hermano.fromJson(Map<String, dynamic> json) {
    String cleanStr(dynamic val) => (val == null || val == false) ? '' : val.toString();

    return Hermano(
      id: json['id'] is int ? json['id'] : int.tryParse(cleanStr(json['id'])),
      numeroHermano: json['numero_hermano'] ?? 0,
      codigoHermano: cleanStr(json['codigo_hermano']),
      nombre: cleanStr(json['nombre']),
      apellido1: cleanStr(json['apellido1']),
      apellido2: cleanStr(json['apellido2']),
      dni: cleanStr(json['dni']),
      email: cleanStr(json['email']),
      telefono: cleanStr(json['telefono']),
      sexo: cleanStr(json['sexo']).isEmpty ? 'Hombre' : json['sexo'],
      fechaAlta: cleanStr(json['fecha_alta']),
      fechaNacimiento: cleanStr(json['fecha_nacimiento']),
      metodoPago: cleanStr(json['metodo_pago']), // Cambio aquí para que use el key exacto
      responsable: json['responsable'] == true,
      calleId: json['calle_id'] is List ? json['calle_id'][0] : json['calle_id'],
      calleNombre: cleanStr(json['calle_nombre']),
      piso: cleanStr(json['piso']),
      puerta: cleanStr(json['puerta']),
      iban: cleanStr(json['iban']),
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
        "iban": iban, // Aseguramos que el IBAN se envíe
      };
}