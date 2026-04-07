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
      // Antes tenías "cod_grupo_proveedor", cámbialo a "codigo"
      codigo: json["codigo"] ?? '', 
      // Antes tenías "nombre_grupo_proveedor", cámbialo a "nombre"
      nombre: json["nombre"] ?? '', 
    );
}