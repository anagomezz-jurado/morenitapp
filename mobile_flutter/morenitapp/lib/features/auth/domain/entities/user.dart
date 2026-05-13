// ─── FUNCIÓN GLOBAL DE CAPITALIZACIÓN ───────────────────────────────────────
// Definida fuera de la clase para poder usarla en el factory User.fromJson
String capText(String text) {
  if (text.isEmpty) return text;
  return text
      .trim()
      .toLowerCase()
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

class User {
  // --- PROPIEDADES ---
  final String id;
  final String nombre;
  final String apellido1;
  final String apellido2;
  final String email;
  final String telefono;
  final String token;

  // Roles y Permisos
  final int rolId;
  final String rolName;
  final List<String> roles;

  // Grupos y Organización
  final int? grupoId;
  final String grupoName;

  // Vinculación (Odoo/Entidad)
  final int? hermanoId;
  final String? numeroHermano;

  // Preferencias
  final bool recibirNotiEmail;

  // --- CONSTRUCTOR ---
  User({
    required this.id,
    required this.nombre,
    required this.apellido1,
    required this.apellido2,
    required this.email,
    required this.telefono,
    required this.rolId,
    required this.rolName,
    required this.grupoName,
    required this.token,
    required this.recibirNotiEmail,
    this.grupoId,
    this.hermanoId,
    this.numeroHermano,
    this.roles = const [],
  });

  // --- GETTERS DE CONVENIENCIA ---
  String get fullName => '$nombre $apellido1 $apellido2'.trim();
  bool get isAdmin => rolId == 1 || rolName.toLowerCase().contains('admin');
  bool get esGrupoAdmin => isAdmin;

  // --- MÉTODOS DE MAPEO (JSON) ---
  factory User.fromJson(Map<String, dynamic> json) {
    String cleanString(dynamic val) {
      if (val == null || val == false || val.toString() == 'false') return '';
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
      // capText se aplica aquí para que SIEMPRE lleguen capitalizados
      nombre: capText(cleanString(json['nombre'])),
      apellido1: capText(cleanString(json['apellido1'])),
      apellido2: capText(cleanString(json['apellido2'])),
      email: cleanString(json['email']),
      telefono: cleanString(json['telefono']),
      token: (json['token'] ?? json['id'] ?? '').toString(),

      rolId: json['rol_id'] is int
          ? json['rol_id']
          : int.tryParse(json['rol_id']?.toString() ?? '2') ?? 2,
      rolName: cleanString(json['rol_name'] ?? 'Usuario'),
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],

      grupoId: parseOdooId(json['grupo_id']),
      grupoName: cleanString(json['grupo_name'] ?? 'Sin grupo'),

      hermanoId: parseOdooId(json['hermano_id']),
      numeroHermano: cleanString(json['numero_hermano']).isEmpty
          ? 'No vinculado'
          : cleanString(json['numero_hermano']),

      recibirNotiEmail: json['recibirNotiEmail'] ?? false,
    );
  }

  // --- INMUTABILIDAD ---
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
      token: token ?? this.token,
      hermanoId: hermanoId ?? this.hermanoId,
      numeroHermano: numeroHermano ?? this.numeroHermano,
    );
  }
}