import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';
import 'package:morenitapp/shared/widgets/disenio_informes.dart';

// --- PLANTILLA DEL CONTENEDOR DE FILTROS ---
class FiltroContenedorTemplate extends StatelessWidget {
  final Widget child;
  final String label;

  const FiltroContenedorTemplate(
      {super.key, required this.child, this.label = "Filtros Avanzados"});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 3, color: primaryColor),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 12, right: 16),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt_outlined,
                        size: 18, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- PANTALLA PRINCIPAL ---
class HermanoActivoListadoScreen extends ConsumerWidget {
  const HermanoActivoListadoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hermanosAsync = ref.watch(hermanosActivosFiltradosProvider);
    final primaryColor = Theme.of(context).primaryColor;

    List<List<String>> prepararDatos(List<Hermano> lista) {
      return lista
          .map((h) => [
                (h.codigoHermano ?? 'S/N').toString(),
                h.nombre,
                '${h.apellido1} ${h.apellido2 ?? ''}',
                h.dni ?? '-',
                h.email ?? '-',
                h.fechaAlta ?? '-',
              ])
          .toList();
    }

    return PlantillaVentanas(
      title: 'Listado de Hermanos Activos',
      isLoading: hermanosAsync.isLoading,
      onDownloadExcel: () async {
        final lista = hermanosAsync.value ?? [];
        if (lista.isEmpty) return;
        ExcelService.descargarExcel(
          nombreArchivo: 'Hermanos_Activos',
          cabeceras: [
            'Nº',
            'Nombre',
            'Apellidos',
            'DNI',
            'Email',
            'Fecha Alta'
          ],
          filas: prepararDatos(lista),
        );
      },
      onDownloadPDF: () async {
        final lista = hermanosAsync.value ?? [];
        if (lista.isEmpty) return;

        Uint8List? logoBytes;
        try {
          final byteData = await rootBundle.load('assets/icono.png');
          logoBytes = byteData.buffer.asUint8List();
        } catch (e) {
          debugPrint('Aviso: No se pudo cargar el logo: $e');
        }

        await ReporteGenerator.generarPDFInformativo(
          titulo: "LISTADO DE HERMANOS\nACTIVOS",
          headers: ['Nº', 'Nombre', 'Apellidos', 'DNI', 'Fecha Alta'],
          data: prepararDatos(lista),
          logoBytes: logoBytes,
        );
      },
      filtrosAdicionales: FiltroContenedorTemplate(
        label: "Búsqueda y Segmentación",
        child: AdvancedFilterBar(
          fields: const [
            {'id': 'nombre', 'name': 'Nombre', 'type': 'string'},
            {'id': 'apellido1', 'name': 'Primer Apellido', 'type': 'string'},
            {'id': 'dni', 'name': 'DNI', 'type': 'string'},
            {'id': 'codigo_hermano', 'name': 'Nº Hermano', 'type': 'number'},
            {'id': 'fecha_alta', 'name': 'Fecha de Alta', 'type': 'date'},
          ],
          onFiltersChanged: (nuevosFiltros) {
            ref
                .read(hermanosFiltersProvider.notifier)
                .setAdvancedFilters(nuevosFiltros);
          },
        ),
      ),
      onSearch: (val) =>
          ref.read(hermanosFiltersProvider.notifier).setQuery(val),
      onRefresh: () => ref.refresh(hermanosListadoProvider),
      onNuevo: () => context.push('/nuevo-hermano'),
      paginationText: hermanosAsync.when(
        data: (lista) => 'Total activos: ${lista.length}',
        error: (_, __) => 'Error al cargar',
        loading: () => 'Cargando...',
      ),
      columns: [
        DataColumn(
            label: Text('Nº',
                style: TextStyle(
                    color: primaryColor, fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('NOMBRE COMPLETO',
                style: TextStyle(
                    color: primaryColor, fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('DNI',
                style: TextStyle(
                    color: primaryColor, fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('FECHA ALTA',
                style: TextStyle(
                    color: primaryColor, fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('ACCIONES',
                style: TextStyle(
                    color: primaryColor, fontWeight: FontWeight.bold))),
      ],
      rows: hermanosAsync.when(
        data: (hermanos) => hermanos
            .map((h) => DataRow(
                  cells: [
                    DataCell(Text(h.codigoHermano ?? 'S/N',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('${h.nombre} ${h.apellido1}')),
                    DataCell(Text(h.dni ?? '-')),
                    DataCell(Text(h.fechaAlta ?? '-')),
                    DataCell(Row(
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.blue, size: 20),
                          onPressed: () =>
                              context.push('/nuevo-hermano', extra: h),
                        ),
                        IconButton(
                          tooltip: 'Dar de Baja',
                          icon: const Icon(Icons.person_off_outlined,
                              color: Colors.orange, size: 20),
                          onPressed: () => _confirmarBaja(context, ref, h),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          onPressed: () =>
                              _confirmarEliminacion(context, ref, h),
                        ),
                      ],
                    )),
                  ],
                ))
            .toList(),
        error: (err, _) => [],
        loading: () => [],
      ),
    );
  }

  // --- LÓGICA DE DIÁLOGOS CON COLOR CORREGIDO ---
  void _confirmarBaja(BuildContext context, WidgetRef ref, Hermano h) {
    final motivoController = TextEditingController();
    final fechaController = TextEditingController(
        text: DateTime.now().toIso8601String().split('T')[0]);
    final primaryColor = Theme.of(context).primaryColor;

    showDialog(
      context: context,
      builder: (ctx) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor, primary: primaryColor),
        ),
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Dar de baja a ${h.nombre}',
              style:
                  TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fechaController,
                decoration: const InputDecoration(
                    labelText: 'Fecha de Baja',
                    prefixIcon: Icon(Icons.calendar_today)),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: motivoController,
                decoration: const InputDecoration(
                    labelText: 'Motivo de la baja',
                    prefixIcon: Icon(Icons.info_outline)),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCELAR')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () async {
                if (motivoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Por favor, indica un motivo')));
                  return;
                }

                final datosBaja = {
                  "estado": "baja",
                  "fecha_baja": fechaController.text,
                  "motivo_baja": motivoController.text,
                };

                try {
                  // 1. Enviamos la actualización al servidor
                  await ref
                      .read(hermanosListadoProvider.notifier)
                      .updateHermano(h.id!, datosBaja);

                  // SOLUCIÓN: Limpiamos la caché de los proveedores
                  ref.invalidate(hermanosListadoProvider);
                  ref.invalidate(hermanosActivosFiltradosProvider);

                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Baja tramitada correctamente'),
                        backgroundColor: Colors.green));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Error al dar de baja: $e'),
                        backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text('CONFIRMAR BAJA',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, WidgetRef ref, Hermano h) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: Text('Esta acción borrará a ${h.nombre} permanentemente.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCELAR')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await ref
                    .read(hermanosListadoProvider.notifier)
                    .eliminarHermano(h.id!);
                if (context.mounted) Navigator.pop(ctx);
              },
              child: const Text('ELIMINAR',
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
