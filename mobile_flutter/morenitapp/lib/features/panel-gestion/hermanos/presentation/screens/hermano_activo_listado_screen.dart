import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class HermanoActivoListadoScreen extends ConsumerWidget {
  const HermanoActivoListadoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usamos el listado general pero filtramos por estado 'activo'
    final hermanosAsync = ref.watch(hermanosListadoProvider);

    return PlantillaVentanas(
      title: 'Listado de Hermanos Activos',
      onDownload: () {
        final listaHermanos = (hermanosAsync.value ?? [])
            .where((h) => h.estado == 'activo')
            .toList();
        final filas = listaHermanos.map((h) => [
              h.numeroHermano,
              h.nombre,
              '${h.apellido1} ${h.apellido2}',
              h.dni,
              h.email
            ]).toList();
        ExcelService.descargarExcel(
            nombreArchivo: 'Activos',
            cabeceras: ['Nº', 'Nombre', 'Apellidos', 'DNI', 'Email'],
            filas: filas);
      },
      isLoading: hermanosAsync.isLoading,
      onRefresh: () => ref.refresh(hermanosListadoProvider),
      onNuevo: () => context.push('/nuevo-hermano'),
      onSearch: (val) =>
          ref.read(hermanosFiltersProvider.notifier).setQuery(val),
      paginationText: hermanosAsync.when(
        data: (h) {
          final activos = h.where((x) => x.estado == 'activo').length;
          return 'Total activos: $activos';
        },
        error: (_, __) => '0',
        loading: () => '...',
      ),
      columns: const [
        DataColumn(label: Text('Nº de Hermano')),
        DataColumn(label: Text('NOMBRE COMPLETO')),
        DataColumn(label: Text('DNI')),
        DataColumn(label: Text('TELÉFONO')),
        DataColumn(label: Text('EMAIL')),
        DataColumn(label: Text('FECHA ALTA')),
        DataColumn(label: Text('ACCIONES')),
      ],
      rows: hermanosAsync.when(
        data: (hermanos) => hermanos
            .where((h) => h.estado == 'activo') // FILTRO PARA MOSTRAR SOLO ACTIVOS
            .map((h) => DataRow(cells: [
                  DataCell(Text(h.codigoHermano.toString())),
                  DataCell(Text('${h.nombre} ${h.apellido1}')),
                  DataCell(Text(h.dni)),
                  DataCell(Text(h.telefono)),
                  DataCell(Text(h.email)),
                  DataCell(Text(h.fechaAlta.toString())),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                        tooltip: 'Ver Ficha / Editar',
                        onPressed: () => context.push('/nuevo-hermano', extra: h),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_off, color: Colors.orange, size: 20),
                        tooltip: 'Tramitar Baja',
                        onPressed: () => context.push('/nuevo-hermano', extra: h),
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
}