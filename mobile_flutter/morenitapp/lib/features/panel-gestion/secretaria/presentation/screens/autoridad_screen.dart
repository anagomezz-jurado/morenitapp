import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';
import '../../domain/entities/autoridad.dart';
import '../providers/secretaria_provider.dart';

class AutoridadesScreen extends ConsumerWidget {
  const AutoridadesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoridadesAsync = ref.watch(autoridadesProvider);

    return PlantillaVentanas(
      title: 'Gestión de Autoridades',
      isLoading: autoridadesAsync.isLoading,
      onRefresh: () => ref.read(autoridadesProvider.notifier).refresh(),
      // Navega a la pantalla del formulario
      onNuevo: () => context.push('/secretaria/autoridades/nueva'),
      columns: const [
        DataColumn(label: Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('NOMBRE', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('CARGO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('TIPO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('LOCALIDAD', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: autoridadesAsync.maybeWhen(
        data: (autoridades) => autoridades.map((a) => DataRow(cells: [
          DataCell(Text(a.codAutoridad)),
          DataCell(Text(a.nombreAutoridad, style: const TextStyle(fontWeight: FontWeight.w500))),
          DataCell(Text(a.cargo)),
          DataCell(Text(a.tipoautoridadName)),
          DataCell(Text(a.localidadName)),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                onPressed: () => context.push('/secretaria/autoridades/editar', extra: a),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmarEliminar(context, ref, a),
              ),
            ],
          )),
        ])).toList(),
        orElse: () => [],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Autoridad autoridad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: Text('¿Deseas eliminar a "${autoridad.nombreAutoridad}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(autoridadesProvider.notifier).eliminar(int.parse(autoridad.id));
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}