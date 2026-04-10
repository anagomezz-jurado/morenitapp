import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class HermanoNoActivoListadoScreen extends ConsumerWidget {
  const HermanoNoActivoListadoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hermanosAsync = ref.watch(hermanosListadoProvider);

    return PlantillaVentanas(
      title: 'Hermanos de Baja',
      onDownload: () {
        final listaHermanos = (hermanosAsync.value ?? [])
            .where((h) => h.estado == 'baja')
            .toList();
        final filas = listaHermanos.map((h) => [
              h.numeroHermano,
              h.nombre,
              '${h.apellido1} ${h.apellido2}',
              h.dni,
              h.fechaBaja ?? '',
              h.motivoBaja ?? ''
            ]).toList();
        ExcelService.descargarExcel(
            nombreArchivo: 'Bajas',
            cabeceras: ['Nº', 'Nombre', 'Apellidos', 'DNI', 'Fecha Baja', 'Motivo'],
            filas: filas);
      },
      isLoading: hermanosAsync.isLoading,
      onRefresh: () => ref.refresh(hermanosListadoProvider),

      onSearch: (val) =>
          ref.read(hermanosFiltersProvider.notifier).setQuery(val),
      paginationText: hermanosAsync.when(
        data: (h) => 'Total bajas: ${h.where((x) => x.estado == 'baja').length}',
        error: (_, __) => '0',
        loading: () => '...',
      ),
      columns: const [
        DataColumn(label: Text('NOMBRE COMPLETO')),
        DataColumn(label: Text('FECHA BAJA')),
        DataColumn(label: Text('MOTIVO')),
        DataColumn(label: Text('ACCIONES')),
      ],
      rows: hermanosAsync.when(
        data: (hermanos) => hermanos
            .where((h) => h.estado == 'baja') // FILTRO PARA MOSTRAR SOLO BAJAS
            .map((h) => DataRow(cells: [
                  DataCell(Text('${h.nombre} ${h.apellido1}')),
                  DataCell(Text(h.fechaBaja ?? '-')),
                  DataCell(Text(h.motivoBaja ?? '-', overflow: TextOverflow.ellipsis)),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                        onPressed: () => context.push('/nuevo-hermano', extra: h),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_backup_restore, color: Colors.green, size: 20),
                        tooltip: 'Reactivar Alta',
                        onPressed: () => _confirmarReactivacion(context, ref, h),
                      ),
                    ],
                  )),
                ]))
            .toList(),
        error: (err, _) => [],
        loading: () => [],
      ),
    );
  }

  void _confirmarReactivacion(BuildContext context, WidgetRef ref, Hermano h) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reactivar Hermano'),
        content: Text('¿Deseas dar de alta nuevamente a ${h.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
          TextButton(
            onPressed: () async {
              final datos = {
                "estado": "activo",
                "fecha_baja": "false", // Importante: String "false" para que el controlador lo entienda como NULL
                "motivo_baja": ""
              };
              await ref.read(hermanosListadoProvider.notifier).updateHermano(h.id!, datos);
              ref.invalidate(hermanosListadoProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('SÍ, REACTIVAR'),
          ),
        ],
      ),
    );
  }
}