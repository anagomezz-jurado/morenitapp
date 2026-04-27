import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/shared/widgets/calle_search_delegate.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_formularios.dart';
import '../../domain/entities/autoridad.dart';
import '../providers/secretaria_provider.dart';

class AutoridadFormScreen extends ConsumerStatefulWidget {
  final Autoridad? autoridadAEditar;
  const AutoridadFormScreen({super.key, this.autoridadAEditar});

  @override
  ConsumerState<AutoridadFormScreen> createState() => _AutoridadFormScreenState();
}

class _AutoridadFormScreenState extends ConsumerState<AutoridadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  int? selectedTipoId;
  int? provinciaId, localidadId, codPostalId;

  late TextEditingController codCtrl, nomCtrl, saludaCtrl, cargoCtrl, emailCtrl, telCtrl, calleCtrl, pisoCtrl, puertaCtrl, obsCtrl;

  @override
  void initState() {
    super.initState();
    final a = widget.autoridadAEditar;
    
    codCtrl = TextEditingController(text: a?.codAutoridad ?? '');
    nomCtrl = TextEditingController(text: a?.nombreAutoridad ?? '');
    saludaCtrl = TextEditingController(text: a?.nombreSaluda ?? '');
    cargoCtrl = TextEditingController(text: a?.cargo ?? '');
    emailCtrl = TextEditingController(text: a?.email ?? '');
    telCtrl = TextEditingController(text: a?.telefono ?? '');
    calleCtrl = TextEditingController(text: a?.direccion ?? '');
    pisoCtrl = TextEditingController();
    puertaCtrl = TextEditingController();
    obsCtrl = TextEditingController(text: a?.observaciones ?? '');
    
    selectedTipoId = a?.tipoautoridadId;
    localidadId = a?.localidadId;


    Future.microtask(() {
      ref.read(provinciasProvider.notifier).cargarProvincias();
      ref.read(localidadesProvider.notifier).cargarLocalidades();
      // Si estamos editando, intentar pre-seleccionar la provincia según la localidad
      if (localidadId != null) {
        final locs = ref.read(localidadesProvider).value;
        final loc = locs?.where((l) => l.id == localidadId).firstOrNull;
        if (loc != null) setState(() => provinciaId = loc.codProvinciaId);
      }
    });
  }

  @override
  void dispose() {
    codCtrl.dispose(); nomCtrl.dispose(); saludaCtrl.dispose();
    cargoCtrl.dispose(); emailCtrl.dispose(); telCtrl.dispose();
    calleCtrl.dispose(); pisoCtrl.dispose(); puertaCtrl.dispose();
    obsCtrl.dispose();
    super.dispose();
  }

  void _abrirSelectorCalle() async {
    final resultado = await showSearch(context: context, delegate: CalleSearchDelegate(ref: ref));
    if (resultado is Calle) {
      final locs = ref.read(localidadesProvider).value ?? [];
      final loc = locs.where((l) => l.id == resultado.localidadId).firstOrNull;
      setState(() {
        calleCtrl.text = resultado.nombreCalle;
        localidadId = resultado.localidadId;
        provinciaId = loc?.codProvinciaId;
      });
    }
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Asegúrate de que las llaves del Map coincidan con tu AutoridadModel.toJson() o lo que reciba el provider
    final Map<String, dynamic> datos = {
      'codAutoridad': codCtrl.text.trim(),
      'nombreAutoridad': nomCtrl.text.trim(),
      'nombreSaluda': saludaCtrl.text.trim(),
      'cargo': cargoCtrl.text.trim(),
      'correoElectronico': emailCtrl.text.trim(),
      'telefono': telCtrl.text.trim(),
      'direccion': "${calleCtrl.text} ${pisoCtrl.text} ${puertaCtrl.text}".trim(),
      'observaciones': obsCtrl.text.trim(),
      'tipoautoridad_id': selectedTipoId,
      'localidad_id': localidadId,
    };

    if (widget.autoridadAEditar != null) {
      datos['id'] = int.tryParse(widget.autoridadAEditar!.id) ?? 0;
    }

    try {
      await ref.read(autoridadesProvider.notifier).guardar(datos);
      if (mounted) context.pop(); // Volver a la tabla
    } catch (e) {
      // Manejar error si es necesario
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlantillaWrapper(
      isLoading: _isLoading,
      title: widget.autoridadAEditar != null ? 'Editar Autoridad' : 'Nueva Autoridad',
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCard(title: 'DATOS DE IDENTIFICACIÓN', children: [
              _buildRow('Código', _textFormField(codCtrl, required: true)),
              _buildRow('Nombre Completo', _textFormField(nomCtrl, required: true)),
              _buildRow('Tipo Autoridad', _tipoDropdown()),
              _buildRow('Saluda', _textFormField(saludaCtrl, hint: 'Ej: Excmo. Sr.')),
            ]),
            _buildCard(title: 'CONTACTO Y CARGO', children: [
              _buildRow('Cargo Actual', _textFormField(cargoCtrl, required: true)),
              _buildRow('Teléfono', _textFormField(telCtrl, isNumber: true)),
              _buildRow('Email', _textFormField(emailCtrl, isEmail: true)),
            ]),
            _buildCard(title: 'UBICACIÓN', children: [
              _buildRow('Calle/Sede', _calleSelectorField()),
              _buildRow('Provincia', _provinciaDropdown()),
              if (provinciaId != null) _buildRow('Localidad', _localidadDropdown()),
              _buildRow('Piso/Puerta', Row(children: [
                Expanded(child: _textFormField(pisoCtrl, hint: 'Piso')),
                const SizedBox(width: 10),
                Expanded(child: _textFormField(puertaCtrl, hint: 'Pta.')),
              ])),
            ]),
            _buildCard(title: 'OBSERVACIONES', children: [
              _textFormField(obsCtrl, maxLines: 3, hint: 'Notas adicionales...'),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Widgets Auxiliares Reutilizables ---

  Widget _tipoDropdown() {
    final tipos = ref.watch(tiposAutoridadProvider);
    return tipos.when(
      data: (list) => DropdownButtonFormField<int>(
        value: selectedTipoId,
        isExpanded: true,
        items: list.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nombre))).toList(),
        onChanged: (v) => setState(() => selectedTipoId = v),
        decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        validator: (v) => v == null ? 'Seleccione tipo' : null,
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error al cargar tipos'),
    );
  }

  Widget _provinciaDropdown() => ref.watch(provinciasProvider).when(
    data: (list) => DropdownButtonFormField<int>(
      value: provinciaId,
      isExpanded: true,
      items: list.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))).toList(),
      onChanged: (v) => setState(() { provinciaId = v; localidadId = null; }),
      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
    ),
    loading: () => const SizedBox(),
    error: (_, __) => const SizedBox(),
  );

  Widget _localidadDropdown() => ref.watch(localidadesProvider).when(
    data: (list) {
      final filtradas = list.where((l) => l.codProvinciaId == provinciaId).toList();
      return DropdownButtonFormField<int>(
        value: filtradas.any((l) => l.id == localidadId) ? localidadId : null,
        isExpanded: true,
        items: filtradas.map((l) => DropdownMenuItem(value: l.id, child: Text(l.nombreLocalidad))).toList(),
        onChanged: (v) => setState(() => localidadId = v),
        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
      );
    },
    loading: () => const SizedBox(),
    error: (_, __) => const SizedBox(),
  );

  Widget _buildCard({required String title, required List<Widget> children}) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 0, 
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey)),
        const Divider(),
        ...children
      ]),
    ),
  );

  Widget _buildRow(String label, Widget child) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87))),
      Expanded(flex: 5, child: child),
    ]),
  );

  Widget _textFormField(TextEditingController ctrl, {bool required = false, bool isNumber = false, bool isEmail = false, String? hint, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl, 
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      validator: (v) => (required && (v == null || v.trim().isEmpty)) ? 'Campo requerido' : null,
      decoration: InputDecoration(hintText: hint, isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget _calleSelectorField() => TextFormField(
    controller: calleCtrl, 
    readOnly: true, 
    onTap: _abrirSelectorCalle,
    decoration: InputDecoration(
      suffixIcon: const Icon(Icons.search, size: 20), 
      isDense: true, 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      hintText: 'Seleccionar ubicación...'
    ),
  );
}