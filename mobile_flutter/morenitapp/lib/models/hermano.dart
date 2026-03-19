class Hermano {
  final String nombre;
  final String apellido1;
  final String apellido2;
  final String telefono;
  final String dni;
  final String fechaNacimiento;
  final String metodoPago;

  Hermano({
    required this.nombre,
    required this.apellido1,
    required this.apellido2,
    required this.telefono,
    required this.dni,
    required this.fechaNacimiento,
    required this.metodoPago,
  });

  factory Hermano.fromJson(Map<String, dynamic> json) {
    return Hermano(
      nombre: json['nombre'] ?? '',
      apellido1: json['apellido1'] ?? '',
      apellido2: json['apellido2'] ?? '',
      telefono: json['telefono'] ?? '',
      dni: json['dni'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'] ?? '',
      metodoPago: json['metodo_pago'] ?? '',
    );
  }
}