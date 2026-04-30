import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/grupo_proveedor.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/disenio_informes.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class GrupoProveedorScreen extends ConsumerWidget {
  const GrupoProveedorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gruposAsync = ref.watch(gruposProveedorProvider);
    final colors = Theme.of(context).colorScheme;

    List<List<String>> prepararDatos(List<GrupoProveedor> lista) {
      return lista
          .map((h) => [
                (h.codigo ?? 'S/N').toString(),
                h.nombre,
              ])
          .toList();
    }

    return PlantillaVentanas(
      title: 'Grupos de Proveedores',
      isLoading: gruposAsync.isLoading,
      onDownloadExcel: () async {
        final lista = gruposAsync.value ?? [];
        if (lista.isEmpty) return;
        ExcelService.descargarExcel(
          nombreArchivo: 'Grupos_Proveedores',
          cabeceras: [
            'Código',
            'Nombre',
          ],
          filas: prepararDatos(lista),
        );
      },
      onDownloadPDF: () async {
        final lista = gruposAsync.value ?? [];
        if (lista.isEmpty) return;

        Uint8List? logoBytes;
        try {
          final byteData = await rootBundle.load('assets/icono.png');
          logoBytes = byteData.buffer.asUint8List();
        } catch (e) {
          debugPrint('Aviso: No se pudo cargar el logo: $e');
        }

        await ReporteGenerator.generarPDFInformativo(
          titulo: "LISTADO DE GRUPOS DE PROVEEDORES",
          headers: ['Código', 'Nombre'],
          data: prepararDatos(lista),
          logoBytes: logoBytes,
        );
      },
      onRefresh: () => ref.refresh(gruposProveedorProvider),
      onNuevo: () => _showSideForm(context, ref),
      columns: const [
        DataColumn(
            label:
                Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('NOMBRE DEL GRUPO',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('ACCIONES',
                style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: gruposAsync.when(
        data: (grupos) => grupos
            .map((g) => DataRow(cells: [
                  DataCell(Text(g.codigo)),
                  DataCell(Text(g.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(_buildActionButtons(
                    context,
                    onEdit: () => _showSideForm(context, ref, grupo: g),
                    onDelete: () => ref
                        .read(gruposProveedorProvider.notifier)
                        .eliminar(g.id!),
                  )),
                ]))
            .toList(),
        error: (_, __) => [],
        loading: () => [],
      ),
    );
  }

  void _showSideForm(BuildContext context, WidgetRef ref,
      {GrupoProveedor? grupo}) {
    final colors = Theme.of(context).colorScheme;

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
            width:
                MediaQuery.of(context).size.width * 0.5, 
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30)),
              border: Border(
                left: BorderSide(
                    color: colors.primary.withOpacity(0.5), width: 2),
              ),
            ),
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30)),
              child: _GrupoFormContent(grupo: grupo),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(anim1),
          child: child,
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context,
      {required VoidCallback onEdit, required VoidCallback onDelete}) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            icon: Icon(Icons.edit_note, color: colors.primary, size: 24),
            onPressed: onEdit),
        IconButton(
            icon: const Icon(Icons.delete_sweep_outlined,
                color: Colors.redAccent, size: 24),
            onPressed: onDelete),
      ],
    );
  }
}

class _GrupoFormContent extends ConsumerStatefulWidget {
  final GrupoProveedor? grupo;
  const _GrupoFormContent({this.grupo});

  @override
  ConsumerState<_GrupoFormContent> createState() => _GrupoFormContentState();
}

class _GrupoFormContentState extends ConsumerState<_GrupoFormContent> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController codCtrl;
  late TextEditingController nomCtrl;

  @override
  void initState() {
    super.initState();
    codCtrl = TextEditingController(text: widget.grupo?.codigo ?? '');
    nomCtrl = TextEditingController(text: widget.grupo?.nombre ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 40, 16, 20),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.08),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30)),
          ),
          child: Row(
            children: [
              Icon(widget.grupo == null ? Icons.add_business : Icons.edit_note,
                  color: colors.primary),
              const SizedBox(width: 12),
              Text(
                widget.grupo == null ? 'Nuevo Grupo' : 'Editar Grupo',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                    fontFamily: 'Palatino'
                    ),
              ),
              const Spacer(),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField(
                      "CÓDIGO DEL GRUPO", codCtrl, "Ej: PROV-001", colors),
                  const SizedBox(height: 25),
                  _buildField("NOMBRE DEL GRUPO", nomCtrl,
                      "Nombre del sector o tipo", colors),

                  const SizedBox(height: 50),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _save,
                      child: Text(
                        widget.grupo == null
                            ? 'GUARDAR GRUPO'
                            : 'ACTUALIZAR GRUPO',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint,
      ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: colors.primary,
                letterSpacing: 1.1)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colors.primary.withOpacity(0.02),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 2)),
          ),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
      ],
    );
  }

  void _save() {
    if (!formKey.currentState!.validate()) return;
    final notifier = ref.read(gruposProveedorProvider.notifier);
    if (widget.grupo == null) {
      notifier.crear(codCtrl.text, nomCtrl.text);
    } else {
      notifier.editar(widget.grupo!.id!, codCtrl.text, nomCtrl.text);
    }
    Navigator.pop(context);
  }
}
