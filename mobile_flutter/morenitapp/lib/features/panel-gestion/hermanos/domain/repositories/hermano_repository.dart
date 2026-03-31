import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';

abstract class HermanoRepository {
  Future<List<Hermano>> getHermanos({int limit = 10, int offset = 0});
  Future<Hermano> anadirHermano(Hermano hermano); // Ambos deben devolver Future<Hermano>
  Future<bool> bajaHermano(String id);
  Future<Hermano> getHermanoByDni(String dni);
}