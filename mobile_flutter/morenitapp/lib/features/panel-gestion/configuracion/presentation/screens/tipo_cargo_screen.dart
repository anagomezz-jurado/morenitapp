import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_cargo.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/disenio_informes.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class TipoCargoScreen extends ConsumerWidget {
  const TipoCargoScreen({super.key});

  List<List<String>> prepararDatos(List<TipoCargo> lista) {
    return lista
        .map((h) => [
              (h.codigo ?? 'S/N').toString(),
              h.nombre,
              h.observaciones ?? '-',
            ])
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cargosAsync = ref.watch(tiposCargoProvider);

    return PlantillaVentanas(
      title: 'Tipos de Cargo',
      isLoading: cargosAsync.isLoading,
      onDownloadExcel: () async {
        final lista = cargosAsync.value ?? [];
        if (lista.isEmpty) return;
        ExcelService.descargarExcel(
          nombreArchivo: 'Tipos_Cargo',
          cabeceras: ['Código', 'Nombre', 'OBSERVACIONES'],
          filas: prepararDatos(lista),
        );
      },
      onDownloadPDF: () async {
        final lista = cargosAsync.value ?? [];
        if (lista.isEmpty) return;

        Uint8List? logoBytes;
        try {
          final byteData = await rootBundle.load('assets/icono.png');
          logoBytes = byteData.buffer.asUint8List();
        } catch (e) {
          debugPrint('Aviso: No se pudo cargar el logo: $e');
        }

        await ReporteGenerator.generarPDFInformativo(
          titulo: "LISTADO DE TIPOS DE CARGO",
          headers: ['Código', 'Nombre', 'OBSERVACIONES'],
          data: prepararDatos(lista),
          logoBytes: logoBytes,
        );
      },
      onRefresh: () => ref.refresh(tiposCargoProvider),
      onNuevo: () => _showSideForm(context, ref),
      columns: const [
        DataColumn(
            label:
                Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label:
                Text('NOMBRE', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('OBSERVACIONES',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('ACCIONES',
                style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: cargosAsync.maybeWhen(
        data: (lista) => lista
            .map((c) => DataRow(cells: [
                  DataCell(Text(c.codigo)),
                  DataCell(Text(c.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(c.observaciones ?? '-',
                      overflow: TextOverflow.ellipsis)),
                  DataCell(_buildActionButtons(
                    context,
                    onEdit: () => _showSideForm(context, ref, cargo: c),
                    onDelete: () => _confirmDelete(context, ref, c),
                  )),
                ]))
            .toList(),
        orElse: () => [],
      ),
    );
  }

  void _showSideForm(BuildContext context, WidgetRef ref, {dynamic cargo}) {
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
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: Material(child: _CargoFormContent(cargo: cargo)),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(anim1),
            child: child);
      },
    );
  }

  Widget _buildActionButtons(BuildContext context,
      {required VoidCallback onEdit, required VoidCallback onDelete}) {
    final colors = Theme.of(context).colorScheme;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
        icon: Icon(Icons.edit_note, color: colors.primary, size: 26),
        onPressed: onEdit,
        tooltip: 'Editar cargo',
      ),
      IconButton(
        icon: const Icon(Icons.delete_sweep_outlined,
            color: Colors.redAccent, size: 24),
        onPressed: onDelete,
        tooltip: 'Eliminar cargo',
      ),
    ]);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic cargo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar el cargo "${cargo.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                ref.read(tiposCargoProvider.notifier).eliminar(cargo.id!);
                Navigator.pop(context);
              },
              child: const Text('ELIMINAR')),
        ],
      ),
    );
  }
}

class _CargoFormContent extends ConsumerStatefulWidget {
  final dynamic cargo;
  const _CargoFormContent({this.cargo});
  @override
  ConsumerState<_CargoFormContent> createState() => _CargoFormContentState();
}

class _CargoFormContentState extends ConsumerState<_CargoFormContent> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController codCtrl;
  late TextEditingController nomCtrl;
  late TextEditingController obsCtrl;

  @override
  void initState() {
    super.initState();
    codCtrl = TextEditingController(text: widget.cargo?.codigo ?? '');
    nomCtrl = TextEditingController(text: widget.cargo?.nombre ?? '');
    obsCtrl = TextEditingController(text: widget.cargo?.observaciones ?? '');
  }

  @override
  void dispose() {
    codCtrl.dispose();
    nomCtrl.dispose();
    obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isNew = widget.cargo == null;

    return Column(children: [
      Container(
          padding: const EdgeInsets.fromLTRB(24, 40, 16, 20),
          decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.only(topLeft: Radius.circular(30))),
          child: Row(children: [
            Icon(isNew ? Icons.work_outline : Icons.edit_note,
                color: colors.primary, size: 28),
            const SizedBox(width: 12),
            Text(isNew ? 'Nuevo Cargo' : 'Editar Cargo',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.primary)),
            const Spacer(),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)),
          ])),

      Expanded(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Form(
                  key: formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField(
                            "CÓDIGO DEL CARGO", codCtrl, "Ej: CAR-01", colors),
                        const SizedBox(height: 25),
                        _buildField("NOMBRE DEL CARGO", nomCtrl,
                            "Director, Gerente, etc.", colors),
                        const SizedBox(height: 25),
                        _buildField("OBSERVACIONES", obsCtrl,
                            "Notas adicionales sobre este cargo", colors,
                            maxLines: 4),
                        const SizedBox(height: 50),
                        _buildSaveButton(colors),
                      ]))))
    ]);
  }

  Widget _buildField(
      String label, TextEditingController ctrl, String hint, ColorScheme colors,
      {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: colors.primary,
              letterSpacing: 1.1)),
      const SizedBox(height: 8),
      TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colors.primary.withOpacity(0.02),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
          validator: (v) =>
              v!.trim().isEmpty ? 'Este campo es requerido' : null),
    ]);
  }

  Widget _buildSaveButton(ColorScheme colors) {
    return SizedBox(
        width: double.infinity,
        height: 55,
        child: FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              final notifier = ref.read(tiposCargoProvider.notifier);

              if (widget.cargo == null) {
                notifier.crear(codCtrl.text.trim(), nomCtrl.text.trim(),
                    obsCtrl.text.trim());
              } else {
                notifier.editar(widget.cargo.id, codCtrl.text.trim(),
                    nomCtrl.text.trim(), obsCtrl.text.trim());
              }

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(widget.cargo == null
                      ? 'Cargo creado'
                      : 'Cargo actualizado')));
            },
            child: Text(
                widget.cargo == null ? 'GUARDAR CARGO' : 'ACTUALIZAR CARGO',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16))));
  }
}
