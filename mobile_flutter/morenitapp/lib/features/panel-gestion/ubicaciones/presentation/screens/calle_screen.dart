import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class CallesGestionScreen extends ConsumerStatefulWidget {
  const CallesGestionScreen({super.key});

  @override
  ConsumerState<CallesGestionScreen> createState() => _CallesGestionScreenState();
}

class _CallesGestionScreenState extends ConsumerState<CallesGestionScreen> {
  @override
  Widget build(BuildContext context) {
    final callesAsync = ref.watch(callesProvider);

    return PlantillaVentanas(
      title: 'Configuración de Calles',
      isLoading: callesAsync.isLoading,
      onRefresh: () => ref.read(callesProvider.notifier).cargarCalles(),
      onNuevo: () => _showSideForm(context),
      columns: const [
        DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('NOMBRE DE CALLE', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: callesAsync.maybeWhen(
        data: (calles) => calles.map((calle) => DataRow(cells: [
          DataCell(Text(calle.id.toString())),
          DataCell(Text(calle.nombreCalle)),
          DataCell(Row(
            children: [
              IconButton(icon: const Icon(Icons.edit_note, color: Colors.blue), onPressed: () => _showSideForm(context, calleEdit: calle)),
              IconButton(icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red), onPressed: () => _confirmarEliminacion(context, calle)),
            ],
          )),
        ])).toList(),
        orElse: () => [],
      ),
    );
  }

  void _showSideForm(BuildContext context, {dynamic calleEdit}) {
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
            child: Material(child: _CalleFormContent(calleEdit: calleEdit)),
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

  void _confirmarEliminacion(BuildContext context, dynamic calle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Desea eliminar la calle "${calle.nombreCalle}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(callesProvider.notifier).borrarCalle(calle.id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

class _CalleFormContent extends ConsumerStatefulWidget {
  final dynamic calleEdit;
  const _CalleFormContent({this.calleEdit});

  @override
  ConsumerState<_CalleFormContent> createState() => _CalleFormContentState();
}

class _CalleFormContentState extends ConsumerState<_CalleFormContent> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nombreCalleCtrl;
  int? idProvincia, idLocalidad, idCP;

  @override
  void initState() {
    super.initState();
    nombreCalleCtrl = TextEditingController(text: widget.calleEdit?.nombreCalle ?? '');
    idLocalidad = widget.calleEdit?.localidadId;
    idCP = widget.calleEdit?.codPostalId;
    // Si edita, deberíamos setear la provincia si el objeto calle la trae o buscarla
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provincias = ref.watch(provinciasProvider);
    final localidades = ref.watch(localidadesFiltradasProvider);
    final cps = ref.watch(codigosPostalesFiltradosProvider);

    return Column(
      children: [
        _buildHeader(context, colors, widget.calleEdit == null),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("PROVINCIA"),
                  provincias.when(
                    data: (lista) => DropdownButtonFormField<int>(
                      value: idProvincia,
                      decoration: _inputDecoration(Icons.map_outlined),
                      items: lista.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))).toList(),
                      onChanged: (val) {
                        setState(() { idProvincia = val; idLocalidad = null; idCP = null; });
                        ref.read(provinciaFiltroSeleccionadaProvider.notifier).state = val;
                      },
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text("Error al cargar"),
                  ),
                  const SizedBox(height: 20),
                  
                  _label("LOCALIDAD"),
                  DropdownButtonFormField<int>(
                    value: idLocalidad,
                    decoration: _inputDecoration(Icons.location_city),
                    items: idProvincia == null ? [] : localidades.maybeWhen(
                      data: (lista) => lista.map((l) => DropdownMenuItem(value: l.id, child: Text(l.nombreLocalidad))).toList(),
                      orElse: () => [],
                    ),
                    onChanged: (val) {
                      setState(() { idLocalidad = val; idCP = null; });
                      ref.read(localidadFiltroSeleccionadaProvider.notifier).state = val;
                    },
                  ),
                  const SizedBox(height: 20),

                  _label("CÓDIGO POSTAL"),
                  DropdownButtonFormField<int>(
                    value: idCP,
                    decoration: _inputDecoration(Icons.mark_as_unread_outlined),
                    items: idLocalidad == null ? [] : cps.maybeWhen(
                      data: (lista) => lista.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      orElse: () => [],
                    ),
                    onChanged: (val) => setState(() => idCP = val),
                  ),
                  const SizedBox(height: 20),

                  _label("NOMBRE DE LA CALLE"),
                  TextFormField(
                    controller: nombreCalleCtrl,
                    decoration: _inputDecoration(Icons.edit_road),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: _save,
                      child: Text(widget.calleEdit == null ? "GUARDAR CALLE" : "ACTUALIZAR CALLE"),
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

  void _save() async {
    if (!formKey.currentState!.validate() || idLocalidad == null || idCP == null) return;
    
    if (widget.calleEdit == null) {
      await ref.read(callesProvider.notifier).agregarCalle(nombreCalleCtrl.text, idLocalidad!, idCP!);
    } else {
      await ref.read(callesProvider.notifier).actualizarCalle(widget.calleEdit.id, nombreCalleCtrl.text, idLocalidad!, idCP!);
    }
    if (mounted) Navigator.pop(context);
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors, bool isNew) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 16, 20),
      color: colors.primary.withOpacity(0.08),
      child: Row(
        children: [
          Icon(isNew ? Icons.add_location_alt : Icons.edit_location, color: colors.primary),
          const SizedBox(width: 12),
          Text(isNew ? 'Nueva Calle' : 'Editar Calle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary)),
          const Spacer(),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
  );

  InputDecoration _inputDecoration(IconData icon) => InputDecoration(
    prefixIcon: Icon(icon, size: 20),
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
  );
}