class User {
  final String id;
  final String nombre;
  final String apellido1;
  final String apellido2;
  final String email;
  final String telefono;
  final int rolId;
  final String rolName;
  final int? grupoId;
  final String grupoName;
  final List<String> roles;
  final bool recibirNotiEmail;
  final bool recibirNotiTelefono;
  final String token;

  User({
    required this.id,
    required this.nombre,
    required this.apellido1,
    required this.apellido2,
    required this.email,
    required this.telefono,
    required this.rolId,
    required this.rolName,
    this.grupoId,
    required this.grupoName,
    this.roles = const [],
    required this.recibirNotiEmail,
    required this.recibirNotiTelefono,
    required this.token,
  });

  // --- GETTERS DE CONVENIENCIA ---

  /// Nombre completo formateado
  String get fullName => '$nombre $apellido1 $apellido2'.trim();

  /// Verifica si el usuario tiene privilegios de Administrador
  bool get isAdmin => rolId == 1 || rolName.toLowerCase().contains('admin');

  /// Alias para consistencia en el panel de gestión
  bool get esGrupoAdmin => isAdmin;

  // --- MÉTODOS DE MAPEO ---

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // Aseguramos que el ID siempre sea String, incluso si Odoo manda int
      id: (json['id'] ?? '').toString(),
      nombre: json['nombre'] ?? '',
      apellido1: json['apellido1'] ?? '',
      apellido2: json['apellido2'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      rolId: json['rol_id'] is int ? json['rol_id'] : int.tryParse(json['rol_id']?.toString() ?? '2') ?? 2,
      rolName: json['rol_name'] ?? 'Usuario',
      grupoId: json['grupo_id'] is int ? json['grupo_id'] : int.tryParse(json['grupo_id']?.toString() ?? ''),
      grupoName: json['grupo_name'] ?? 'Sin grupo',
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
      recibirNotiEmail: json['recibirNotiEmail'] ?? false,
      recibirNotiTelefono: json['recibirNotiTelefono'] ?? false,
      // El token suele ser el ID en esta implementación
      token: (json['token'] ?? json['id'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "apellido1": apellido1,
    "apellido2": apellido2,
    "email": email,
    "telefono": telefono,
    "rol_id": rolId,
    "rol_name": rolName,
    "grupo_id": grupoId,
    "grupo_name": grupoName,
    "roles": roles,
    "recibirNotiEmail": recibirNotiEmail,
    "recibirNotiTelefono": recibirNotiTelefono,
    "token": token,
  };

  // --- MÉTODO COPYWITH (Para Riverpod / Inmutabilidad) ---

  User copyWith({
    String? id,
    String? nombre,
    String? apellido1,
    String? apellido2,
    String? email,
    String? telefono,
    int? rolId,
    String? rolName,
    int? grupoId,
    String? grupoName,
    List<String>? roles,
    bool? recibirNotiEmail,
    bool? recibirNotiTelefono,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido1: apellido1 ?? this.apellido1,
      apellido2: apellido2 ?? this.apellido2,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      rolId: rolId ?? this.rolId,
      rolName: rolName ?? this.rolName,
      grupoId: grupoId ?? this.grupoId,
      grupoName: grupoName ?? this.grupoName,
      roles: roles ?? this.roles,
      recibirNotiEmail: recibirNotiEmail ?? this.recibirNotiEmail,
      recibirNotiTelefono: recibirNotiTelefono ?? this.recibirNotiTelefono,
      token: token ?? this.token,
    );
  }
}