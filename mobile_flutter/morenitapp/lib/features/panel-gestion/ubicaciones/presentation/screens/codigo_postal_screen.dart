import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/codigo_postal.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class CodigoPostalScreen extends ConsumerWidget {
  const CodigoPostalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cpAsync = ref.watch(codigosPostalesProvider);
    final localidadesAsync = ref.watch(localidadesProvider);

    return PlantillaVentanas(
      title: 'Códigos Postales',
      isLoading: cpAsync.isLoading,
      onRefresh: () => ref.read(codigosPostalesProvider.notifier).cargarCodigosPostales(),
      onNuevo: () => _showFormDialog(context, ref),
      columns: const [
        DataColumn(label: Text('CÓDIGO POSTAL')),
        DataColumn(label: Text('LOCALIDAD ASIGNADA')),
        DataColumn(label: Text('ACCIONES')),
      ],
      rows: cpAsync.maybeWhen(
        data: (codigos) => codigos.map((cp) {
          final nombreLocalidad = localidadesAsync.maybeWhen(
            data: (list) => list.any((l) => l.id == cp.localidadId) 
                ? list.firstWhere((l) => l.id == cp.localidadId).nombreLocalidad 
                : 'ID: ${cp.localidadId}',
            orElse: () => 'Cargando...',
          );

          return DataRow(cells: [
            DataCell(Text(cp.name, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(nombreLocalidad)),
            DataCell(Row(
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showFormDialog(context, ref, cp: cp)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(context, ref, cp)),
              ],
            )),
          ]);
        }).toList(),
        orElse: () => [],
      ),
    );
  }

  void _showFormDialog(BuildContext context, WidgetRef ref, {CodigoPostal? cp}) {
    final isEditing = cp != null;
    final nameCtrl = TextEditingController(text: cp?.name);
    int? selectedLocalidadId = cp?.localidadId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar C.P.' : 'Nuevo C.P.'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Código Postal')),
            const SizedBox(height: 15),
            ref.watch(localidadesProvider).whenData((list) => DropdownButtonFormField<int>(
              value: selectedLocalidadId,
              decoration: const InputDecoration(labelText: 'Localidad'),
              items: list.map((l) => DropdownMenuItem(value: l.id, child: Text(l.nombreLocalidad))).toList(),
              onChanged: (val) => selectedLocalidadId = val,
            )).value ?? const SizedBox(),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || selectedLocalidadId == null) return;
              if (isEditing) {
                await ref.read(codigosPostalesProvider.notifier).editarCodigoPostal(cp.id, nameCtrl.text, selectedLocalidadId!);
              } else {
                await ref.read(codigosPostalesProvider.notifier).agregarCodigoPostal(nameCtrl.text, selectedLocalidadId!);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, CodigoPostal cp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar?'),
        content: Text('¿Desea eliminar el código postal ${cp.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
          TextButton(
            onPressed: () async {
              await ref.read(codigosPostalesProvider.notifier).borrarCodigoPostal(cp.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}