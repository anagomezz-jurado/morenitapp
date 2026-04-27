import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Asegúrate de tener go_router para la navegación
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';
import 'package:morenitapp/shared/widgets/disenio_informes.dart';
import '../../domain/entities/organizador.dart';
// Importa tu nueva pantalla de formulario aquí
// import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/screens/nuevo_organizador_screen.dart';

class OrganizadoresScreen extends ConsumerWidget {
  const OrganizadoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizadoresAsync = ref.watch(organizadoresProvider);

    // Función para exportación
    List<List<String>> prepararDatos(List<Organizador> lista) {
      return lista.map((o) => [
        o.cif,
        o.nombre,
        o.telefono ?? '-',
        o.email ?? '-',
        '${o.piso ?? ''} ${o.puerta ?? ''}'.trim()
      ]).toList();
    }

    return PlantillaVentanas(
      title: 'Directorio de Organizadores',

      // --- EXPORTACIÓN EXCEL ---
      onDownloadExcel: () async {
        final lista = organizadoresAsync.value ?? [];
        if (lista.isEmpty) return;
        ExcelService.descargarExcel(
          nombreArchivo: 'Organizadores_MorenitApp',
          cabeceras: ['CIF', 'Nombre', 'Teléfono', 'Email', 'Dirección'],
          filas: prepararDatos(lista),
        );
      },

      // --- EXPORTACIÓN PDF ---
      onDownloadPDF: () async {
        final lista = organizadoresAsync.value ?? [];
        if (lista.isEmpty) return;

        Uint8List? logoBytes;
        try {
          final byteData = await rootBundle.load('assets/icono.png');
          logoBytes = byteData.buffer.asUint8List();
        } catch (e) {
          debugPrint('Aviso: No se pudo cargar el logo: $e');
        }

        await ReporteGenerator.generarPDFInformativo(
          titulo: "DIRECTORIO DE ORGANIZADORES\nY ENTIDADES 2026",
          headers: ['CIF', 'Nombre', 'Teléfono', 'Email', 'Dirección'],
          data: prepararDatos(lista),
          logoBytes: logoBytes,
        );
      },

      isLoading: organizadoresAsync.isLoading,
      onRefresh: () => ref.refresh(organizadoresProvider),
      
      // CAMBIO: Ahora navega a la pantalla de formulario completo
      onNuevo: () => context.push('/panel-gestion/eventos-cultos/organizadores/nuevo'),

      onSearch: (val) {
        // Implementar lógica de filtrado si el notifier lo permite
      },

      paginationText: organizadoresAsync.when(
        data: (lista) => 'Total registros: ${lista.length}',
        error: (_, __) => 'Error al cargar datos',
        loading: () => 'Cargando...',
      ),

      columns: const [
        DataColumn(label: Text('CIF')),
        DataColumn(label: Text('NOMBRE / ENTIDAD')),
        DataColumn(label: Text('CONTACTO')),
        DataColumn(label: Text('UBICACIÓN')),
        DataColumn(label: Text('ACCIONES')),
      ],

      rows: organizadoresAsync.when(
        data: (organizadores) => organizadores.map((o) => DataRow(cells: [
          DataCell(Text(o.cif)),
          DataCell(Text(o.nombre, style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(o.telefono ?? '-', style: const TextStyle(fontSize: 12)),
              Text(o.email ?? '-', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          )),
          // Mejorado el display de la dirección
          DataCell(Text(
            '${o.piso ?? ''} ${o.puerta ?? ''}'.trim().isEmpty ? 'Pral.' : '${o.piso} ${o.puerta}',
            style: const TextStyle(fontSize: 12),
          )),
          DataCell(Row(
            children: [
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                // CAMBIO: Navega pasando el objeto organizador
                onPressed: () => context.push('/panel-gestion/eventos-cultos/organizadores/editar', extra: o),
              ),
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
                onPressed: () => _confirmarEliminacion(context, ref, o),
              ),
            ],
          )),
        ])).toList(),
        error: (err, _) => [],
        loading: () => [],
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, WidgetRef ref, Organizador o) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: Text('Esta acción borrará a "${o.nombre}" permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(organizadoresProvider.notifier).eliminar(o.id);
              if (context.mounted) Navigator.pop(ctx);
              // Opcional: mostrar snackbar de éxito
            }, 
            child: const Text('ELIMINAR')
          ),
        ],
      ),
    );
  }
}