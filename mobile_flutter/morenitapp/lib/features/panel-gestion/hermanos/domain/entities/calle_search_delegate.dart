import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/codigo_postal.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/localidad.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';

class CalleSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  CalleSearchDelegate({required this.ref});

  @override
  String get searchFieldLabel => 'Buscar calle...';

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _mostrarResultados(context);

  @override
  Widget buildSuggestions(BuildContext context) => _mostrarResultados(context);

  Widget _mostrarResultados(BuildContext context) {
  // Usamos watch para reaccionar a los cambios
  final callesAsync = ref.watch(callesProvider);
  final localidadesAsync = ref.watch(localidadesProvider);
  final cpsAsync = ref.watch(codigosPostalesProvider);

  // 1. Si está cargando, mostramos loader
  if (callesAsync.isLoading || localidadesAsync.isLoading || cpsAsync.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  final calles = callesAsync.value ?? [];
  final localidades = localidadesAsync.value ?? [];
  final cps = cpsAsync.value ?? [];

  // 2. Si las listas están vacías pero no están cargando, es que hubo un error o falta dispararlas
  if (localidades.isEmpty || cps.isEmpty) {
     return const Center(
       child: Text("Cargando datos de ubicación..."),
     );
  }

  final sugerencias = calles
      .where((c) => c.nombreCalle.toLowerCase().contains(query.toLowerCase()))
      .toList();

  return ListView.builder(
    itemCount: sugerencias.length + (query.isNotEmpty ? 1 : 0),
    itemBuilder: (context, i) {
      if (i == sugerencias.length) {
        return ListTile(
          leading: const Icon(Icons.add),
          title: Text('Crear calle: "$query"'),
          onTap: () => close(context, query),
        );
      }

      final calle = sugerencias[i];

      // BUSQUEDA MEJORADA:
      // Usamos .firstWhere con un orElse que nos ayude a debuguear
      final loc = localidades.firstWhere(
        (l) => l.id == calle.localidadId,
        orElse: () => Localidad(id: 0, nombreLocalidad: 'ID ${calle.localidadId} no encontrada', codProvinciaId: 0, nombreCapital: ''),
      );

      final cp = cps.firstWhere(
        (c) => c.id == calle.codPostalId,
        orElse: () => CodigoPostal(id: 0, name: 'ID ${calle.codPostalId} no encontrado', localidadId: 0),
      );

      return ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(calle.nombreCalle),
        subtitle: Text('${loc.nombreLocalidad} — CP: ${cp.name}'),
        onTap: () => close(context, calle),
      );
    },
  );
}
}