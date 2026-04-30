import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Entidades y Providers de Proveedores
import 'package:morenitapp/features/panel-gestion/proveedores/domain/entities/proveedor.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/presentation/providers/proveedor_providers.dart';

// Entidades y Providers de Configuración (Grupos)
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';

// Entidades y Providers de Ubicaciones
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';

// Widgets compartidos
import 'package:morenitapp/shared/widgets/calle_search_delegate.dart';
import 'package:morenitapp/shared/widgets/plantilla_formularios.dart';

class ProveedorFormScreen extends ConsumerStatefulWidget {
  final Proveedor? proveedorAEditar;
  final bool forcedAnunciante;

  const ProveedorFormScreen(
      {super.key, this.proveedorAEditar, this.forcedAnunciante = false});

  @override
  ConsumerState<ProveedorFormScreen> createState() =>
      _ProveedorFormScreenState();
}

class _ProveedorFormScreenState extends ConsumerState<ProveedorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool esAnunciante = false;

  int? provinciaId, localidadId, cpId, calleSeleccionadaId, grupoId;

  late TextEditingController codCtrl,
      nomCtrl,
      contCtrl,
      telCtrl,
      emaCtrl,
      obsCtrl;
  late TextEditingController calleCtrl,
      numCtrl,
      escCtrl,
      bloqCtrl,
      portCtrl,
      pisoCtrl,
      ptaCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.proveedorAEditar;

    codCtrl = TextEditingController(text: p?.codProveedor ?? '');
    nomCtrl = TextEditingController(text: p?.nombre ?? '');
    contCtrl = TextEditingController(text: p?.contacto ?? '');
    telCtrl = TextEditingController(text: p?.telefono ?? '');
    emaCtrl = TextEditingController(text: p?.email ?? '');
    obsCtrl = TextEditingController(text: p?.observaciones ?? '');

    calleCtrl = TextEditingController(text: p?.calleNombre ?? '');
    numCtrl = TextEditingController(text: p?.numero ?? '');
    escCtrl = TextEditingController(text: p?.escalera ?? '');
    bloqCtrl = TextEditingController(text: p?.bloque ?? '');
    portCtrl = TextEditingController(text: p?.portal ?? '');
    pisoCtrl = TextEditingController(text: p?.piso ?? '');
    ptaCtrl = TextEditingController(text: p?.puerta ?? '');

    calleSeleccionadaId = p?.calleId;
    grupoId = p?.grupoId;
    esAnunciante = p?.anunciante ?? widget.forcedAnunciante;

    Future.microtask(() {
      ref.read(provinciasProvider.notifier).cargarProvincias();
      ref.read(localidadesProvider.notifier).cargarLocalidades();
      ref.read(codigosPostalesProvider.notifier).cargarCodigosPostales();
     
      if (p != null) _inicializarUbicacionEdicion(p);
    });
  }

  void _inicializarUbicacionEdicion(Proveedor p) {
    if (p.calleId == null) return;
    final calles = ref.read(callesProvider).value ?? [];
    try {
      final calle = calles.firstWhere((c) => c.id == p.calleId);
      _autocompletarDesdeCalle(calle);
    } catch (_) {
      setState(() => calleCtrl.text = p.calleNombre ?? '');
    }
  }

  void _abrirSelectorCalle() async {
    final result = await showSearch(
        context: context, delegate: CalleSearchDelegate(ref: ref));
    if (result == null) return;
    if (result is Calle) {
      _autocompletarDesdeCalle(result);
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

  // --- GUARDADO ---
  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final datos = {
      if (widget.proveedorAEditar != null) "id": widget.proveedorAEditar!.id,
      "cod_proveedor": codCtrl.text.trim(),
      "nombre": nomCtrl.text.trim(),
      "contacto": contCtrl.text.trim(),
      "telefono": telCtrl.text.trim(),
      "email": emaCtrl.text.trim(),
      "anunciante": esAnunciante,
      "grupo_id": grupoId, 
      "observaciones": obsCtrl.text.trim(),
      "calle_id": calleSeleccionadaId,
      "numero": numCtrl.text.trim(),
      "escalera": escCtrl.text.trim(),
      "bloque": bloqCtrl.text.trim(),
      "portal": portCtrl.text.trim(),
      "piso": pisoCtrl.text.trim(),
      "puerta": ptaCtrl.text.trim(),
    };

    final bool success = (widget.proveedorAEditar == null)
        ? await ref.read(proveedoresProvider.notifier).crear(datos)
        : await ref.read(proveedoresProvider.notifier).actualizar(datos);

    if (mounted && success) context.pop();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PlantillaWrapper(
      isLoading: _isLoading,
      title: widget.proveedorAEditar != null
          ? 'Ficha de Proveedor'
          : 'Nuevo Proveedor',
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCard(title: 'DATOS DE REGISTRO', children: [
              _buildRow('Código', _textFormField(codCtrl, required: true)),
              _buildRow('Nombre', _textFormField(nomCtrl, required: true)),
              _buildRow('Grupo', _grupoDropdown()), // Dropdown dinámico
              _buildRow(
                  '¿Anunciante?',
                  Switch(
                    value: esAnunciante,
                    onChanged: (v) => setState(() => esAnunciante = v),
                    activeColor: colors.primary,
                  )),
            ]),

            // SECCIÓN: CONTACTO
            _buildCard(title: 'DATOS DE CONTACTO', children: [
              _buildRow('Contacto', _textFormField(contCtrl)),
              _buildRow('Teléfono', _textFormField(telCtrl, isNumber: true)),
              _buildRow('Email', _textFormField(emaCtrl, isEmail: true)),
            ]),

            // SECCIÓN: UBICACIÓN (Fondo blanco, estilo Hermanos)
            _buildCard(title: 'UBICACIÓN PRINCIPAL', children: [
              _buildRow('Calle', _calleSelectorField()),
              const Divider(height: 30),
              _buildRow('Provincia', _provinciaDropdown()),
              if (provinciaId != null)
                _buildRow('Localidad', _localidadDropdown()),
              if (localidadId != null) _buildRow('CP', _cpDropdown()),
              const Divider(height: 30),
              _buildRow(
                  'Nº / Pta',
                  Row(children: [
                    Expanded(child: _textFormField(numCtrl, hint: 'Número')),
                    const SizedBox(width: 8),
                    Expanded(child: _textFormField(ptaCtrl, hint: 'Puerta')),
                  ])),
              _buildRow(
                  'Piso / Esc.',
                  Row(children: [
                    Expanded(child: _textFormField(pisoCtrl, hint: 'Piso')),
                    const SizedBox(width: 8),
                    Expanded(child: _textFormField(escCtrl, hint: 'Escalera')),
                  ])),
              _buildRow(
                  'Bloque / Portal',
                  Row(children: [
                    Expanded(child: _textFormField(bloqCtrl, hint: 'Bloque')),
                    const SizedBox(width: 8),
                    Expanded(child: _textFormField(portCtrl, hint: 'Portal')),
                  ])),
            ]),

            // SECCIÓN: NOTAS
            _buildCard(title: 'OBSERVACIONES', children: [
              const SizedBox(height: 8),
              _textFormField(obsCtrl,
                  maxLines: 4, hint: 'Notas adicionales sobre el proveedor...'),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE COMPONENTES ---
  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                fontSize: 11,
                letterSpacing: 1.1)),
        const Divider(height: 25),
        ...children
      ]),
    );
  }

  Widget _buildRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(
            flex: 3,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.black54))),
        Expanded(flex: 7, child: child),
      ]),
    );
  }

  Widget _textFormField(TextEditingController ctrl,
      {bool required = false,
      bool isNumber = false,
      bool isEmail = false,
      int maxLines = 1,
      String? hint}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13),
      keyboardType: isNumber
          ? TextInputType.number
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade100)),
      ),
      validator: (v) =>
          (required && (v == null || v.isEmpty)) ? 'Requerido' : null,
    );
  }

  Widget _calleSelectorField() {
    return TextFormField(
      controller: calleCtrl,
      readOnly: true,
      onTap: _abrirSelectorCalle,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
          suffixIcon: const Icon(Icons.search, size: 20),
          hintText: 'Buscar calle...',
          isDense: true,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200))),
      validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
    );
  }

  // --- DROPDOWNS DINÁMICOS ---

  Widget _grupoDropdown() {
    final gruposAsync = ref.watch(gruposProveedorProvider);
    return gruposAsync.when(
      data: (lista) => DropdownButtonFormField<int>(
        value: lista.any((g) => g.id == grupoId) ? grupoId : null,
        isExpanded: true,
        items: lista
            .map((g) => DropdownMenuItem(
                value: g.id,
                child: Text(g.nombre, style: const TextStyle(fontSize: 13))))
            .toList(),
        onChanged: (v) => setState(() => grupoId = v),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          hintText: 'Seleccionar...',
        ),
        validator: (v) => v == null ? 'Obligatorio' : null,
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error al cargar'),
    );
  }

  // Dropdowns de Ubicación (Idénticos a Hermanos)
  Widget _provinciaDropdown() => ref.watch(provinciasProvider).when(
        data: (list) => DropdownButtonFormField<int>(
          value: provinciaId,
          items: list
              .map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(p.nombreProvincia,
                      style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: (v) {
            setState(() {
              provinciaId = v;
              localidadId = null;
              cpId = null;
            });
          },
          decoration: const InputDecoration(
              labelText: 'Provincia',
              isDense: true,
              border: OutlineInputBorder()),
        ),
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text('Error'),
      );

  Widget _localidadDropdown() => ref.watch(localidadesProvider).when(
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
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) {
              setState(() {
                localidadId = v;
                cpId = null;
              });
            },
            decoration: const InputDecoration(
                labelText: 'Localidad',
                isDense: true,
                border: OutlineInputBorder()),
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
            value: filtrados.any((c) => c.id == cpId) ? cpId : null,
            items: filtrados
                .map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) {
              setState(() => cpId = v);
            },
            decoration: const InputDecoration(
                labelText: 'CP', isDense: true, border: OutlineInputBorder()),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text('Error'),
      );
}
