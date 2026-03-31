import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/codigo_postal.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';

class CodigoPostalScreen extends ConsumerWidget {
  const CodigoPostalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el provider base (sin filtros externos)
    final cpAsync = ref.watch(codigosPostalesProvider);
    final localidadesAsync = ref.watch(localidadesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF714B67),
        elevation: 0,
        title: const Text('Gestión de Códigos Postales',
            style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF875A7B),
                foregroundColor: Colors.white,
              ),
              onPressed: () => _showFormDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('NUEVO'),
            ),
          ),
        ],
      ),
      body: cpAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Center(child: Text('Error al cargar CPs: $err')),
        data: (codigos) {
          if (codigos.isEmpty) {
            return const Center(
                child: Text('No hay códigos postales registrados.'));
          }
          return _buildTable(context, ref, codigos, localidadesAsync);
        },
      ),
    );
  }

  Widget _buildTable(BuildContext context, WidgetRef ref,
      List<CodigoPostal> codigos, AsyncValue localidadesAsync) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
          columns: const [
            DataColumn(
                label: Text('Código Postal',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Localidad Asignada',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Acciones',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: codigos.map((cp) {
            // Buscamos el nombre de la localidad por ID
            final nombreLocalidad = localidadesAsync.maybeWhen(
              data: (list) {
                final loc = list
                    .where((l) => l.id.toString() == cp.localidadId.toString());
                return loc.isNotEmpty
                    ? loc.first.nombreLocalidad
                    : 'ID: ${cp.localidadId} (No encontrada)';
              },
              orElse: () => 'Cargando...',
            );

            return DataRow(cells: [
              DataCell(Text(cp.name,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
              DataCell(Text(nombreLocalidad)),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showFormDialog(context, ref, cp: cp),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () => _confirmDelete(context, ref, cp),
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  void _showFormDialog(BuildContext context, WidgetRef ref,
      {CodigoPostal? cp}) {
    final isEditing = cp != null;
    final nameCtrl = TextEditingController(text: cp?.name);
    int? selectedLocalidadId = cp?.localidadId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Registro' : 'Nuevo Registro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'CP (Número)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            ref.watch(localidadesProvider).when(
                  data: (list) => DropdownButtonFormField<int>(
                    value: list.any((l) => l.id == selectedLocalidadId)
                        ? selectedLocalidadId
                        : null,
                    items: list
                        .map((l) => DropdownMenuItem(
                            value: l.id, child: Text(l.nombreLocalidad)))
                        .toList(),
                    onChanged: (val) => selectedLocalidadId = val,
                    decoration: const InputDecoration(
                        labelText: 'Seleccionar Localidad',
                        border: OutlineInputBorder()),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error al cargar localidades'),
                ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF714B67)),
            onPressed: () async {
              if (nameCtrl.text.isEmpty || selectedLocalidadId == null) return;
              try {
                if (isEditing) {
                  await ref
                      .read(codigosPostalesProvider.notifier)
                      .editarCodigoPostal(
                          cp.id, nameCtrl.text.trim(), selectedLocalidadId!);
                } else {
                  await ref
                      .read(codigosPostalesProvider.notifier)
                      .agregarCodigoPostal(
                          nameCtrl.text.trim(), selectedLocalidadId!);
                }
                ref.invalidate(codigosPostalesProvider);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('GUARDAR', style: TextStyle(color: Colors.white)),
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
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              await ref
                  .read(codigosPostalesProvider.notifier)
                  .borrarCodigoPostal(cp.id);
              ref.invalidate(codigosPostalesProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
