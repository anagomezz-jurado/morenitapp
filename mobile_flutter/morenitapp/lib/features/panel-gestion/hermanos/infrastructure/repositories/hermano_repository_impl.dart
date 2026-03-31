import 'package:morenitapp/features/panel-gestion/hermanos/domain/datasources/hermano_datasource.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/repositories/hermano_repository.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/infrastructure/datasources/hermanos_datasource_impl.dart';

// features/panel-gestion/hermanos/domain/repositories/hermano_repository.dart


class HermanoRepositoryImpl extends HermanoRepository {

  final HermanoDatasource dataSource;

  // Usamos HermanosDatasourceImpl (en plural como tu import) 
  // o el nombre exacto que tenga tu archivo de infraestructura
  HermanoRepositoryImpl({
    HermanoDatasource? dataSource
  }) : dataSource = dataSource ?? HermanosDatasourceImpl();

  @override
  Future<List<Hermano>> getHermanos({int limit = 10, int offset = 0}) {
    return dataSource.getHermanos(limit: limit, offset: offset);
  }

  @override
  Future<Hermano> anadirHermano(Hermano hermano) async {
    // Asegúrate de que en la definición de la interfaz 'HermanoRepository'
    // este método devuelva Future<Hermano> y no Future<void>
    return dataSource.anadirHermano(hermano);
  }

  @override
  Future<bool> bajaHermano(String id) {
    return dataSource.bajaHermano(id);
  }

  @override
  Future<Hermano> getHermanoByDni(String dni) {
    return dataSource.getHermanoByDni(dni);
  }
}