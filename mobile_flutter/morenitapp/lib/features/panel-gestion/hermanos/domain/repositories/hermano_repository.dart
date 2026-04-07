import '../entities/hermano.dart';

abstract class HermanoRepository {
  Future<List<Hermano>> getHermanos({int limit = 10, int offset = 0});
  Future<Hermano> anadirHermano(Hermano hermano);
  Future<void> updateHermano(int id, Map<String, dynamic> datos); // Cambiado a int
  Future<void> eliminarHermano(int id); // Cambiado a int
  Future<bool> bajaHermano(int id);     // Cambiado a int
  Future<Hermano> getHermanoByDni(String dni);
}