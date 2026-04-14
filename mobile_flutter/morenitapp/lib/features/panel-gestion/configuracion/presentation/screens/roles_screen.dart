import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class RolesScreen extends ConsumerWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesProvider);

    return PlantillaVentanas(
      title: 'Gestión de Roles',
      isLoading: rolesAsync.isLoading,
      onRefresh: () => ref.refresh(rolesProvider),
      onNuevo: () => _showSideForm(context, ref),
      columns: const [
        DataColumn(label: Text('ID / CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('NOMBRE DEL ROL', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: rolesAsync.when(
        data: (roles) => roles.map((r) => DataRow(cells: [
          DataCell(CircleAvatar(radius: 12, child: Text(r.codigo.toString(), style: const TextStyle(fontSize: 10)))),
          DataCell(Text(r.nombre, style: const TextStyle(fontWeight: FontWeight.w500))),
          DataCell(_buildActionButtons(context, 
            onEdit: () => _showSideForm(context, ref, rol: r),
            onDelete: () => ref.read(rolesProvider.notifier).eliminar(r.id!),
          )),
        ])).toList(),
        error: (_, __) => [],
        loading: () => [],
      ),
    );
  }

  void _showSideForm(BuildContext context, WidgetRef ref, {dynamic rol}) {
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
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
            ),
            child: Material(child: _RolFormContent(rol: rol)),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(anim1),
          child: child,
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, {required VoidCallback onEdit, required VoidCallback onDelete}) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(Icons.edit_note, color: colors.primary), onPressed: onEdit),
        IconButton(icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent), onPressed: onDelete),
      ],
    );
  }
}

class _RolFormContent extends ConsumerStatefulWidget {
  final dynamic rol;
  const _RolFormContent({this.rol});
  @override
  ConsumerState<_RolFormContent> createState() => _RolFormContentState();
}

class _RolFormContentState extends ConsumerState<_RolFormContent> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController codCtrl;
  late TextEditingController nomCtrl;

  @override
  void initState() {
    super.initState();
    codCtrl = TextEditingController(text: widget.rol?.codigo.toString() ?? '');
    nomCtrl = TextEditingController(text: widget.rol?.nombre ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        _buildHeader(context, colors, widget.rol == null),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _buildField("CÓDIGO NUMÉRICO", codCtrl, "Ej: 1", colors, isNumeric: true),
                  const SizedBox(height: 25),
                  _buildField("NOMBRE DEL ROL", nomCtrl, "Nombre del rol", colors),
                  const SizedBox(height: 50),
                  _buildSaveButton(colors),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors, bool isNew) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 16, 20),
      decoration: BoxDecoration(color: colors.primary.withOpacity(0.08), borderRadius: const BorderRadius.only(topLeft: Radius.circular(30))),
      child: Row(
        children: [
          Icon(isNew ? Icons.person_add : Icons.edit_note, color: colors.primary),
          const SizedBox(width: 12),
          Text(isNew ? 'Nuevo Rol' : 'Editar Rol', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary)),
          const Spacer(),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, ColorScheme colors, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colors.primary, letterSpacing: 1.1)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(hintText: hint, filled: true, fillColor: colors.primary.withOpacity(0.02), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
      ],
    );
  }

  Widget _buildSaveButton(ColorScheme colors) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: colors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: () {
          if (!formKey.currentState!.validate()) return;
          final code = int.tryParse(codCtrl.text) ?? 0;
          if (widget.rol == null) {
            ref.read(rolesProvider.notifier).crear(code, nomCtrl.text);
          } else {
            ref.read(rolesProvider.notifier).editar(widget.rol.id, code, nomCtrl.text);
          }
          Navigator.pop(context);
        },
        child: Text(widget.rol == null ? 'GUARDAR ROL' : 'ACTUALIZAR ROL', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}