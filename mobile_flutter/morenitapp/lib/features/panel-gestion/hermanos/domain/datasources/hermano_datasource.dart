import '../entities/hermano.dart';

abstract class HermanoDatasource {
  Future<Hermano> anadirHermano(Hermano hermano);
  Future<List<Hermano>> getHermanos({int limit = 10, int offset = 0});
  Future<void> updateHermano(int id, Map<String, dynamic> datos);
  Future<void> eliminarHermano(int id);
  Future<bool> bajaHermano(int id);
  Future<Hermano> getHermanoByDni(String dni);
}
