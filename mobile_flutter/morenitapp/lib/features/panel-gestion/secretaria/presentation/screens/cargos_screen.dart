import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';
import '../../domain/entities/cargo.dart';
import '../providers/secretaria_provider.dart';

class CargosScreen extends ConsumerWidget {
  const CargosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cargosAsync = ref.watch(cargosProvider);

    return PlantillaVentanas(
      title: 'Gestión de Cargos',
      isLoading: cargosAsync.isLoading,
      onRefresh: () async => await ref.read(cargosProvider.notifier).refresh(),
      onNuevo: () => context.push('/secretaria/cargos/nuevo'),
      columns: const [
        DataColumn(label: Text('COD')),
        DataColumn(label: Text('CARGO')),
        DataColumn(label: Text('INICIO')),
        DataColumn(label: Text('ACCIONES')),
      ],
      rows: cargosAsync.maybeWhen(
        data: (cargos) => cargos.map((c) => DataRow(cells: [
          DataCell(Text(c.codCargo)),
          DataCell(Text(c.nombreCargo)),
          DataCell(Text(c.fechaInicio.toString().split(' ')[0])),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                onPressed: () => context.push('/secretaria/cargos/editar', extra: c),
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

  void _confirmDelete(BuildContext context, WidgetRef ref, Cargo cargo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar cargo?'),
        content: Text('Se eliminará "${cargo.nombreCargo}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(cargosProvider.notifier).eliminar(int.parse(cargo.id));
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}