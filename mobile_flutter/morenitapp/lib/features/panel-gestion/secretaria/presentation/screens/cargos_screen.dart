import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/disenio_informes.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';
import '../../domain/entities/cargo.dart';
import '../providers/secretaria_provider.dart';

class CargosScreen extends ConsumerWidget {
  const CargosScreen({super.key});

  List<String> preparar(Cargo c) {
    return [
      c.codCargo,
      c.nombreCargo,
      c.tipoCargoName,
      c.fechaInicio.toString().split(" ")[0],
      c.fechaFin?.toString().split(" ")[0] ?? "",
      "${c.calleNombre} ${c.numero}",
      c.telefono,
      c.motivo,
      c.textoSaludo,
      c.observaciones,
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(cargosProvider);

    return PlantillaVentanas(
      title: 'Gestión de Cargos',
      isLoading: async.isLoading,
      onDownloadExcel: () async {
        final lista = async.value ?? [];
        if (lista.isEmpty) return;

        ExcelService.descargarExcel(
          nombreArchivo: 'Cargos',
          cabeceras: [
            'Código',
            'Nombre',
            'Tipo',
            'Inicio',
            'Fin',
            'Calle',
            'Teléfono',
            'Motivo',
            'Saludo',
            'Observaciones'
          ],
          filas: lista.map(preparar).toList(),
        );
      },
      onDownloadPDF: () async {
        final lista = async.value ?? [];
        if (lista.isEmpty) return;

        Uint8List? logo;
        try {
          final bd = await rootBundle.load('assets/icono.png');
          logo = bd.buffer.asUint8List();
        } catch (_) {}

        await ReporteGenerator.generarPDFInformativo(
          titulo: "LISTADO COMPLETO DE CARGOS",
          headers: [
            'Código',
            'Nombre',
            'Tipo',
            'Inicio',
            'Fin',
            'Calle',
            'Teléfono',
            'Motivo',
            'Saludo',
            'Obs'
          ],
          data: lista.map(preparar).toList(),
          logoBytes: logo,
        );
      },
      onRefresh: () => ref.read(cargosProvider.notifier).refresh(),
      onNuevo: () => context.push('/secretaria/cargos/nuevo'),
      columns: const [
        DataColumn(label: Text('CÓDIGO')),
        DataColumn(label: Text('NOMBRE')),
        DataColumn(label: Text('TIPO')),
        DataColumn(label: Text('FECHAS')),
        DataColumn(label: Text('DIRECCIÓN')),
        DataColumn(label: Text('CONTACTO')),
        DataColumn(label: Text('ACCIONES')),
      ],
      rows: async.maybeWhen(
        data: (list) => list.map((c) {
          return DataRow(cells: [
            DataCell(Text(c.codCargo)),
            DataCell(Text(c.nombreCargo,
                style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(c.tipoCargoName)),
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Inicio: ${c.fechaInicio.toString().split(" ")[0]}"),
                if (c.fechaFin != null)
                  Text("Fin: ${c.fechaFin!.toString().split(" ")[0]}"),
              ],
            )),
            DataCell(Text("${c.calleNombre} ${c.numero}")),
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.telefono.isNotEmpty) Text("Tel: ${c.telefono}"),
                if (c.motivo.isNotEmpty) Text("Motivo: ${c.motivo}"),
                if (c.textoSaludo.isNotEmpty) Text(c.textoSaludo),
              ],
            )),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () =>
                      context.push('/secretaria/cargos/editar', extra: c),
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

  void _delete(BuildContext context, WidgetRef ref, Cargo c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Cargo'),
        content: Text('¿Eliminar "${c.nombreCargo}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR')),
          FilledButton(
            onPressed: () {
              ref.read(cargosProvider.notifier).eliminar(int.parse(c.id));
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
