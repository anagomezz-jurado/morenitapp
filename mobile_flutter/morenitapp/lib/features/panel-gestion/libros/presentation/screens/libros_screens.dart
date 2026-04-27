import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Opcional, pero recomendado según tus pantallas anteriores
import 'package:morenitapp/features/panel-gestion/libros/presentation/providers/libro_provider.dart';
import 'package:morenitapp/features/panel-gestion/libros/domain/entities/libro.dart'; // Importa la entidad
import 'package:morenitapp/features/panel-gestion/libros/presentation/screens/libro_anunciante.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class LibrosScreen extends ConsumerWidget {
  const LibrosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final librosAsync = ref.watch(librosProvider);

    return PlantillaVentanas(
      title: 'Gestión de Libros y Revistas',
      isLoading: librosAsync.isLoading,
      onRefresh: () async => await ref.refresh(librosProvider),
      onNuevo: () => _openForm(context),
      onSearch: (val) {
        // Implementar lógica de filtrado si es necesario
      },
      paginationText: librosAsync.when(
        data: (lista) => 'Total: ${lista.length} registros',
        error: (_, __) => 'Error al cargar datos',
        loading: () => 'Cargando registros...',
      ),
      columns: const [
        DataColumn(label: Text('CÓDIGO')),
        DataColumn(label: Text('NOMBRE')),
        DataColumn(label: Text('AÑO')),
        DataColumn(label: Text('IMP. ANUNC.')), // Cambiado para mayor claridad
        DataColumn(label: Text('ACCIONES')),
      ],
      rows: librosAsync.when(
        data: (libros) => libros.map((libro) => DataRow(
          cells: [
            DataCell(Text(libro.codLibro)),
            DataCell(Text(libro.nombre, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(libro.anio.toString())),
            DataCell(
              Text(
                '${libro.totalAnunciantes.toStringAsFixed(2)} €', // Usamos el campo calculado del modelo
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              )
            ),
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _openForm(context, libro: libro),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _confirmarEliminar(context, ref, libro),
                ),
              ],
            )),
          ],
        )).toList(),
        error: (err, _) => [
          DataRow(cells: [
            DataCell(Text('Error: $err')),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
          ])
        ],
        loading: () => [],
      ),
    );
  }

  void _openForm(BuildContext context, {Libro? libro}) {
    // Si usas MaterialPageRoute:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LibroFormScreen(libroAEditar: libro),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Libro libro) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar borrado'),
        content: Text('¿Deseas eliminar "${libro.nombre}"?\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('CANCELAR')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success = await ref.read(librosProvider.notifier).borrarLibro(libro.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al eliminar el libro'))
                  );
                }
              }
            },
            child: const Text('BORRAR', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}