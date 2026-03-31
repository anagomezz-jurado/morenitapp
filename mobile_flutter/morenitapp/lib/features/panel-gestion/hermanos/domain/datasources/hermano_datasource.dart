import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';

abstract class HermanoDatasource {

  // Para crear uno nuevo, pasamos la entidad
  Future<Hermano> anadirHermano( Hermano hermano );
  
  // Para dar de baja, solemos usar el ID
  Future<bool> bajaHermano( String id );
  
  // Obtener listado de hermanos (útil para tu menú de "Activos")
  Future<List<Hermano>> getHermanos({ int limit = 10, int offset = 0 });

  // Buscar por DNI o nombre
  Future<Hermano> getHermanoByDni( String dni );

}