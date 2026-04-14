import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';
import '../../domain/entities/cofradia.dart';
import '../providers/secretaria_provider.dart';

class CofradiasScreen extends ConsumerWidget {
  const CofradiasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cofradiasAsync = ref.watch(cofradiasProvider);

    return PlantillaVentanas(
      title: 'Gestión de Cofradías',
      isLoading: cofradiasAsync.isLoading,
      onRefresh: () => ref.read(cofradiasProvider.notifier).refresh(),
      onNuevo: () => context.push('/secretaria/cofradias/nueva'),
      columns: const [
        DataColumn(label: Text('CIF')),
        DataColumn(label: Text('NOMBRE')),
        DataColumn(label: Text('LOCALIDAD')),
        DataColumn(label: Text('ACCIONES')),
      ],
      rows: cofradiasAsync.maybeWhen(
        data: (list) => list.map((c) => DataRow(cells: [
          DataCell(Text(c.cif)),
          DataCell(Text(c.nombre, style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(c.direccionName ?? 'No asignada')),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                onPressed: () => context.push('/secretaria/cofradias/editar', extra: c),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(context, ref, c),
              ),
            ],
          )),
        ])).toList(),
        orElse: () => [],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Cofradia c) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar cofradía?'),
        content: Text('Se eliminará "${c.nombre}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(cofradiasProvider.notifier).eliminar(int.parse(c.id));
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}