import '../../domain/datasources/hermano_datasource.dart';
import '../../domain/entities/hermano.dart';
import '../../domain/repositories/hermano_repository.dart';
import '../datasources/hermanos_datasource_impl.dart';

class HermanoRepositoryImpl extends HermanoRepository {
  final HermanoDatasource dataSource;

  HermanoRepositoryImpl({HermanoDatasource? dataSource})
      : dataSource = dataSource ?? HermanosDatasourceImpl();

  @override
  Future<List<Hermano>> getHermanos({int limit = 10, int offset = 0}) =>
      dataSource.getHermanos(limit: limit, offset: offset);

  @override
  Future<Hermano> anadirHermano(Hermano hermano) => dataSource.anadirHermano(hermano);

  @override
  Future<void> updateHermano(int id, Map<String, dynamic> datos) =>
      dataSource.updateHermano(id, datos);

  @override
  Future<void> eliminarHermano(int id) => dataSource.eliminarHermano(id);

  @override
  Future<bool> bajaHermano(int id) => dataSource.bajaHermano(id);

  @override
  Future<Hermano> getHermanoByDni(String dni) => dataSource.getHermanoByDni(dni);
}