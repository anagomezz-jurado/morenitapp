import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class TipoEventoScreen extends ConsumerWidget {
  const TipoEventoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(tiposEventoProvider);

    return PlantillaVentanas(
      title: 'Tipos de Evento',
      isLoading: eventosAsync.isLoading,
      onRefresh: () => ref.refresh(tiposEventoProvider),
      onNuevo: () => _showSideForm(context, ref),
      columns: const [
        DataColumn(label: Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('NOMBRE DEL EVENTO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: eventosAsync.when(
        data: (lista) => lista.map((e) => DataRow(cells: [
          DataCell(Text(e.codigo)),
          DataCell(Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.w500))),
          DataCell(_buildActionButtons(context, 
            onEdit: () => _showSideForm(context, ref, evento: e),
            onDelete: () => ref.read(tiposEventoProvider.notifier).eliminar(e.id!),
          )),
        ])).toList(),
        error: (_, __) => [],
        loading: () => [],
      ),
    );
  }

  void _showSideForm(BuildContext context, WidgetRef ref, {dynamic evento}) {
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
            child: Material(child: _EventoFormContent(evento: evento)),
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

class _EventoFormContent extends ConsumerStatefulWidget {
  final dynamic evento;
  const _EventoFormContent({this.evento});
  @override
  ConsumerState<_EventoFormContent> createState() => _EventoFormContentState();
}

class _EventoFormContentState extends ConsumerState<_EventoFormContent> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController codCtrl;
  late TextEditingController nomCtrl;

  @override
  void initState() {
    super.initState();
    codCtrl = TextEditingController(text: widget.evento?.codigo ?? '');
    nomCtrl = TextEditingController(text: widget.evento?.nombre ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(children: [
      _buildHeader(context, colors, widget.evento == null),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(32), child: Form(key: formKey, child: Column(children: [
        _buildField("CÓDIGO (EJ: BAUT)", codCtrl, "Ej: BAUT", colors),
        const SizedBox(height: 25),
        _buildField("NOMBRE DEL EVENTO", nomCtrl, "Nombre del evento", colors),
        const SizedBox(height: 50),
        _buildSaveButton(colors),
      ]))))
    ]);
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors, bool isNew) {
    return Container(padding: const EdgeInsets.fromLTRB(24, 40, 16, 20), decoration: BoxDecoration(color: colors.primary.withOpacity(0.08), borderRadius: const BorderRadius.only(topLeft: Radius.circular(30))), child: Row(children: [
      Icon(isNew ? Icons.event : Icons.edit_note, color: colors.primary),
      const SizedBox(width: 12),
      Text(isNew ? 'Nuevo Evento' : 'Editar Evento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary)),
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
      if (widget.evento == null) {
        ref.read(tiposEventoProvider.notifier).crear(codCtrl.text, nomCtrl.text);
      } else {
        ref.read(tiposEventoProvider.notifier).editar(widget.evento.id, codCtrl.text, nomCtrl.text);
      }
      Navigator.pop(context);
    }, child: Text(widget.evento == null ? 'GUARDAR EVENTO' : 'ACTUALIZAR EVENTO', style: const TextStyle(fontWeight: FontWeight.bold))));
  }
}