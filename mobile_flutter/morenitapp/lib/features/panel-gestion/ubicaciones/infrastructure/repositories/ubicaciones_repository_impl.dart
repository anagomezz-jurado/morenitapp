import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/datasources/ubicaciones_datasource.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/codigo_postal.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/localidad.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/provincia.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/repositories/ubicaciones_repository.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/infrastructure/datasources/ubicaciones_datasource_impl.dart';

class UbicacionRepositoryImpl extends UbicacionRepository {
  final UbicacionDatasource dataSource;

  UbicacionRepositoryImpl({UbicacionDatasource? dataSource})
      : dataSource = dataSource ?? UbicacionDataSourceImpl();

  // Provincias
  @override
  Future<List<Provincia>> getProvincias() => dataSource.getProvincias();

  @override
  Future<Provincia> crearProvincia(Provincia provincia) =>
      dataSource.crearProvincia(provincia);

  @override
  Future<bool> editarProvincia(int id, Map<String, dynamic> datos) =>
      dataSource.editarProvincia(id, datos);

  @override
  Future<bool> eliminarProvincia(int id) => dataSource.eliminarProvincia(id);

  // Localidades
  @override
  Future<List<Localidad>> getLocalidades({int? provinciaId}) =>
      dataSource.getLocalidades(provinciaId: provinciaId);

  @override
  Future<Localidad> crearLocalidad(Localidad localidad) =>
      dataSource.crearLocalidad(localidad);

  @override
  Future<bool> eliminarLocalidad(int id) => dataSource.eliminarLocalidad(id);

  // Códigos Postales
  @override
  Future<List<CodigoPostal>> getCodigosPostales({int? localidadId}) =>
      dataSource.getCodigosPostales(localidadId: localidadId);

  @override
  Future<CodigoPostal> crearCodigoPostal(CodigoPostal cp) =>
      dataSource.crearCodigoPostal(cp);

  @override
  Future<bool> eliminarCodigoPostal(int id) =>
      dataSource.eliminarCodigoPostal(id);
  @override
  Future<bool> editarCodigoPostal(int id, Map<String, dynamic> datos) {
    return dataSource.editarCodigoPostal(id, datos);
  }

  // Calles
  @override
  Future<List<Calle>> getCalles() => dataSource.getCalles();

  @override
  Future<Calle> crearCalle(Calle calle) => dataSource.crearCalle(calle);

  @override
  Future<bool> editarCalle(int id, Map<String, dynamic> datos) =>
      dataSource.editarCalle(id, datos);

  @override
  Future<bool> eliminarCalle(int id) => dataSource.eliminarCalle(id);

  @override
  Future<bool> editarLocalidad(int id, Map<String, dynamic> datos) {
    return dataSource.editarLocalidad(id, datos);
  }
}
