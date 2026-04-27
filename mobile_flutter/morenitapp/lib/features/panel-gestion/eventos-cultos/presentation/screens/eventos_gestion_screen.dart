import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/evento.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';
import 'package:morenitapp/shared/widgets/disenio_informes.dart';
// Asegúrate de importar la entidad que acabamos de corregir

class EventosGestionScreen extends ConsumerWidget {
  const EventosGestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(eventosProvider);

    // Función de exportación corregida con los campos del modelo
    List<List<String>> prepararDatos(List<Evento> lista) {
      return lista.map((e) => [
        DateFormat('dd/MM/yyyy HH:mm').format(e.fechaInicio),
        e.nombre,
        e.tipoNombre,
        e.lugar ?? '-',
        e.organizadorNombre ?? 'Propio'
      ]).toList();
    }

    return PlantillaVentanas(
      title: 'Agenda de Eventos y Cultos',

      onDownloadExcel: () async {
        final lista = eventosAsync.value ?? [];
        if (lista.isEmpty) return;
        ExcelService.descargarExcel(
          nombreArchivo: 'Eventos_MorenitApp',
          cabeceras: ['Fecha', 'Evento', 'Tipo', 'Lugar', 'Organizador'],
          filas: prepararDatos(lista),
        );
      },

      onDownloadPDF: () async {
        final lista = eventosAsync.value ?? [];
        if (lista.isEmpty) return;

        Uint8List? logoBytes;
        try {
          final byteData = await rootBundle.load('assets/icono.png');
          logoBytes = byteData.buffer.asUint8List();
        } catch (e) {
          debugPrint('Aviso: No se pudo cargar el logo: $e');
        }

        await ReporteGenerator.generarPDFInformativo(
          titulo: "CALENDARIO DE EVENTOS Y CULTOS\nREAL COFRADÍA 2026",
          headers: ['Fecha', 'Evento', 'Tipo', 'Lugar', 'Organizador'],
          data: prepararDatos(lista),
          logoBytes: logoBytes,
        );
      },

      isLoading: eventosAsync.isLoading,
      onRefresh: () => ref.refresh(eventosProvider),
      onNuevo: () => context.push('/panel-gestion/eventos-cultos/eventos/nuevo'),

      paginationText: eventosAsync.when(
        data: (lista) => 'Total eventos: ${lista.length}',
        error: (_, __) => 'Error al cargar agenda',
        loading: () => 'Cargando...',
      ),

      columns: const [
        DataColumn(label: Text('FECHA / HORA')),
        DataColumn(label: Text('EVENTO / CULTO')),
        DataColumn(label: Text('LUGAR')),
        DataColumn(label: Text('TIPO')),
        DataColumn(label: Text('ACCIONES')),
      ],

      rows: eventosAsync.when(
  data: (eventos) => eventos.map((e) => DataRow(cells: [
    DataCell(Text(DateFormat('dd/MM HH:mm').format(e.fechaInicio))),
    DataCell(Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.bold))),
    DataCell(Text(e.lugar ?? 'No definido', style: const TextStyle(fontSize: 12))),
    DataCell(Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(4)
      ),
      child: Text(e.tipoNombre, style: const TextStyle(fontSize: 11)),
    )),
    DataCell(Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
          onPressed: () => context.push('/panel-gestion/eventos-cultos/eventos/editar', extra: e),
        ),
        IconButton(
          icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
          onPressed: () => _confirmarEliminacion(context, ref, e),
        ),
      ],
    )),
  ])).toList(),
  // CAMBIO AQUÍ: Muestra el error en la tabla para saber qué falla
  error: (err, stack) => [
    DataRow(cells: [
      DataCell(Text('ERROR', style: TextStyle(color: Colors.red))),
      DataCell(Text(err.toString())), 
      DataCell(const SizedBox()),
      DataCell(const SizedBox()),
      DataCell(const SizedBox()),
    ])
  ],
  // CAMBIO AQUÍ: Muestra algo mientras carga
  loading: () => [
    const DataRow(cells: [
      DataCell(CircularProgressIndicator()),
      DataCell(Text('Cargando eventos...')),
      DataCell(SizedBox()),
      DataCell(SizedBox()),
      DataCell(SizedBox()),
    ])
  ],
),
    );
  }

  void _confirmarEliminacion(BuildContext context, WidgetRef ref, Evento e) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar evento?'),
        content: Text('¿Seguro que desea eliminar "${e.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(eventosProvider.notifier).eliminar(e.id);
              if (context.mounted) Navigator.pop(ctx);
            }, 
            child: const Text('ELIMINAR')
          ),
        ],
      ),
    );
  }
}