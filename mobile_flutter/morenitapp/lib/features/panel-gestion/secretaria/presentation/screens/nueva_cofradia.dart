import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/shared/widgets/calle_search_delegate.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_formularios.dart';
import '../../domain/entities/cofradia.dart';
import '../providers/secretaria_provider.dart';

class CofradiaFormScreen extends ConsumerStatefulWidget {
  final Cofradia? cofradiaAEditar;
  const CofradiaFormScreen({super.key, this.cofradiaAEditar});

  @override
  ConsumerState<CofradiaFormScreen> createState() => _CofradiaFormScreenState();
}

class _CofradiaFormScreenState extends ConsumerState<CofradiaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  int? provinciaId, localidadId, cpId, calleSeleccionadaId;

  late TextEditingController cifCtrl,
      nombreCtrl,
      fundacionCtrl,
      emailCtrl,
      telefonoCtrl,
      webCtrl,
      obsCtrl,
      calleCtrl,
      numeroCtrl,
      pisoCtrl,
      puertaCtrl,
      bloqueCtrl,
      escaleraCtrl,
      portalCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.cofradiaAEditar;

    cifCtrl = TextEditingController(text: c?.cif ?? '');
    nombreCtrl = TextEditingController(text: c?.nombre ?? '');
    fundacionCtrl = TextEditingController(text: c?.fundacion?.toString() ?? '');
    emailCtrl = TextEditingController(text: c?.email ?? '');
    telefonoCtrl = TextEditingController(text: c?.telefono ?? '');
    webCtrl = TextEditingController(text: c?.web ?? '');
    obsCtrl = TextEditingController(text: c?.observaciones ?? '');
    calleCtrl = TextEditingController(text: c?.calleNombre ?? '');
    numeroCtrl = TextEditingController(text: c?.numero ?? '');
    pisoCtrl = TextEditingController(text: c?.piso ?? '');
    puertaCtrl = TextEditingController(text: c?.puerta ?? '');
    bloqueCtrl = TextEditingController(text: c?.bloque ?? '');
    escaleraCtrl = TextEditingController(text: c?.escalera ?? '');
    portalCtrl = TextEditingController(text: c?.portal ?? '');

    Future.microtask(() async {
      await ref.read(provinciasProvider.notifier).cargarProvincias();
      await ref.read(localidadesProvider.notifier).cargarLocalidades();
      await ref.read(codigosPostalesProvider.notifier).cargarCodigosPostales();

      if (!mounted) return;
      if (c != null) {
        setState(() {
          calleSeleccionadaId = c.calleId;
        });
        _inicializarUbicacionEdicion(c);
      }
    });
  }

  void _inicializarUbicacionEdicion(Cofradia c) {
    if (c.calleId == null) return;
    final calles = ref.read(callesProvider).value ?? [];
    try {
      final calle = calles.firstWhere((x) => x.id == c.calleId);
      _autocompletarDesdeCalle(calle);
    } catch (_) {
      setState(() => calleCtrl.text = c.calleNombre);
    }
  }

  void _abrirSelectorCallePrincipal() async {
    final result = await showSearch(
        context: context, delegate: CalleSearchDelegate(ref: ref));
    if (result == null) return;
    if (result is Calle) _autocompletarDesdeCalle(result);
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

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final data = {
        "cifCofradia": cifCtrl.text.trim(),
        "nombreCofradia": nombreCtrl.text.trim(),
        "antiguedadCofradia": int.tryParse(fundacionCtrl.text.trim()) ?? 0,
        "emailCofradia": emailCtrl.text.trim(),
        "telefonoCofradia": telefonoCtrl.text.trim(),
        "paginaWeb": webCtrl.text.trim(),
        "observaciones":
            obsCtrl.text.trim().isEmpty ? false : obsCtrl.text.trim(),
        "calle_id": calleSeleccionadaId,
        "numero": numeroCtrl.text.trim(),
        "piso": pisoCtrl.text.trim(),
        "puerta": puertaCtrl.text.trim(),
        "bloque": bloqueCtrl.text.trim(),
        "escalera": escaleraCtrl.text.trim(),
        "portal": portalCtrl.text.trim(),
      };

      if (widget.cofradiaAEditar == null) {
        await ref.read(cofradiasProvider.notifier).guardar(data);
      } else {
        await ref
            .read(cofradiasProvider.notifier)
            .actualizar(int.parse(widget.cofradiaAEditar!.id), data);
      }
      if (mounted) context.pop();
    } catch (e) {
      _showErrorDialog(e.toString());
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String e) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(e),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))
        ],
      ),
    );
  }

  // ---- UI ----
  @override
  Widget build(BuildContext context) {
    return PlantillaWrapper(
      isLoading: _isLoading,
      title: widget.cofradiaAEditar != null
          ? 'Ficha de Cofradía'
          : 'Nueva Cofradía',
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(children: [
          _buildCard(title: 'DATOS GENERALES', children: [
            _buildRow('CIF *', _textFormField(cifCtrl, required: true)),
            _buildRow('Nombre *', _textFormField(nombreCtrl, required: true)),
            _buildRow(
                'Fundación', _textFormField(fundacionCtrl, isNumber: true)),
          ]),
          _buildCard(title: 'DIRECCIÓN', children: [
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
          _buildCard(title: 'CONTACTO', children: [
            _buildRow('Teléfono', _textFormField(telefonoCtrl, isNumber: true)),
            _buildRow('Email', _textFormField(emailCtrl, isEmail: true)),
            _buildRow('Web', _textFormField(webCtrl)),
          ]),
          _buildCard(title: 'OBSERVACIONES', children: [
            TextFormField(
              controller: obsCtrl,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'Notas adicionales...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
          ]),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  // ---- helpers de UI ----
  Widget _buildCard({required String title, required List<Widget> children}) =>
      Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey)),
            const Divider(),
            ...children
          ]),
        ),
      );

  Widget _buildRow(String label, Widget child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(fontSize: 13, color: Colors.black54))),
          Expanded(flex: 5, child: child),
        ]),
      );

  Widget _textFormField(TextEditingController c,
      {bool required = false,
      bool isEmail = false,
      bool isNumber = false,
      String? hint}) {
    return TextFormField(
      controller: c,
      keyboardType: isNumber
          ? TextInputType.number
          : isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (v) =>
          (required && (v == null || v.isEmpty)) ? 'Obligatorio' : null,
    );
  }

  Widget _calleSelectorField() => TextFormField(
        controller: calleCtrl,
        readOnly: true,
        onTap: _abrirSelectorCallePrincipal,
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.search),
          hintText: 'Buscar calle...',
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Seleccione una calle' : null,
      );

  Widget _provinciaDropdown() => ref.watch(provinciasProvider).when(
        data: (list) => DropdownButtonFormField<int>(
          value: provinciaId,
          items: list
              .map((p) =>
                  DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia)))
              .toList(),
          onChanged: (v) => setState(() {
            provinciaId = v;
            localidadId = null;
            cpId = null;
          }),
          decoration: const InputDecoration(
              isDense: true, border: OutlineInputBorder()),
        ),
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text('Error'),
      );

  Widget _localidadDropdown() => ref.watch(localidadesProvider).when(
        data: (list) {
          final filtradas =
              list.where((l) => l.codProvinciaId == provinciaId).toList();
          return DropdownButtonFormField<int>(
            value: localidadId,
            items: filtradas
                .map((l) => DropdownMenuItem(
                    value: l.id, child: Text(l.nombreLocalidad)))
                .toList(),
            onChanged: (v) => setState(() {
              localidadId = v;
              cpId = null;
            }),
            decoration: const InputDecoration(
                isDense: true, border: OutlineInputBorder()),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text('Error'),
      );

  Widget _cpDropdown() => ref.watch(codigosPostalesProvider).when(
        data: (list) {
          final filtrados =
              list.where((c) => c.localidadId == localidadId).toList();
          return DropdownButtonFormField<int>(
            value: cpId,
            items: filtrados
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => cpId = v),
            decoration: const InputDecoration(
                isDense: true, border: OutlineInputBorder()),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text('Error'),
      );

  @override
  void dispose() {
    for (final c in [
      cifCtrl,
      nombreCtrl,
      fundacionCtrl,
      emailCtrl,
      telefonoCtrl,
      webCtrl,
      obsCtrl,
      calleCtrl,
      numeroCtrl,
      pisoCtrl,
      puertaCtrl,
      bloqueCtrl,
      escaleraCtrl,
      portalCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
