import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/codigo_postal.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/localidad.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';

class CalleSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  CalleSearchDelegate({required this.ref});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final parentTheme = Theme.of(context);
    // Usamos los colores dinámicos del tema para la barra de búsqueda
    return parentTheme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: parentTheme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: parentTheme.colorScheme.primary),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Buscar calle...';

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.grey),
            onPressed: () => query = '',
          )
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _mostrarResultados(context);

  @override
  Widget buildSuggestions(BuildContext context) => _mostrarResultados(context);

  Widget _mostrarResultados(BuildContext context) {
    // Accedemos a los colores del tema actual
    final colors = Theme.of(context).colorScheme;
    
    final callesAsync = ref.watch(callesProvider);
    final localidadesAsync = ref.watch(localidadesProvider);
    final cpsAsync = ref.watch(codigosPostalesProvider);

    if (callesAsync.isLoading || localidadesAsync.isLoading || cpsAsync.isLoading) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }

    final sugerencias = (callesAsync.value ?? [])
        .where((c) => c.nombreCalle.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Container(
      color: const Color(0xFFF0F2F5), // Mantengo el fondo gris suave de tu plantilla
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: sugerencias.length + (query.isNotEmpty ? 1 : 0),
        itemBuilder: (context, i) {
          
          // --- Opción para añadir nueva calle ---
          if (i == sugerencias.length) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  child: Icon(Icons.add_location_alt_rounded, color: colors.primary),
                ),
                title: Text('Añadir nueva calle: "$query"', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary)),
                onTap: () => close(context, query),
              ),
            );
          }

          final calle = sugerencias[i];
          
          final loc = localidadesAsync.value?.cast<Localidad?>().firstWhere(
            (l) => l?.id.toString() == calle.localidadId.toString(), orElse: () => null);

          final cp = cpsAsync.value?.cast<CodigoPostal?>().firstWhere(
            (c) => c?.id.toString() == calle.codPostalId.toString(), orElse: () => null);

          // --- Tarjeta de resultado con colores de AppTheme ---
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary, // Fondo Primario dinámico
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_on_rounded, color: colors.onPrimary, size: 22),
              ),
              title: Text(
                calle.nombreCalle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16, 
                  color: Color(0xFF2D3436)
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${loc?.nombreLocalidad ?? '...'} • CP: ${cp?.name ?? 'S/N'}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              onTap: () => close(context, calle),
            ),
          );
        },
      ),
    );
  }
}