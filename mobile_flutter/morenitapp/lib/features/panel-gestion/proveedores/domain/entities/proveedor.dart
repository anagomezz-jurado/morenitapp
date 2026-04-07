
class Proveedor {
  final String id;
  final String codProveedor;
  final String nombre;
  final String? contacto;
  final String? telefono;
  final String? email;
  final int? grupoId;
  final String? grupoNombre;
  final String? direccion;
  final String? observaciones;
  final bool anunciante;

  Proveedor({
    required this.id,
    required this.codProveedor,
    required this.nombre,
    this.contacto,
    this.telefono,
    this.email,
    this.grupoId,
    this.grupoNombre,
    this.direccion,
    this.observaciones,
    this.anunciante = false,
  });
}