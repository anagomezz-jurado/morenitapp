import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_autoridad.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/disenio_informes.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class TipoAutoridadScreen extends ConsumerWidget {
  const TipoAutoridadScreen({super.key});
  List<List<String>> prepararDatos(List<TipoAutoridad> lista) {
      return lista
          .map((h) => [
                (h.codigo ?? 'S/N').toString(),
                h.nombre,
              ])
          .toList();
    }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoridadesAsync = ref.watch(tiposAutoridadProvider);

    return PlantillaVentanas(
      title: 'Tipos de Autoridad',
      isLoading: autoridadesAsync.isLoading,
      onDownloadExcel: () async {
        final lista = autoridadesAsync.value ?? [];
        if (lista.isEmpty) return;
        ExcelService.descargarExcel(
          nombreArchivo: 'Tipos_Autoridad',
          cabeceras: [
            'Código',
            'Nombre',
          ],
          filas: prepararDatos(lista),
        );
      },
      onDownloadPDF: () async {
        final lista = autoridadesAsync.value ?? [];
        if (lista.isEmpty) return;

        Uint8List? logoBytes;
        try {
          final byteData = await rootBundle.load('assets/icono.png');
          logoBytes = byteData.buffer.asUint8List();
        } catch (e) {
          debugPrint('Aviso: No se pudo cargar el logo: $e');
        }

        await ReporteGenerator.generarPDFInformativo(
          titulo: "LISTADO DE TIPOS DE AUTORIDAD",
          headers: ['Código', 'Nombre'],
          data: prepararDatos(lista),
          logoBytes: logoBytes,
        );
      },
      
      onRefresh: () => ref.refresh(tiposAutoridadProvider),
      onNuevo: () => _showSideForm(context, ref),
      columns: const [
        DataColumn(label: Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('NOMBRE', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: autoridadesAsync.when(
        data: (lista) => lista.map((a) => DataRow(cells: [
          DataCell(Text(a.codigo)),
          DataCell(Text(a.nombre, style: const TextStyle(fontWeight: FontWeight.w500))),
          DataCell(_buildActionButtons(context, 
            onEdit: () => _showSideForm(context, ref, autoridad: a),
            onDelete: () => ref.read(tiposAutoridadProvider.notifier).eliminar(a.id!),
          )),
        ])).toList(),
        error: (_, __) => [],
        loading: () => [],
      ),
    );
  }

  // Se repite la misma lógica de _showSideForm y _buildActionButtons del archivo anterior
  void _showSideForm(BuildContext context, WidgetRef ref, {dynamic autoridad}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: double.infinity,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30))),
            child: Material(child: _AutoridadFormContent(autoridad: autoridad)),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(anim1), child: child);
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, {required VoidCallback onEdit, required VoidCallback onDelete}) {
    final colors = Theme.of(context).colorScheme;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(icon: Icon(Icons.edit_note, color: colors.primary), onPressed: onEdit),
      IconButton(icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent), onPressed: onDelete),
    ]);
  }
}

class _AutoridadFormContent extends ConsumerStatefulWidget {
  final dynamic autoridad;
  const _AutoridadFormContent({this.autoridad});
  @override
  ConsumerState<_AutoridadFormContent> createState() => _AutoridadFormContentState();
}

class _AutoridadFormContentState extends ConsumerState<_AutoridadFormContent> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController codCtrl;
  late TextEditingController nomCtrl;

  @override
  void initState() {
    super.initState();
    codCtrl = TextEditingController(text: widget.autoridad?.codigo ?? '');
    nomCtrl = TextEditingController(text: widget.autoridad?.nombre ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(children: [
      _buildHeader(context, colors, widget.autoridad == null),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(32), child: Form(key: formKey, child: Column(children: [
        _buildField("CÓDIGO", codCtrl, "Ej: AUT-01", colors),
        const SizedBox(height: 25),
        _buildField("NOMBRE", nomCtrl, "Nombre de autoridad", colors),
        const SizedBox(height: 50),
        _buildSaveButton(colors),
      ]))))
    ]);
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors, bool isNew) {
    return Container(padding: const EdgeInsets.fromLTRB(24, 40, 16, 20), decoration: BoxDecoration(color: colors.primary.withOpacity(0.08), borderRadius: const BorderRadius.only(topLeft: Radius.circular(30))), child: Row(children: [
      Icon(isNew ? Icons.gavel : Icons.edit_note, color: colors.primary),
      const SizedBox(width: 12),
      Text(isNew ? 'Nueva Autoridad' : 'Editar Autoridad', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary)),
      const Spacer(),
      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
    ]));
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, ColorScheme colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colors.primary)),
      const SizedBox(height: 8),
      TextFormField(controller: ctrl, decoration: InputDecoration(hintText: hint, filled: true, fillColor: colors.primary.withOpacity(0.02), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => v!.isEmpty ? 'Requerido' : null),
    ]);
  }

  Widget _buildSaveButton(ColorScheme colors) {
    return SizedBox(width: double.infinity, height: 50, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: colors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: () {
      if (!formKey.currentState!.validate()) return;
      if (widget.autoridad == null) {
        ref.read(tiposAutoridadProvider.notifier).crear(codCtrl.text, nomCtrl.text);
      } else {
        ref.read(tiposAutoridadProvider.notifier).editar(widget.autoridad.id, codCtrl.text, nomCtrl.text);
      }
      Navigator.pop(context);
    }, child: Text(widget.autoridad == null ? 'GUARDAR' : 'ACTUALIZAR', style: const TextStyle(fontWeight: FontWeight.bold))));
  }
}