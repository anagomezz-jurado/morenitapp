import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/shared/widgets/calle_search_delegate.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_formularios.dart';
import '../../domain/entities/autoridad.dart';
import '../providers/secretaria_provider.dart' hide tiposAutoridadProvider;

class AutoridadFormScreen extends ConsumerStatefulWidget {
  final Autoridad? autoridadAEditar;
  const AutoridadFormScreen({super.key, this.autoridadAEditar});

  @override
  ConsumerState<AutoridadFormScreen> createState() =>
      _AutoridadFormScreenState();
}

class _AutoridadFormScreenState extends ConsumerState<AutoridadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  int? selectedTipoId;
  int? provinciaId, localidadId, cpId, calleSeleccionadaId;

  late TextEditingController codCtrl,
      nomCtrl,
      saludaCtrl,
      cargoCtrl,
      emailCtrl,
      telCtrl,
      calleCtrl,
      numeroCtrl,
      pisoCtrl,
      puertaCtrl,
      bloqueCtrl,
      escaleraCtrl,
      portalCtrl,
      obsCtrl;

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
    calleCtrl = TextEditingController(text: a?.calleNombre ?? '');
    numeroCtrl = TextEditingController(text: a?.numero ?? '');
    pisoCtrl = TextEditingController(text: a?.piso ?? '');
    puertaCtrl = TextEditingController(text: a?.puerta ?? '');
    bloqueCtrl = TextEditingController(text: a?.bloque ?? '');
    escaleraCtrl = TextEditingController(text: a?.escalera ?? '');
    portalCtrl = TextEditingController(text: a?.portal ?? '');
    obsCtrl = TextEditingController(text: a?.observaciones ?? '');

    Future.microtask(() async {
      await ref.read(provinciasProvider.notifier).cargarProvincias();
      await ref.read(localidadesProvider.notifier).cargarLocalidades();
      await ref.read(codigosPostalesProvider.notifier).cargarCodigosPostales();

      if (!mounted) return;

      if (a != null) {
        setState(() {
          selectedTipoId = a.tipoautoridadId;
          calleSeleccionadaId = a.calleId;
        });
        _inicializarUbicacionEdicion(a);
      }
    });
  }

  void _abrirSelectorCallePrincipal() async {
    final result = await showSearch(
        context: context, delegate: CalleSearchDelegate(ref: ref));
    if (result == null) return;
    if (result is Calle) {
      _autocompletarDesdeCalle(result);
    } else if (result is String && result.isNotEmpty) {
      _dialogoCrearCalleRapido(result);
    }
  }

  void _autocompletarDesdeCalle(Calle calle) {
    final listaCPs = ref.read(codigosPostalesProvider).value ?? [];
    final listaLocs = ref.read(localidadesProvider).value ?? [];
    try {
      final loc = listaLocs.firstWhere((l) => l.id == calle.localidadId);
      final cp = listaCPs.firstWhere((c) => c.id == calle.codPostalId);
      setState(() {
        calleSeleccionadaId = calle.id;
        calleCtrl.text = calle.nombreCalle;
        provinciaId = loc.codProvinciaId;
        localidadId = loc.id;
        cpId = cp.id;
      });
    } catch (_) {
      setState(() {
        calleSeleccionadaId = calle.id;
        calleCtrl.text = calle.nombreCalle;
      });
    }
  }

  void _inicializarUbicacionEdicion(Autoridad a) {
    if (a.calleId == null) return;
    final calles = ref.read(callesProvider).value ?? [];
    try {
      final calle = calles.firstWhere((c) => c.id == a.calleId);
      _autocompletarDesdeCalle(calle);
    } catch (_) {
      setState(() {
        calleCtrl.text = a.calleNombre;
      });
    }
  }

  void _dialogoCrearCalleRapido(String nombreSugerido) {
    final nombreCtrlCrear = TextEditingController(text: nombreSugerido);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nueva Calle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _textFormField(nombreCtrlCrear, hint: 'Nombre', required: true),
              const SizedBox(height: 10),
              _provinciaDropdown(
                  onChanged: (v) => setDialogState(() => provinciaId = v)),
              if (provinciaId != null)
                _localidadDropdown(
                    onChanged: (v) => setDialogState(() => localidadId = v)),
              if (localidadId != null)
                _cpDropdown(onChanged: (v) => setDialogState(() => cpId = v)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: (localidadId == null || cpId == null)
                  ? null
                  : () async {
                      await ref.read(callesProvider.notifier).agregarCalle(
                          nombreCtrlCrear.text.trim(), localidadId!, cpId!);
                      final nueva = ref.read(callesProvider).value?.last;
                      if (nueva != null) _autocompletarDesdeCalle(nueva);
                      if (mounted) Navigator.pop(context);
                    },
              child: const Text('GUARDAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> data = {
        "codAutoridad": codCtrl.text.trim(),
        "nombreAutoridad": nomCtrl.text.trim(),
        "nombreSaluda": saludaCtrl.text.trim(),
        "cargo": cargoCtrl.text.trim(),
        "telefono": telCtrl.text.trim(),
        "correoElectronico": emailCtrl.text.trim(),
        "observaciones":
            obsCtrl.text.trim().isEmpty ? false : obsCtrl.text.trim(),
        "tipoautoridad_id": selectedTipoId,
        "calle_id": calleSeleccionadaId,
        "numero": numeroCtrl.text.trim(),
        "piso": pisoCtrl.text.trim(),
        "puerta": puertaCtrl.text.trim(),
        "bloque": bloqueCtrl.text.trim(),
        "escalera": escaleraCtrl.text.trim(),
        "portal": portalCtrl.text.trim(),
      };

      if (widget.autoridadAEditar == null) {
        await ref.read(autoridadesProvider.notifier).guardar(data);
      } else {
        await ref
            .read(autoridadesProvider.notifier)
            .actualizar(int.parse(widget.autoridadAEditar!.id), data);
      }

      if (mounted) context.pop();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlantillaWrapper(
      isLoading: _isLoading,
      title: widget.autoridadAEditar != null
          ? 'Ficha de Autoridad'
          : 'Nueva Autoridad',
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCard(title: 'IDENTIFICACIÓN', children: [
              _buildRow('Código *', _textFormField(codCtrl, required: true)),
              _buildRow('Nombre *', _textFormField(nomCtrl, required: true)),
              _buildRow('Saluda', _textFormField(saludaCtrl)),
              _buildRow('Tipo *', _tipoAutoridadDropdown()),
            ]),
            _buildCard(title: 'CARGO Y CONTACTO', children: [
              _buildRow('Cargo *', _textFormField(cargoCtrl, required: true)),
              _buildRow('Teléfono', _textFormField(telCtrl, isNumber: true)),
              _buildRow('Email', _textFormField(emailCtrl, isEmail: true)),
            ]),
            _buildCard(title: 'UBICACIÓN', children: [
              _buildRow('Calle *', _calleSelectorField()),
              const Divider(),
              _buildRow('Provincia', _provinciaDropdown()),
              if (provinciaId != null)
                _buildRow('Localidad', _localidadDropdown()),
              if (localidadId != null) _buildRow('CP', _cpDropdown()),
              _buildRow(
                  'Nº / Pta',
                  Row(children: [
                    Expanded(child: _textFormField(numeroCtrl, hint: 'Número')),
                    const SizedBox(width: 8),
                    Expanded(child: _textFormField(puertaCtrl, hint: 'Puerta')),
                  ])),
              _buildRow(
                  'Piso / Esc.',
                  Row(children: [
                    Expanded(child: _textFormField(pisoCtrl, hint: 'Piso')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _textFormField(escaleraCtrl, hint: 'Escalera')),
                  ])),
              _buildRow(
                  'Bloque / Portal',
                  Row(children: [
                    Expanded(child: _textFormField(bloqueCtrl, hint: 'Bloque')),
                    const SizedBox(width: 8),
                    Expanded(child: _textFormField(portalCtrl, hint: 'Portal')),
                  ])),
            ]),
            _buildCard(title: 'OBSERVACIONES', children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: obsCtrl,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: 'Notas adicionales...',
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- Widgets de utilidad ---

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  fontSize: 11)),
          const Divider(),
          ...children
        ]),
      ),
    );
  }

  Widget _buildRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.black54))),
        Expanded(flex: 5, child: child),
      ]),
    );
  }

  Widget _textFormField(TextEditingController ctrl,
      {bool required = false,
      bool isNumber = false,
      bool isEmail = false,
      String? hint,
      bool readOnly = false}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: isNumber
          ? TextInputType.number
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          fillColor: readOnly ? Colors.grey[100] : null,
          filled: readOnly),
      validator: (v) =>
          (required && (v == null || v.isEmpty)) ? 'Obligatorio' : null,
    );
  }

  Widget _tipoAutoridadDropdown() {
    final tipos = ref.watch(tiposAutoridadProvider);
    return tipos.when(
      data: (list) => DropdownButtonFormField<int>(
        value: selectedTipoId,
        items: list
            .map((t) => DropdownMenuItem(value: t.id, child: Text(t.nombre)))
            .toList(),
        onChanged: (v) => setState(() => selectedTipoId = v),
        validator: (v) => v == null ? 'Obligatorio' : null,
        decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error'),
    );
  }

  Widget _calleSelectorField() {
    return TextFormField(
      controller: calleCtrl,
      readOnly: true,
      onTap: _abrirSelectorCallePrincipal,
      decoration: InputDecoration(
          suffixIcon: const Icon(Icons.search),
          hintText: 'Buscar calle...',
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
    );
  }

  Widget _provinciaDropdown({Function(int?)? onChanged}) => ref
      .watch(provinciasProvider)
      .when(
        data: (list) => DropdownButtonFormField<int>(
          value: provinciaId,
          items: list
              .map((p) =>
                  DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia)))
              .toList(),
          onChanged: (v) {
            setState(() {
              provinciaId = v;
              localidadId = null;
              cpId = null;
            });
            if (onChanged != null) onChanged(v);
          },
          decoration: InputDecoration(
              labelText: 'Provincia',
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        ),
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text('Error'),
      );

  Widget _localidadDropdown({Function(int?)? onChanged}) => ref
      .watch(localidadesProvider)
      .when(
        data: (list) {
          final filtradas =
              list.where((l) => l.codProvinciaId == provinciaId).toList();
          return DropdownButtonFormField<int>(
            value:
                filtradas.any((l) => l.id == localidadId) ? localidadId : null,
            items: filtradas
                .map((l) => DropdownMenuItem(
                    value: l.id,
                    child: Text(l.nombreLocalidad,
                        overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) {
              setState(() {
                localidadId = v;
                cpId = null;
              });
              if (onChanged != null) onChanged(v);
            },
            decoration: InputDecoration(
                labelText: 'Localidad',
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text('Error'),
      );

  Widget _cpDropdown({Function(int?)? onChanged}) => ref
      .watch(codigosPostalesProvider)
      .when(
        data: (list) {
          final filtrados =
              list.where((c) => c.localidadId == localidadId).toList();
          return DropdownButtonFormField<int>(
            value: filtrados.any((c) => c.id == cpId) ? cpId : null,
            items: filtrados
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) {
              setState(() => cpId = v);
              if (onChanged != null) onChanged(v);
            },
            decoration: InputDecoration(
                labelText: 'CP',
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text('Error'),
      );

  @override
  void dispose() {
    final ctrls = [
      codCtrl,
      nomCtrl,
      saludaCtrl,
      cargoCtrl,
      emailCtrl,
      telCtrl,
      calleCtrl,
      numeroCtrl,
      pisoCtrl,
      puertaCtrl,
      bloqueCtrl,
      escaleraCtrl,
      portalCtrl,
      obsCtrl,
    ];
    for (var c in ctrls) {
      c.dispose();
    }
    super.dispose();
  }
}
