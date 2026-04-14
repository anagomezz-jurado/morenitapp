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
        DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('NOMBRE PROVINCIA', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: provinciasAsync.maybeWhen(
        data: (provincias) => provincias.map((prov) => DataRow(cells: [
          DataCell(Text(prov.id.toString())),
          DataCell(Text(prov.nombreProvincia, style: const TextStyle(fontWeight: FontWeight.w500))),
          DataCell(IconButton(icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red), onPressed: () => _confirmDelete(context, ref, prov))),
        ])).toList(),
        orElse: () => [],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic prov) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Desea eliminar la provincia ${prov.nombreProvincia}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await ref.read(provinciasProvider.notifier).borrarProvincia(prov.id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  _mostrarAdvertenciaUso(context, prov.nombreProvincia);
                }
              }
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }

  void _mostrarAdvertenciaUso(BuildContext context, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
        content: Text('La provincia "$nombre" tiene datos vinculados y no puede ser borrada.', textAlign: TextAlign.center),
        actions: [Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('ENTENDIDO')))],
      ),
    );
  }
}