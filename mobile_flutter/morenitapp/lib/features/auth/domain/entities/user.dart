class User {
  final String id;
  final String email;
  final String fullName;
  final List<String> roles;
  final String token;
  final int rolId; // <--- Nueva propiedad para manejar la lógica de Odoo

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.roles,
    required this.token,
    required this.rolId, // <--- Requerido en el constructor
  });

  // Mantienes tus getters de conveniencia
  bool get isAdmin => rolId == 1 || roles.contains('admin');
  bool get isUser => rolId == 2;
}