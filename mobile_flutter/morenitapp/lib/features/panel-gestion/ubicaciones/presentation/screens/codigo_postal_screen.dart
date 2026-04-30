import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/codigo_postal.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class CodigoPostalScreen extends ConsumerWidget {
  const CodigoPostalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cpAsync = ref.watch(codigosPostalesProvider);
    final localidadesAsync = ref.watch(localidadesProvider);

    return PlantillaVentanas(
      title: 'Códigos Postales',
      isLoading: cpAsync.isLoading,
      onRefresh: () =>
          ref.read(codigosPostalesProvider.notifier).cargarCodigosPostales(),
      onNuevo: () => _showSideForm(context, ref),
      columns: const [
        DataColumn(
            label: Text('CÓDIGO POSTAL',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('LOCALIDAD ASIGNADA',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('ACCIONES',
                style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: cpAsync.maybeWhen(
        data: (codigos) => codigos.map((cp) {
          final nombreLocalidad = localidadesAsync.maybeWhen(
            data: (list) => list.any((l) => l.id == cp.localidadId)
                ? list.firstWhere((l) => l.id == cp.localidadId).nombreLocalidad
                : 'ID: ${cp.localidadId}',
            orElse: () => '...',
          );
          return DataRow(cells: [
            DataCell(Text(cp.name,
                style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(nombreLocalidad)),
            DataCell(Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.edit_note, color: Colors.blue),
                    onPressed: () => _showSideForm(context, ref, cp: cp)),
                IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined,
                        color: Colors.red),
                    onPressed: () => _confirmDelete(context, ref, cp)),
              ],
            )),
          ]);
        }).toList(),
        orElse: () => [],
      ),
    );
  }

  void _showSideForm(BuildContext context, WidgetRef ref, {CodigoPostal? cp}) {
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
            width: MediaQuery.of(context).size.width * 0.35,
            height: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: Material(child: _CPFormContent(cp: cp)),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(anim1),
          child: child),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, CodigoPostal cp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar?'),
        content: Text('¿Desea eliminar el código postal ${cp.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await ref
                    .read(codigosPostalesProvider.notifier)
                    .borrarCodigoPostal(cp.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('ELIMINAR')),
        ],
      ),
    );
  }
}

class _CPFormContent extends ConsumerStatefulWidget {
  final CodigoPostal? cp;
  const _CPFormContent({this.cp});
  @override
  ConsumerState<_CPFormContent> createState() => _CPFormContentState();
}

class _CPFormContentState extends ConsumerState<_CPFormContent> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController cpCtrl;
  int? selectedLoc;

  @override
  void initState() {
    super.initState();
    cpCtrl = TextEditingController(text: widget.cp?.name ?? '');
    selectedLoc = widget.cp?.localidadId;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(children: [
      _buildHeader(context, colors, widget.cp == null),
      Expanded(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Form(
                  key: formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("CÓDIGO POSTAL"),
                        TextFormField(
                            controller: cpCtrl,
                            keyboardType: TextInputType.number,
                            decoration:
                                _inputDecoration(Icons.mark_as_unread_outlined),
                            validator: (v) => v!.isEmpty ? 'Requerido' : null),
                        const SizedBox(height: 25),
                        _label("LOCALIDAD"),
                        ref.watch(localidadesProvider).when(
                              data: (list) => DropdownButtonFormField<int>(
                                  value: selectedLoc,
                                  decoration:
                                      _inputDecoration(Icons.location_city),
                                  items: list
                                      .map((l) => DropdownMenuItem(
                                          value: l.id,
                                          child: Text(l.nombreLocalidad)))
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => selectedLoc = val)),
                              loading: () => const LinearProgressIndicator(),
                              error: (_, __) => const Text("Error"),
                            ),
                        const SizedBox(height: 50),
                        SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton(
                                style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15))),
                                onPressed: _save,
                                child: Text(widget.cp == null
                                    ? "GUARDAR"
                                    : "ACTUALIZAR"))),
                      ]))))
    ]);
  }

  void _save() async {
    if (!formKey.currentState!.validate() || selectedLoc == null) return;
    if (widget.cp == null) {
      await ref
          .read(codigosPostalesProvider.notifier)
          .agregarCodigoPostal(cpCtrl.text, selectedLoc!);
    } else {
      await ref
          .read(codigosPostalesProvider.notifier)
          .editarCodigoPostal(widget.cp!.id, cpCtrl.text, selectedLoc!);
    }
    if (mounted) Navigator.pop(context);
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors, bool isNew) =>
      Container(
          padding: const EdgeInsets.fromLTRB(24, 40, 16, 20),
          color: colors.primary.withOpacity(0.08),
          child: Row(children: [
            Icon(isNew ? Icons.post_add : Icons.edit, color: colors.primary),
            const SizedBox(width: 12),
            Text(isNew ? 'Nuevo C.P.' : 'Editar C.P.',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.primary)),
            const Spacer(),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close))
          ]));
  Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)));
  InputDecoration _inputDecoration(IconData icon) => InputDecoration(
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200)));
}
