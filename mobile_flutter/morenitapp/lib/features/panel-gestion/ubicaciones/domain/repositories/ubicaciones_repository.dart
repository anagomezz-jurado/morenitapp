import '../entities/provincia.dart';
import '../entities/localidad.dart';
import '../entities/calle.dart';
import '../entities/codigo_postal.dart';

abstract class UbicacionRepository {

  // El repositorio suele replicar los métodos del datasource
  // pero es donde podrías manejar lógica de fallos o mapeos extra.

  // Provincias
  Future<List<Provincia>> getProvincias();
  Future<Provincia> crearProvincia(Provincia provincia);
  Future<bool> eliminarProvincia(int id);
  Future<bool> editarProvincia(int id, Map<String, dynamic> datos);

  // Localidades
  Future<List<Localidad>> getLocalidades({int? provinciaId});
  Future<Localidad> crearLocalidad(Localidad localidad);
  Future<bool> editarLocalidad(int id, Map<String, dynamic> datos);
  Future<bool> eliminarLocalidad(int id);

  // Códigos Postales
  Future<List<CodigoPostal>> getCodigosPostales({int? localidadId});
  Future<CodigoPostal> crearCodigoPostal(CodigoPostal cp);
 Future<bool> editarCodigoPostal(int id, Map<String, dynamic> datos); // Añade esto
  Future<bool> eliminarCodigoPostal(int id);

  // Calles
  Future<List<Calle>> getCalles();
  Future<Calle> crearCalle(Calle calle);
  Future<bool> eliminarCalle(int id);
  Future<bool> editarCalle(int id, Map<String, dynamic> datos);

}