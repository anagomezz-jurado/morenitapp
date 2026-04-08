class User {
  final String id;
  final String email;
  final String nombre;
  final String apellido1;
  final String apellido2;
  final String telefono;
  final List<String> roles;
  final String token;
  final int rolId;
  final bool recibirNotiEmail;
  final bool recibirNotiTelefono;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido1,
    required this.apellido2,
    required this.telefono,
    required this.roles,
    required this.token,
    required this.rolId,
    required this.recibirNotiEmail,
    required this.recibirNotiTelefono,
  });

  // Nombre completo calculado para mostrar en la UI
  String get fullName => '$nombre $apellido1 $apellido2'.trim();

  bool get isAdmin => rolId == 1 || roles.contains('admin');
  bool get isUser => rolId == 2;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"].toString(),
    email: json["email"] ?? '',
    nombre: json["nombre"] ?? '',
    apellido1: json["apellido1"] ?? '',
    apellido2: json["apellido2"] ?? '',
    telefono: json["telefono"] ?? '',
    roles: List<String>.from(json["roles"] ?? []),
    token: json["token"] ?? '',
    rolId: json["rol_id"] ?? 2,
    recibirNotiEmail: json["recibirNotiEmail"] ?? true,
    recibirNotiTelefono: json["recibirNotiTelefono"] ?? false,
  );
}