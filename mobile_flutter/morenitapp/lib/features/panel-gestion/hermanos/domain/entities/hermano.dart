class Hermano {
  final String? id;
  final int numeroHermano;
  final String? codigoHermano;
  final String sexo;
  final String nombre;
  final String apellido1;
  final String apellido2;
  final String dni;
  final String fechaNacimiento;
  final String telefono;
  final String email;
  final int? calleId; 
  final String calleNombre;
  final String? puerta;
  final String? piso;
  final String fechaAlta;
  final String metodoPago;
  final bool responsable;

  Hermano({
    this.id,
    required this.numeroHermano,
    this.codigoHermano,
    required this.sexo,
    required this.nombre,
    required this.apellido1,
    required this.apellido2,
    required this.dni,
    required this.fechaNacimiento,
    required this.telefono,
    required this.email,
    this.calleId,
    this.calleNombre = '',
    this.puerta,
    this.piso,
    required this.fechaAlta,
    required this.metodoPago,
    this.responsable = false,
  });

  factory Hermano.fromJson(Map<String, dynamic> json) => Hermano(
      id: json['id']?.toString(),
      numeroHermano: json['numero_hermano'] ?? 0,
      codigoHermano: json['codigo_hermano']?.toString(),
      sexo: json['sexo'] ?? 'Hombre',
      nombre: json['nombre'] ?? '',
      apellido1: json['apellido1'] ?? '',
      apellido2: json['apellido2'] ?? '',
      dni: json['dni'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'] ?? '',
      calleId: json['calle_id'],
      calleNombre: json['calle_nombre'] ?? '',
      puerta: json['puerta'],
      piso: json['piso'],
      fechaAlta: json['fecha_alta'] ?? '',
      metodoPago: json['metodo_pago'] ?? 'metalico',
      responsable: json['responsable'] == true,
    );

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
      "metodo_pago": metodoPago == 'Domiciliado' ? 'banco' : 'metalico',
      "responsable": responsable,
      "piso": piso,
      "puerta": puerta,
    };
}