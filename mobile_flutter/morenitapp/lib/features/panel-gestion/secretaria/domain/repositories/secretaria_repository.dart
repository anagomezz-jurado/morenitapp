import '../entities/autoridad.dart';
import '../entities/cargo.dart';
import '../entities/cofradia.dart';

abstract class SecretariaRepository {
  Future<List<Autoridad>> getAutoridades();
  Future<List<Cargo>> getCargos();
  Future<List<Cofradia>> getCofradias();

  Future<void> upsertAutoridad(Map<String, dynamic> data);
  Future<void> upsertCargo(Map<String, dynamic> data);
  Future<void> upsertCofradia(Map<String, dynamic> data);

  Future<void> deleteRegistro(String modelo, int id);
}