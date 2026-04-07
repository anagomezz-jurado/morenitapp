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
    final Map<String, dynamic> res = await datasource.upsertAutoridad(data);
    if (res['success'] != true) throw Exception(res['error'] ?? 'Error');
  }

  @override
  Future<void> upsertCargo(Map<String, dynamic> data) async {
    final Map<String, dynamic> res = await datasource.upsertCargo(data);
    if (res['success'] != true) throw Exception(res['error'] ?? 'Error');
  }

  @override
  Future<void> upsertCofradia(Map<String, dynamic> data) async {
    final Map<String, dynamic> res = await datasource.upsertCofradia(data);
    if (res['success'] != true) throw Exception(res['error'] ?? 'Error');
  }

  @override
  Future<void> deleteRegistro(String modelo, int id) async {
    final Map<String, dynamic> res = await datasource.deleteRegistro(modelo, id);
    if (res['success'] != true) throw Exception(res['error'] ?? 'Error');
  }
}