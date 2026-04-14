import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class TipoCargoScreen extends ConsumerWidget {
  const TipoCargoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cargosAsync = ref.watch(tiposCargoProvider);

    return PlantillaVentanas(
      title: 'Tipos de Cargo',
      isLoading: cargosAsync.isLoading,
      onRefresh: () => ref.refresh(tiposCargoProvider),
      onNuevo: () => _showSideForm(context, ref),
      columns: const [
        DataColumn(label: Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('NOMBRE', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('OBSERVACIONES', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: cargosAsync.when(
        data: (lista) => lista.map((c) => DataRow(cells: [
          DataCell(Text(c.codigo)),
          DataCell(Text(c.nombre, style: const TextStyle(fontWeight: FontWeight.w500))),
          DataCell(Text(c.observaciones ?? '-')),
          DataCell(_buildActionButtons(context, 
            onEdit: () => _showSideForm(context, ref, cargo: c),
            onDelete: () => ref.read(tiposCargoProvider.notifier).eliminar(c.id!),
          )),
        ])).toList(),
        error: (_, __) => [],
        loading: () => [],
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
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30))),
            child: Material(child: _CargoFormContent(cargo: cargo)),
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(children: [
      _buildHeader(context, colors, widget.cargo == null),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(32), child: Form(key: formKey, child: Column(children: [
        _buildField("CÓDIGO", codCtrl, "Ej: CAR-01", colors),
        const SizedBox(height: 25),
        _buildField("NOMBRE", nomCtrl, "Nombre del cargo", colors),
        const SizedBox(height: 25),
        _buildField("OBSERVACIONES", obsCtrl, "Notas adicionales", colors, maxLines: 3),
        const SizedBox(height: 50),
        _buildSaveButton(colors),
      ]))))
    ]);
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors, bool isNew) {
    return Container(padding: const EdgeInsets.fromLTRB(24, 40, 16, 20), decoration: BoxDecoration(color: colors.primary.withOpacity(0.08), borderRadius: const BorderRadius.only(topLeft: Radius.circular(30))), child: Row(children: [
      Icon(isNew ? Icons.work_outline : Icons.edit_note, color: colors.primary),
      const SizedBox(width: 12),
      Text(isNew ? 'Nuevo Cargo' : 'Editar Cargo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary)),
      const Spacer(),
      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
    ]));
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, ColorScheme colors, {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colors.primary)),
      const SizedBox(height: 8),
      TextFormField(controller: ctrl, maxLines: maxLines, decoration: InputDecoration(hintText: hint, filled: true, fillColor: colors.primary.withOpacity(0.02), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => v!.isEmpty ? 'Requerido' : null),
    ]);
  }

  Widget _buildSaveButton(ColorScheme colors) {
    return SizedBox(width: double.infinity, height: 50, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: colors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: () {
      if (!formKey.currentState!.validate()) return;
      if (widget.cargo == null) {
        ref.read(tiposCargoProvider.notifier).crear(codCtrl.text, nomCtrl.text, obsCtrl.text);
      } else {
        ref.read(tiposCargoProvider.notifier).editar(widget.cargo.id, codCtrl.text, nomCtrl.text, obsCtrl.text);
      }
      Navigator.pop(context);
    }, child: Text(widget.cargo == null ? 'GUARDAR CARGO' : 'ACTUALIZAR CARGO', style: const TextStyle(fontWeight: FontWeight.bold))));
  }
}