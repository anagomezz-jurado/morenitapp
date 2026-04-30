import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';
import 'package:morenitapp/shared/widgets/disenio_informes.dart'; 

class HermanoNoActivoListadoScreen extends ConsumerWidget {
  const HermanoNoActivoListadoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hermanosAsync = ref.watch(hermanosListadoProvider);
    final primaryColor = Theme.of(context).primaryColor;

    List<List<String>> prepararDatosExportacion(List<Hermano> listaCompleta) {
      final query = ref.read(hermanosFiltersProvider).query.toLowerCase();
      
      return listaCompleta
          .where((h) => h.estado == 'baja')
          .where((h) {
            final matchName = '${h.nombre} ${h.apellido1} ${h.apellido2}'.toLowerCase().contains(query);
            final matchDni = (h.dni ?? '').toLowerCase().contains(query);
            return matchName || matchDni;
          })
          .map((h) => [
                (h.codigoHermano ?? h.numeroHermano.toString()),
                '${h.nombre} ${h.apellido1} ${h.apellido2 ?? ''}',
                h.dni ?? '-',
                h.fechaBaja ?? '-',
                h.motivoBaja ?? '-',
              ])
          .toList();
    }

    return PlantillaVentanas(
      title: 'Hermanos de Baja',
      isLoading: hermanosAsync.isLoading,
      
      // --- EXPORTAR EXCEL ---
      onDownloadExcel: () async {
        final lista = hermanosAsync.value ?? [];
        final filas = prepararDatosExportacion(lista);
        
        if (filas.isEmpty) return;

        ExcelService.descargarExcel(
          nombreArchivo: 'Reporte_Bajas_Hermanos',
          cabeceras: ['Nº', 'Nombre Completo', 'DNI', 'Fecha Baja', 'Motivo'],
          filas: filas,
        );
      },

      // --- EXPORTAR PDF ---
      onDownloadPDF: () async {
        final lista = hermanosAsync.value ?? [];
        final filas = prepararDatosExportacion(lista);
        
        if (filas.isEmpty) return;

        Uint8List? logoBytes;
        try {
          final byteData = await rootBundle.load('assets/icono.png');
          logoBytes = byteData.buffer.asUint8List();
        } catch (e) {
          debugPrint('Aviso: No se pudo cargar el logo para el PDF');
        }

        await ReporteGenerator.generarPDFInformativo(
          titulo: "REPORTE DE HERMANOS\nEN ESTADO DE BAJA",
          headers: ['Nº', 'Nombre Completo', 'DNI', 'Fecha Baja', 'Motivo'],
          data: filas,
          logoBytes: logoBytes,
        );
      },
      
      onRefresh: () => ref.refresh(hermanosListadoProvider),
      onSearch: (val) => ref.read(hermanosFiltersProvider.notifier).setQuery(val),
      
      paginationText: hermanosAsync.when(
        data: (h) => 'Total bajas: ${h.where((x) => x.estado == 'baja').length}',
        error: (_, __) => 'Error al cargar',
        loading: () => 'Cargando...',
      ),
      
      columns: [
        DataColumn(label: Text('Nº', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
        DataColumn(label: Text('NOMBRE COMPLETO', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
        DataColumn(label: Text('FECHA BAJA', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
        DataColumn(label: Text('MOTIVO', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
      ],
      
      rows: hermanosAsync.when(
        data: (hermanos) {
          final query = ref.watch(hermanosFiltersProvider).query.toLowerCase();
          
          return hermanos
            .where((h) => h.estado == 'baja')
            .where((h) {
              final matchName = '${h.nombre} ${h.apellido1} ${h.apellido2}'.toLowerCase().contains(query);
              final matchDni = (h.dni ?? '').toLowerCase().contains(query);
              return matchName || matchDni;
            })
            .map((h) => DataRow(cells: [
                  DataCell(Text(h.codigoHermano ?? h.numeroHermano.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('${h.nombre} ${h.apellido1}')),
                  DataCell(Text(h.fechaBaja ?? '-')),
                  DataCell(SizedBox(
                    width: 200, 
                    child: Text(h.motivoBaja ?? '-', overflow: TextOverflow.ellipsis)
                  )),
                  DataCell(Row(
                    children: [
                      IconButton(
                        tooltip: 'Ver/Editar Ficha',
                        icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey, size: 20),
                        onPressed: () => context.push('/nuevo-hermano', extra: h),
                      ),
                      IconButton(
                        tooltip: 'Reactivar Alta',
                        icon: const Icon(Icons.settings_backup_restore, color: Colors.green, size: 20),
                        onPressed: () => _confirmarReactivacion(context, ref, h),
                      ),
                    ],
                  )),
                ]))
            .toList();
        },
        error: (err, _) => [],
        loading: () => [],
      ),
    );
  }

  void _confirmarReactivacion(BuildContext context, WidgetRef ref, Hermano h) {
    final primaryColor = Theme.of(context).primaryColor;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.person_add, color: Colors.green),
            const SizedBox(width: 10),
            const Text('Reactivar Hermano'),
          ],
        ),
        content: Text('¿Deseas dar de alta nuevamente a ${h.nombre} ${h.apellido1}?\n\nEsto lo moverá de nuevo a la lista de activos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            onPressed: () async {
              final datos = { "estado": "activo" };

              try {
                await ref.read(hermanosListadoProvider.notifier).updateHermano(h.id!, datos);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${h.nombre} reactivado correctamente'),
                      backgroundColor: Colors.green,
                    )
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
                  );
                }
              }
            },
            child: const Text('SÍ, REACTIVAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}