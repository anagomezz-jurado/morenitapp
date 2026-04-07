class Organizador {
  final int id;
  final String cif;
  final String nombre;
  final String? telefono;
  final String? email;
  final int direccionId; // Many2one id
  final String? piso;
  final String? puerta;
  final String? logo; // Base64 string

  Organizador({
    required this.id,
    required this.cif,
    required this.nombre,
    this.telefono,
    this.email,
    required this.direccionId,
    this.piso,
    this.puerta,
    this.logo,
  });

  factory Organizador.fromJson(Map<String, dynamic> json) => Organizador(
   id: json["id"] is int ? json["id"] : int.parse(json["id"].toString()),
    cif: json['cif'] ?? '',
    nombre: json['nombre'] ?? '',
    telefono: json['telefono'],
    email: json['email'],
    direccionId: json['direccion']?[0] ?? 0, // Odoo suele devolver [id, "nombre"]
    piso: json['piso'],
    puerta: json['puerta'],
    logo: json['logo'] is String ? json['logo'] : null,
  );
}