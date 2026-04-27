import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:morenitapp/shared/widgets/calle_search_delegate.dart';
import 'package:morenitapp/shared/widgets/plantilla_formularios.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/organizador.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';

class NuevoOrganizador extends ConsumerStatefulWidget {
  final Organizador? organizadorAEditar;
  const NuevoOrganizador({super.key, this.organizadorAEditar});

  @override
  ConsumerState<NuevoOrganizador> createState() => _NuevoOrganizadorState();
}

class _NuevoOrganizadorState extends ConsumerState<NuevoOrganizador> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Ubicación IDs
  int? provinciaId, localidadId, cpId, calleSeleccionadaId;

  // Controladores
  late TextEditingController cifCtrl,
      nombreCtrl,
      telefonoCtrl,
      emailCtrl,
      calleCtrl,
      pisoCtrl,
      puertaCtrl;

  // Imágenes (Base64 strings para Odoo)
  String? logoB64, firmaPresiB64, firmaSecB64, firmaTesB64;

  @override
  void initState() {
    super.initState();
    final o = widget.organizadorAEditar;

    cifCtrl = TextEditingController(text: o?.cif ?? '');
    nombreCtrl = TextEditingController(text: o?.nombre ?? '');
    telefonoCtrl = TextEditingController(text: o?.telefono ?? '');
    emailCtrl = TextEditingController(text: o?.email ?? '');
    calleCtrl = TextEditingController(text: o?.direccionName ?? '');
    pisoCtrl = TextEditingController(text: o?.piso ?? '');
    puertaCtrl = TextEditingController(text: o?.puerta ?? '');
    
    // Inicializar imágenes si existen
    logoB64 = o?.logo;
    firmaPresiB64 = o?.firmaPresidente;
    firmaSecB64 = o?.firmaSecretario;
    firmaTesB64 = o?.firmaTesorero;

    Future.microtask(() async {
      await ref.read(provinciasProvider.notifier).cargarProvincias();
      await ref.read(localidadesProvider.notifier).cargarLocalidades();
      await ref.read(codigosPostalesProvider.notifier).cargarCodigosPostales();

      if (o != null && o.direccionId != null) {
        setState(() => calleSeleccionadaId = o.direccionId);
        _inicializarUbicacionEdicion(o.direccionId!);
      }
    });
  }

  // --- LÓGICA DE IMÁGENES ---
  Future<void> _pickImage(String tipo) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      final String base64Image = base64Encode(bytes);
      setState(() {
        if (tipo == 'logo') logoB64 = base64Image;
        if (tipo == 'presi') firmaPresiB64 = base64Image;
        if (tipo == 'sec') firmaSecB64 = base64Image;
        if (tipo == 'tes') firmaTesB64 = base64Image;
      });
    }
  }

  // --- LÓGICA DE UBICACIÓN (Igual a NuevoHermano) ---
  void _abrirSelectorCalle() async {
    final resultado = await showSearch(context: context, delegate: CalleSearchDelegate(ref: ref));
    if (resultado is Calle) _autocompletarDesdeCalle(resultado);
  }

  void _autocompletarDesdeCalle(Calle calle) {
    final listaCPs = ref.read(codigosPostalesProvider).value ?? [];
    final listaLocs = ref.read(localidadesProvider).value ?? [];
    try {
      final cp = listaCPs.firstWhere((c) => c.id == calle.codPostalId);
      final loc = listaLocs.firstWhere((l) => l.id == calle.localidadId);
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

  void _inicializarUbicacionEdicion(int id) {
    final calles = ref.read(callesProvider).value ?? [];
    final calle = calles.firstWhere((c) => c.id == id, orElse: () => Calle(id: 0, nombreCalle: '', localidadId: 0, codPostalId: 0));
    if (calle.id != 0) _autocompletarDesdeCalle(calle);
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> datos = {
        "cif": cifCtrl.text.trim(),
        "nombre": nombreCtrl.text.trim(),
        "telefono": telefonoCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "direccion_id": calleSeleccionadaId,
        "piso": pisoCtrl.text.trim(),
        "puerta": puertaCtrl.text.trim(),
        "logo": logoB64,
        "firma_presidente": firmaPresiB64,
        "firma_secretario": firmaSecB64,
        "firma_tesorero": firmaTesB64,
      };

      if (widget.organizadorAEditar == null) {
        await ref.read(organizadoresProvider.notifier).crear(datos);
      } else {
        await ref.read(organizadoresProvider.notifier).editar(widget.organizadorAEditar!.id, datos);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Guardado correctamente'), backgroundColor: Colors.green));
        context.pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String error) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Error'), content: Text(error), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ok'))]));
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;

    return PlantillaWrapper(
      isLoading: _isLoading,
      title: widget.organizadorAEditar != null ? 'Editar Organizador' : 'Nuevo Organizador',
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCard(title: 'IDENTIFICACIÓN Y CONTACTO', children: [
              _buildRow('Logo Entidad', _imagePickerBox(logoB64, () => _pickImage('logo'), isCircle: true)),
              _buildRow('CIF', _textFormField(cifCtrl, required: true)),
              _buildRow('Nombre', _textFormField(nombreCtrl, required: true)),
              _buildRow('Teléfono', _textFormField(telefonoCtrl, isNumber: true)),
              _buildRow('Email', _textFormField(emailCtrl, isEmail: true)),
            ]),

            _buildCard(title: 'UBICACIÓN', children: [
              _buildRow('Calle', _calleSelectorField()),
              const Divider(),
              _buildRow('Provincia', _provinciaDropdown()),
              if (provinciaId != null) _buildRow('Localidad', _localidadDropdown()),
              if (localidadId != null) _buildRow('C.P.', _cpDropdown()),
              _buildRow('Piso/Puerta', Row(children: [
                Expanded(child: _textFormField(pisoCtrl, hint: 'Piso')),
                const SizedBox(width: 10),
                Expanded(child: _textFormField(puertaCtrl, hint: 'Puerta')),
              ])),
            ]),

            _buildCard(title: 'FIRMAS AUTORIZADAS', children: [
              const Text('Presidencia y Secretaría', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _signatureBox('Firma Presidente', firmaPresiB64, () => _pickImage('presi')),
                  _signatureBox('Firma Secretario', firmaSecB64, () => _pickImage('sec')),
                ],
              ),
              const Divider(height: 30),
              const Text('Tesorería', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Center(child: _signatureBox('Firma Tesorero', firmaTesB64, () => _pickImage('tes'))),
            ]),

            const SizedBox(height: 24),
            _buildSubmitButton(primary, widget.organizadorAEditar != null),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE IMAGEN ---

  Widget _imagePickerBox(String? b64, VoidCallback onTap, {bool isCircle = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80, width: 80,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: isCircle ? null : BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300)
        ),
        child: b64 != null 
          ? ClipRRect(
              borderRadius: BorderRadius.circular(isCircle ? 100 : 8),
              child: Image.memory(base64Decode(b64), fit: BoxFit.cover))
          : const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
      ),
    );
  }

  Widget _signatureBox(String label, String? b64, VoidCallback onTap) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 100, width: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8)
            ),
            child: b64 != null 
              ? Image.memory(base64Decode(b64), fit: BoxFit.contain)
              : const Icon(Icons.gesture, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // --- REUTILIZACIÓN DE COMPONENTES DE TU PLANTILLA ---

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0, color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 11)),
          const Divider(), ...children
        ]),
      ),
    );
  }

  Widget _buildRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54))),
        Expanded(flex: 5, child: child),
      ]),
    );
  }

  Widget _textFormField(TextEditingController ctrl, {bool required = false, bool isNumber = false, bool isEmail = false, String? hint}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isEmail ? TextInputType.emailAddress : (isNumber ? TextInputType.number : TextInputType.text),
      validator: (val) => (required && (val == null || val.isEmpty)) ? 'Obligatorio' : null,
      decoration: InputDecoration(hintText: hint, isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget _calleSelectorField() {
    return TextFormField(
      controller: calleCtrl, readOnly: true, onTap: _abrirSelectorCalle,
      validator: (val) => (val == null || val.isEmpty) ? 'Obligatorio' : null,
      decoration: InputDecoration(suffixIcon: const Icon(Icons.search), hintText: 'Buscar calle...', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  // Los dropdowns de provincia/localidad/cp se mantienen igual que en NuevoHermano...
  Widget _provinciaDropdown() => ref.watch(provinciasProvider).when(
    data: (list) => DropdownButtonFormField<int>(
      value: provinciaId,
      items: list.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))).toList(),
      onChanged: (v) => setState(() { provinciaId = v; localidadId = null; cpId = null; }),
      decoration: const InputDecoration(labelText: 'Provincia', isDense: true, border: OutlineInputBorder()),
    ),
    loading: () => const LinearProgressIndicator(),
    error: (_, __) => const Text('Error'),
  );

  Widget _localidadDropdown() => ref.watch(localidadesProvider).when(
    data: (list) {
      final filtradas = list.where((l) => l.codProvinciaId == provinciaId).toList();
      return DropdownButtonFormField<int>(
        value: filtradas.any((l) => l.id == localidadId) ? localidadId : null,
        items: filtradas.map((l) => DropdownMenuItem(value: l.id, child: Text(l.nombreLocalidad, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (v) => setState(() { localidadId = v; cpId = null; }),
        decoration: const InputDecoration(labelText: 'Localidad', isDense: true, border: OutlineInputBorder()),
      );
    },
    loading: () => const LinearProgressIndicator(),
    error: (_, __) => const Text('Error'),
  );

  Widget _cpDropdown() => ref.watch(codigosPostalesProvider).when(
    data: (list) {
      final filtrados = list.where((c) => c.localidadId == localidadId).toList();
      return DropdownButtonFormField<int>(
        value: filtrados.any((c) => c.id == cpId) ? cpId : null,
        items: filtrados.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
        onChanged: (v) => setState(() => cpId = v),
        decoration: const InputDecoration(labelText: 'C.P.', isDense: true, border: OutlineInputBorder()),
      );
    },
    loading: () => const LinearProgressIndicator(),
    error: (_, __) => const Text('Error'),
  );

  Widget _buildSubmitButton(Color color, bool esEdicion) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: _isLoading ? null : _onSave,
        child: Text(esEdicion ? 'GUARDAR CAMBIOS' : 'REGISTRAR ORGANIZADOR', style: const TextStyle(color: Colors.white)),
      ));
  }
}