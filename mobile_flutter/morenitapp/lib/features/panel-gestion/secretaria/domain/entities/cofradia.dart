class Cofradia {
  final String id;
  final String cif;
  final String nombre;
  final int fundacion;
  final String email;

  Cofradia({
    required this.id,
    required this.cif,
    required this.nombre,
    required this.fundacion,
    required this.email,
  });

  factory Cofradia.fromJson(Map<String, dynamic> json) {
    return Cofradia(
      id: json['id']?.toString() ?? '',
      cif: json['cif']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      fundacion: (json['anioFundacion'] is int) ? json['anioFundacion'] : 0,
      email: (json['email'] is String) ? json['email'] : '',
    );
  }
}