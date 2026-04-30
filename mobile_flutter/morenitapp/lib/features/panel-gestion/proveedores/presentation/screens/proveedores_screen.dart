import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/domain/entities/proveedor.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/presentation/providers/proveedor_providers.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class ProveedoresScreen extends ConsumerWidget {
  const ProveedoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proveedoresAsync = ref.watch(proveedoresProvider);
    final listaTodos = ref.watch(listaTodosLosProveedores);

    return PlantillaVentanas(
      title: 'Gestión de Proveedores',
      isLoading: proveedoresAsync.isLoading,
      onRefresh: () => ref.refresh(proveedoresProvider),
      onNuevo: () => context.push('/proveedores/nuevo'),
      onSearch: (val) {
      },
      // CORRECCIÓN: 'columns' en lugar de 'columnas'
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
            label:
                Text('EMAIL', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('ACCIONES',
                style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: listaTodos
          .map((p) => DataRow(cells: [
                DataCell(Text(p.codProveedor)),
                DataCell(Text(p.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(Text(p.telefono ?? '-')),
                DataCell(Text(p.email ?? '-')),
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
        title: const Text('¿Eliminar registro?'),
        content: Text('¿Desea eliminar al proveedor "${p.nombre}"?'),
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
