import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

// (Mantenemos los imports anteriores...)

class HermanoActivoListadoScreen extends ConsumerWidget {
  const HermanoActivoListadoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hermanosAsync = ref.watch(hermanosActivosFiltradosProvider);

    return PlantillaVentanas(
      title: 'Listado de Hermanos Activos',
      onDownload: () {
        final listaHermanos = hermanosAsync.value ?? [];
        final filas = listaHermanos.map((h) => [
          h.codigoHermano.toString(),
          h.nombre,
          '${h.apellido1} ${h.apellido2}',
          h.dni,
          h.email
        ]).toList();
        ExcelService.descargarExcel(
            nombreArchivo: 'Hermanos_Activos',
            cabeceras: ['Nº', 'Nombre', 'Apellidos', 'DNI', 'Email'],
            filas: filas);
      },
      isLoading: hermanosAsync.isLoading,
      onRefresh: () => ref.refresh(hermanosListadoProvider),
      onNuevo: () => context.push('/nuevo-hermano'),
      onSearch: (val) => ref.read(hermanosFiltersProvider.notifier).setQuery(val),
      paginationText: hermanosAsync.when(
        data: (lista) => 'Total activos: ${lista.length}',
        error: (_, __) => 'Error al cargar',
        loading: () => 'Cargando...',
      ),
      columns: const [
        DataColumn(label: Text('Nº HERMANO')),
        DataColumn(label: Text('NOMBRE COMPLETO')),
        DataColumn(label: Text('DNI')),
        DataColumn(label: Text('TELÉFONO')),
        DataColumn(label: Text('ACCIONES')),
      ],
      rows: hermanosAsync.when(
        data: (hermanos) => hermanos.map((h) => DataRow(cells: [
          DataCell(Text(h.codigoHermano ?? 'S/N')),
          DataCell(Text('${h.nombre} ${h.apellido1}')),
          DataCell(Text(h.dni ?? '-')),
          DataCell(Text(h.telefono ?? '-')),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: () => context.push('/nuevo-hermano', extra: h),
              ),
              IconButton(
                icon: const Icon(Icons.person_off, color: Colors.orange, size: 20),
                onPressed: () => _confirmarBaja(context, ref, h),
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
                onPressed: () => _confirmarEliminacion(context, ref, h),
              ),
            ],
          )),
        ])).toList(),
        error: (err, _) => [],
        loading: () => [],
      ),
    );
  }

  void _confirmarBaja(BuildContext context, WidgetRef ref, Hermano h) {
    // Lógica para tramitar la baja administrativa (cambio de estado)
  }

  void _confirmarEliminacion(BuildContext context, WidgetRef ref, Hermano h) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: Text('Esta acción borrará a ${h.nombre} permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(hermanosListadoProvider.notifier).eliminarHermano(h.id!);
              if (context.mounted) Navigator.pop(ctx);
            }, 
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }
}