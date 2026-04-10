import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class ProvinciaScreen extends ConsumerWidget {
  const ProvinciaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provinciasAsync = ref.watch(provinciasProvider);

    return PlantillaVentanas(
      title: 'Gestión de Provincias',
      isLoading: provinciasAsync.isLoading,
      onRefresh: () => ref.read(provinciasProvider.notifier).cargarProvincias(),
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('NOMBRE PROVINCIA')),
        DataColumn(label: Text('ACCIONES')),
      ],
      rows: provinciasAsync.maybeWhen(
        data: (provincias) => provincias.map((prov) => DataRow(
          cells: [
            DataCell(Text(prov.id.toString())),
            DataCell(Text(prov.nombreProvincia)),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmarEliminacion(context, ref, prov),
                ),
              ],
            )),
          ],
        )).toList(),
        orElse: () => [],
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, WidgetRef ref, dynamic prov) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Desea eliminar la provincia ${prov.nombreProvincia}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                // Intentamos borrar
                await ref.read(provinciasProvider.notifier).borrarProvincia(prov.id);
                if (context.mounted) Navigator.pop(context); // Cerrar diálogo de confirmación
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Provincia eliminada correctamente'))
                );
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Cerrar diálogo de confirmación
                  _mostrarAdvertenciaUso(context, prov.nombreProvincia);
                }
              }
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarAdvertenciaUso(BuildContext context, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('No se puede eliminar'),
          ],
        ),
        content: Text(
          'La provincia "$nombre" no puede ser eliminada porque tiene localidades vinculadas con este código postal/ID.\n\nDebe eliminar primero las localidades asociadas.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ENTENDIDO'),
            ),
          )
        ],
      ),
    );
  }
}