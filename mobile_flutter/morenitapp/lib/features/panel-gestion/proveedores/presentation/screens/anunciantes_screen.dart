import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/domain/entities/proveedor.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/presentation/providers/proveedor_providers.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class AnunciantesScreen extends ConsumerWidget {
  const AnunciantesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaAnunciantes = ref.watch(listaSoloAnunciantes);
    final asyncState = ref.watch(proveedoresProvider);
    return PlantillaVentanas(
      title: 'Panel de Anunciantes',
      isLoading: asyncState.isLoading,
      onRefresh: () => ref.refresh(proveedoresProvider),
      onNuevo: () =>
          context.push('/proveedores/nuevo', extra: {'forcedAnunciante': true}),

      columns: const [
        DataColumn(
            label:
                Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label:
                Text('NOMBRE', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('TELÉFONO',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('ACCIONES',
                style: TextStyle(fontWeight: FontWeight.bold))),
      ],

      rows: listaAnunciantes
          .map((p) => DataRow(cells: [
                DataCell(Text(p.codProveedor)),
                DataCell(Text(p.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(Text(p.telefono ?? '-')),
                DataCell(Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.blue),
                        onPressed: () =>
                            context.push('/proveedores/editar', extra: p)),
                    IconButton(
                        icon: const Icon(Icons.delete_sweep_outlined,
                            color: Colors.red),
                        onPressed: () => _confirmarEliminar(context, ref, p)),
                  ],
                )),
              ]))
          .toList(),
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Proveedor p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Anunciante?'),
        content:
            Text('Esta acción eliminará a "${p.nombre}" de la base de datos.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(proveedoresProvider.notifier).eliminar(int.parse(p.id));
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}
