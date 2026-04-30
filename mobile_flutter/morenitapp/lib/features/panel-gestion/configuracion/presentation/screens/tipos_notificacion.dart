import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/notificacion_tipo.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class TiposNotificacionScreen extends ConsumerWidget {
  const TiposNotificacionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiposAsync = ref.watch(notificacionTiposProvider);

    return PlantillaVentanas(
      title: 'Tipos de Notificación',
      isLoading: tiposAsync.isLoading,
      onRefresh: () => ref.refresh(notificacionTiposProvider),
      onNuevo: () => _showSideForm(context, ref),
      columns: const [
        DataColumn(
            label:
                Text('NOMBRE', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('ACCIONES',
                style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: tiposAsync.when(
        data: (tipos) {
          if (tipos.isEmpty) {
            return [
              const DataRow(cells: [
                DataCell(Text('No hay registros disponibles')),
                DataCell(Text('-')),
              ])
            ];
          }
          return tipos
              .map((t) => DataRow(cells: [
                    DataCell(Text(t.name)),
                    DataCell(_buildActions(
                      context,
                      onEdit: () => _showSideForm(context, ref, tipo: t),
                      onDelete: () async {
                        final success = await ref
                            .read(notificacionTiposProvider.notifier)
                            .eliminar(t.id);
                        if (context.mounted && !success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Error al eliminar el registro')));
                        }
                      },
                    )),
                  ]))
              .toList();
        },
        error: (err, stack) {
          debugPrint('Error en TiposNotificacion: $err');
          return [
            DataRow(cells: [
              DataCell(Text('Error al cargar datos',
                  style: TextStyle(color: Colors.red))),
              DataCell(Text(err.toString())),
            ])
          ];
        },
        loading: () => [
          const DataRow(cells: [
            DataCell(CircularProgressIndicator()),
            DataCell(Text('Cargando...')),
          ])
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context,
      {required VoidCallback onEdit, required VoidCallback onDelete}) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            icon: Icon(Icons.edit_note, color: colors.primary),
            onPressed: onEdit),
        IconButton(
            icon: const Icon(Icons.delete_sweep_outlined,
                color: Colors.redAccent),
            onPressed: onDelete),
      ],
    );
  }

  void _showSideForm(BuildContext context, WidgetRef ref,
      {NotificacionTipo? tipo}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
          ),
          child: Material(child: _TipoForm(tipo: tipo)),
        ),
      ),
      transitionBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
  }
}

class _TipoForm extends ConsumerStatefulWidget {
  final NotificacionTipo? tipo;
  const _TipoForm({this.tipo});

  @override
  ConsumerState<_TipoForm> createState() => _TipoFormState();
}

class _TipoFormState extends ConsumerState<_TipoForm> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nombreCtrl;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nombreCtrl = TextEditingController(text: widget.tipo?.name ?? '');
  }

  void _save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isSaving = true);

    try {
      final notifier = ref.read(notificacionTiposProvider.notifier);

      if (widget.tipo == null) {
        await notifier.crear(nombreCtrl.text);
      } else {
        await notifier.editar(widget.tipo!.id, nombreCtrl.text);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        _buildHeader(context, colors),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _buildField(
                      "NOMBRE", nombreCtrl, "Ej: Avisos Generales", colors),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: isSaving ? null : _save,
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.tipo == null ? 'GUARDAR' : 'ACTUALIZAR'),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 16, 20),
      decoration: BoxDecoration(color: colors.primary.withOpacity(0.08)),
      child: Row(
        children: [
          Icon(widget.tipo == null ? Icons.add : Icons.edit,
              color: colors.primary),
          const SizedBox(width: 10),
          Text(widget.tipo == null ? 'Nuevo Tipo' : 'Editar Tipo',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.primary)),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context))
        ],
      ),
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
                color: colors.primary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: colors.primary.withOpacity(0.02)),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
      ],
    );
  }
}
