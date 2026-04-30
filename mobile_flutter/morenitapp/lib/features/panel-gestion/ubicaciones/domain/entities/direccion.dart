class Direccion {
  final int id;
  final String calle;
  final String numero;
  final int provinciaId;
  final int localidadId;
  final int cpId;

  Direccion(
      {required this.id,
      required this.calle,
      required this.numero,
      required this.provinciaId,
      required this.localidadId,
      required this.cpId});
}
