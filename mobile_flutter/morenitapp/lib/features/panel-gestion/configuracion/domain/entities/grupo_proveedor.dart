class GrupoProveedor {
  final int? id;
  final String codigo;
  final String nombre;

  GrupoProveedor({
    this.id,
    required this.codigo,
    required this.nombre,
  });
factory GrupoProveedor.fromJson(Map<String, dynamic> json) => GrupoProveedor(
      id: json["id"], 
      codigo: json["codigo"] ?? '', 
      nombre: json["nombre"] ?? '', 
    );
}