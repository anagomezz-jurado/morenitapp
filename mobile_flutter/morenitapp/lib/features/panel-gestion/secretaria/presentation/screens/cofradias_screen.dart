import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/disenio_informes.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';
import '../../domain/entities/cofradia.dart';
import '../providers/secretaria_provider.dart';

class CofradiasScreen extends ConsumerWidget {
  const CofradiasScreen({super.key});

  List<String> preparar(Cofradia c) {
    return [
      c.cif,
      c.nombre,
      c.fundacion.toString(),
      "${c.calleNombre} ${c.numero}",
      c.telefono,
      c.email,
      c.web,
      c.observaciones
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(cofradiasProvider);

    return PlantillaVentanas(
      title: 'Gestión de Cofradías',
      isLoading: async.isLoading,
      onDownloadExcel: () async {
        final list = async.value ?? [];
        if (list.isEmpty) return;

        ExcelService.descargarExcel(
          nombreArchivo: 'Cofradias',
          cabeceras: [
            'CIF',
            'Nombre',
            'Fundación',
            'Calle',
            'Teléfono',
            'Email',
            'Web',
            'Observaciones'
          ],
          filas: list.map(preparar).toList(),
        );
      },
      onDownloadPDF: () async {
        final list = async.value ?? [];
        if (list.isEmpty) return;

        Uint8List? logo;
        try {
          final data = await rootBundle.load('assets/icono.png');
          logo = data.buffer.asUint8List();
        } catch (_) {}

        await ReporteGenerator.generarPDFInformativo(
          titulo: "LISTADO COMPLETO DE COFRADÍAS",
          headers: [
            'CIF',
            'Nombre',
            'Fundación',
            'Calle',
            'Teléfono',
            'Email',
            'Web',
            'Obs'
          ],
          data: list.map(preparar).toList(),
          logoBytes: logo,
        );
      },
      onRefresh: () => ref.read(cofradiasProvider.notifier).refresh(),
      onNuevo: () => context.push('/secretaria/cofradias/nueva'),
      columns: const [
        DataColumn(label: Text('CIF')),
        DataColumn(label: Text('NOMBRE')),
        DataColumn(label: Text('FUNDACIÓN')),
        DataColumn(label: Text('DIRECCIÓN')),
        DataColumn(label: Text('CONTACTO')),
        DataColumn(label: Text('ACCIONES')),
      ],
      rows: async.maybeWhen(
        data: (list) => list.map((c) {
          return DataRow(cells: [
            DataCell(Text(c.cif)),
            DataCell(Text(c.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(c.fundacion.toString())),
            DataCell(Text("${c.calleNombre} ${c.numero}")),
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.telefono.isNotEmpty) Text("Tel: ${c.telefono}"),
                if (c.email.isNotEmpty) Text(c.email),
                if (c.web.isNotEmpty) Text(c.web),
              ],
            )),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () =>
                      context.push('/secretaria/cofradias/editar', extra: c),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _delete(context, ref, c),
                ),
              ],
            )),
          ]);
        }).toList(),
        orElse: () => [],
      ),
    );
  }

  void _delete(BuildContext context, WidgetRef ref, Cofradia c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Cofradía'),
        content: Text('¿Eliminar "${c.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR')),
          FilledButton(
            onPressed: () {
              ref.read(cofradiasProvider.notifier).eliminar(int.parse(c.id));
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}
