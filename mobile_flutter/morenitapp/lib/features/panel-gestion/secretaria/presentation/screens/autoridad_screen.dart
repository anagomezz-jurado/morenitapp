import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/disenio_informes.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';
import '../../domain/entities/autoridad.dart';
import '../providers/secretaria_provider.dart';

class AutoridadesScreen extends ConsumerWidget {
  const AutoridadesScreen({super.key});

  List<List<String>> prepararDatos(List<Autoridad> lista) {
    return lista.map((a) {
      return [
        a.codAutoridad,
        a.nombreAutoridad,
        a.nombreSaluda,
        a.cargo,
        a.tipoautoridadName,
        "${a.calleNombre} ${a.numero}".trim(),
        a.piso,
        a.puerta,
        a.bloque,
        a.escalera,
        a.portal,
        a.telefono,
        a.email,
        a.observaciones,
      ];
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoridadesAsync = ref.watch(autoridadesProvider);

    return PlantillaVentanas(
      title: 'Gestión de Autoridades',
      isLoading: autoridadesAsync.isLoading,
      onDownloadExcel: () async {
        final lista = autoridadesAsync.value ?? [];
        if (lista.isEmpty) return;

        ExcelService.descargarExcel(
          nombreArchivo: 'Autoridades',
          cabeceras: [
            'Código',
            'Nombre',
            'Saluda',
            'Cargo',
            'Tipo',
            'Calle',
            'Piso',
            'Puerta',
            'Bloque',
            'Escalera',
            'Portal',
            'Teléfono',
            'Email',
            'Observaciones'
          ],
          filas: prepararDatos(lista),
        );
      },
      onDownloadPDF: () async {
        final lista = autoridadesAsync.value ?? [];
        if (lista.isEmpty) return;

        Uint8List? logo;
        try {
          final data = await rootBundle.load('assets/icono.png');
          logo = data.buffer.asUint8List();
        } catch (_) {}

        await ReporteGenerator.generarPDFInformativo(
          titulo: "LISTADO COMPLETO DE AUTORIDADES",
          headers: [
            'Código',
            'Nombre',
            'Saluda',
            'Cargo',
            'Tipo',
            'Calle',
            'Piso',
            'Puerta',
            'Bloque',
            'Escalera',
            'Portal',
            'Teléfono',
            'Email',
            'Obs'
          ],
          data: prepararDatos(lista),
          logoBytes: logo,
        );
      },
      onRefresh: () => ref.read(autoridadesProvider.notifier).refresh(),
      onNuevo: () => context.push('/secretaria/autoridades/nueva'),
      columns: const [
        DataColumn(label: Text('CÓDIGO')),
        DataColumn(label: Text('NOMBRE')),
        DataColumn(label: Text('TIPO')),
        DataColumn(label: Text('CARGO')),
        DataColumn(label: Text('CONTACTO')),
        DataColumn(label: Text('DIRECCIÓN')),
        DataColumn(label: Text('ACCIONES')),
      ],
      rows: autoridadesAsync.maybeWhen(
        data: (list) => list.map((a) {
          return DataRow(cells: [
            DataCell(Text(a.codAutoridad)),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.nombreAutoridad,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (a.nombreSaluda.isNotEmpty)
                    Text(a.nombreSaluda,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700)),
                ],
              ),
            ),
            DataCell(Text(a.tipoautoridadName)),
            DataCell(Text(a.cargo)),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (a.telefono.isNotEmpty) Text("Tel: ${a.telefono}"),
                  if (a.email.isNotEmpty) Text(a.email),
                ],
              ),
            ),
            DataCell(
              Text(
                  "${a.calleNombre} ${a.numero}, P${a.piso} Puerta ${a.puerta}"),
            ),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () => context.push(
                    '/secretaria/autoridades/editar',
                    extra: a,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmarEliminar(context, ref, a),
                ),
              ],
            )),
          ]);
        }).toList(),
        orElse: () => [],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Autoridad a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Autoridad'),
        content: Text('¿Desea eliminar a "${a.nombreAutoridad}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              ref.read(autoridadesProvider.notifier).eliminar(int.parse(a.id));
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
