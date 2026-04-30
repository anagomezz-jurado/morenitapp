import '../../domain/entities/autoridad.dart';
import '../../domain/entities/cargo.dart';
import '../../domain/entities/cofradia.dart';
import '../../domain/repositories/secretaria_repository.dart';
import '../datasources/secretaria_datasource_impl.dart';

class SecretariaRepositoryImpl implements SecretariaRepository {
  final SecretariaDatasourceImpl datasource;
  SecretariaRepositoryImpl(this.datasource);

  @override
  Future<List<Autoridad>> getAutoridades() => datasource.getAutoridades();

  @override
  Future<List<Cargo>> getCargos() => datasource.getCargos();

  @override
  Future<List<Cofradia>> getCofradias() => datasource.getCofradias();

  @override
  Future<void> upsertAutoridad(Map<String, dynamic> data) async {
    await datasource.upsertAutoridad(data);
  }

  @override
  Future<void> upsertCargo(Map<String, dynamic> data) async {
    await datasource.upsertCargo(data);
  }

  @override
  Future<void> upsertCofradia(Map<String, dynamic> data) async {
    await datasource.upsertCofradia(data);
  }

  @override
  Future<void> deleteRegistro(String modelo, int id) async {
    await datasource.deleteRegistro(modelo, id);
  }

  @override
  Future<List<Map<String, dynamic>>> getTiposCargos() =>
      datasource.getTiposCargos();

  @override
  Future<List<Map<String, dynamic>>> getCalles() => datasource.getCalles();
}
