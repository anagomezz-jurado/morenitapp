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
  final int? hermanoId;
final String? numeroHermano;

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
    this.hermanoId,
    this.numeroHermano,
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
  String cleanString(dynamic val) {
    if (val == null || val == false || val.toString() == 'false') return '';
    // Si es una lista (formato Odoo [id, nombre]), sacamos el nombre
    if (val is List && val.length > 1) return val[1].toString();
    return val.toString();
  }

  int? parseOdooId(dynamic value) {
    if (value is List && value.isNotEmpty) return value[0] as int;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  return User(
    id: (json['id'] ?? '').toString(),
    nombre: cleanString(json['nombre']),
    apellido1: cleanString(json['apellido1']),
    apellido2: cleanString(json['apellido2']),
    email: cleanString(json['email']),
    telefono: cleanString(json['telefono']),
    rolId: json['rol_id'] is int ? json['rol_id'] : int.tryParse(json['rol_id']?.toString() ?? '2') ?? 2,
    rolName: cleanString(json['rol_name'] ?? 'Usuario'),
    grupoId: parseOdooId(json['grupo_id']),
    grupoName: cleanString(json['grupo_name'] ?? 'Sin grupo'),
    roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    recibirNotiEmail: json['recibirNotiEmail'] ?? false,
    recibirNotiTelefono: json['recibirNotiTelefono'] ?? false,
    token: (json['token'] ?? json['id'] ?? '').toString(),
    hermanoId: parseOdooId(json['hermano_id']),
    // MEJORA AQUÍ:
    numeroHermano: cleanString(json['numero_hermano']).isEmpty 
        ? 'No vinculado' 
        : cleanString(json['numero_hermano']),
  );
}

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
    int? hermanoId,
String? numeroHermano,

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
      hermanoId: hermanoId ?? this.hermanoId,
    numeroHermano: numeroHermano ?? this.numeroHermano,
    );
  }
}