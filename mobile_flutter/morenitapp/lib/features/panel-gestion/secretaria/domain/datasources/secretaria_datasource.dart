import '../entities/autoridad.dart';
import '../entities/cargo.dart';
import '../entities/cofradia.dart';

abstract class SecretariaDatasource {
  Future<List<Autoridad>> getAutoridades();
  Future<List<Cargo>> getCargos();
  Future<List<Cofradia>> getCofradias();

  Future<Map<String, dynamic>> upsertAutoridad(Map<String, dynamic> data);
  Future<Map<String, dynamic>> upsertCargo(Map<String, dynamic> data);
  Future<Map<String, dynamic>> upsertCofradia(Map<String, dynamic> data);
  
  Future<Map<String, dynamic>> deleteRegistro(String modelo, int id);
}