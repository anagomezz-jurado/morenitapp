import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/screens/calle_search_delegate.dart';
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

  // IDs para Odoo
  int? direccionId;
  int? provinciaId, localidadId;

  // Controladores
  final cifCtrl = TextEditingController();
  final nomCtrl = TextEditingController();
  final fundCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telCtrl = TextEditingController();
  final webCtrl = TextEditingController();
  final obsCtrl = TextEditingController();
  final calleNameCtrl = TextEditingController();
  final puertaCtrl = TextEditingController();
  final pisoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.cofradiaAEditar != null) {
      final c = widget.cofradiaAEditar!;
      cifCtrl.text = c.cif;
      nomCtrl.text = c.nombre;
      fundCtrl.text = c.fundacion.toString();
      emailCtrl.text = c.email;
      telCtrl.text = c.telefono;
      webCtrl.text = c.web;
      obsCtrl.text = c.observaciones;
      calleNameCtrl.text = c.direccionName ?? '';
      puertaCtrl.text = c.puerta;
      pisoCtrl.text = c.piso;
      direccionId = c.direccionId;
      localidadId = c.localidadId;
      
      _inicializarUbicaciones();
    } else {
      // Si es nueva, cargamos las provincias por defecto
      _cargarDatosBase();
    }
  }

  void _cargarDatosBase() {
    Future.microtask(() => ref.read(provinciasProvider.notifier).cargarProvincias());
  }

  void _inicializarUbicaciones() {
    Future.microtask(() async {
      await ref.read(provinciasProvider.notifier).cargarProvincias();
      await ref.read(localidadesProvider.notifier).cargarLocalidades();
      
      if (localidadId != null) {
        final locs = ref.read(localidadesProvider).value;
        final loc = locs?.where((l) => l.id == localidadId).firstOrNull;
        if (loc != null) {
          setState(() => provinciaId = loc.codProvinciaId);
        }
      }
    });
  }

  @override
  void dispose() {
    cifCtrl.dispose(); nomCtrl.dispose(); fundCtrl.dispose();
    emailCtrl.dispose(); telCtrl.dispose(); webCtrl.dispose();
    obsCtrl.dispose(); calleNameCtrl.dispose(); puertaCtrl.dispose();
    pisoCtrl.dispose();
    super.dispose();
  }

  void _abrirSelectorCalle() async {
    final resultado = await showSearch(
      context: context, 
      delegate: CalleSearchDelegate(ref: ref)
    );
    
    if (resultado is Calle) {
      final locs = ref.read(localidadesProvider).value ?? [];
      final loc = locs.where((l) => l.id == resultado.localidadId).firstOrNull;

      setState(() {
        // En Calle entity el ID suele ser String, convertimos a int para Odoo
        direccionId = int.tryParse(resultado.id.toString());
        calleNameCtrl.text = resultado.nombreCalle;
        localidadId = resultado.localidadId;
        provinciaId = loc?.codProvinciaId;
      });
    }
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'cifCofradia': cifCtrl.text.trim(),
      'nombreCofradia': nomCtrl.text.trim(),
      'antiguedadCofradia': int.tryParse(fundCtrl.text) ?? 0,
      'emailCofradia': emailCtrl.text.trim(),
      'telefonoCofradia': telCtrl.text.trim(),
      'paginaWeb': webCtrl.text.trim(),
      'observaciones': obsCtrl.text.trim(),
      'direccion_id': direccionId,
      'puerta': puertaCtrl.text.trim(),
      'piso': pisoCtrl.text.trim(),
      'localidad_id': localidadId,
    };

    if (widget.cofradiaAEditar != null) {
      data['id'] = int.tryParse(widget.cofradiaAEditar!.id);
    }

    try {
      await ref.read(cofradiasProvider.notifier).guardar(data);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlantillaWrapper(
      title: widget.cofradiaAEditar == null ? 'Nueva Cofradía' : 'Editar Cofradía',
      isLoading: _isLoading,
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCard(title: 'DATOS GENERALES', children: [
                _buildRow('CIF *', _field(cifCtrl, required: true)),
                _buildRow('Nombre *', _field(nomCtrl, required: true)),
              ]),

              _buildCard(title: 'LOCALIZACIÓN', children: [
                _buildRow('Calle *', _calleField()),
                _buildRow('Provincia', _provinciaDropdown()),
                if (provinciaId != null) _buildRow('Localidad', _localidadDropdown()),
                _buildRow('Piso/Pta', Row(children: [
                  Expanded(child: _field(pisoCtrl, hint: 'Piso')),
                  const SizedBox(width: 8),
                  Expanded(child: _field(puertaCtrl, hint: 'Puerta')),
                ])),
              ]),

              _buildCard(title: 'CONTACTO', children: [
                _buildRow('Teléfono', _field(telCtrl, isNum: true)),
                _buildRow('Email', _field(emailCtrl, isEmail: true)),
                _buildRow('Página Web', _field(webCtrl)),
              ]),

              _buildCard(title: 'INFORMACIÓN ADICIONAL', children: [
                _buildRow('Año Fundación', _field(fundCtrl, isNum: true)),
                _buildRow('Observaciones', _field(obsCtrl, maxLines: 3, hint: 'Escribe aquí...')),
              ]),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets de Interfaz ---

  Widget _calleField() => TextFormField(
    controller: calleNameCtrl,
    readOnly: true,
    onTap: _abrirSelectorCalle,
    validator: (v) => (direccionId == null) ? 'Seleccione una calle' : null,
    decoration: InputDecoration(
      suffixIcon: const Icon(Icons.search, size: 20),
      isDense: true, 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      hintText: 'Buscar calle...'
    ),
  );

  Widget _provinciaDropdown() => ref.watch(provinciasProvider).when(
    data: (list) => DropdownButtonFormField<int>(
      value: provinciaId,
      isExpanded: true,
      items: list.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))).toList(),
      onChanged: (v) => setState(() { provinciaId = v; localidadId = null; }),
      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
    ),
    loading: () => const LinearProgressIndicator(),
    error: (_, __) => const Text('Error al cargar provincias'),
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
        validator: (v) => v == null ? 'Requerido' : null,
      );
    },
    loading: () => const LinearProgressIndicator(),
    error: (_, __) => const Text('Error al cargar localidades'),
  );

  Widget _buildCard({required String title, required List<Widget> children}) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 0, color: Colors.white,
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
      Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 13))),
      Expanded(flex: 5, child: child),
    ]),
  );

  Widget _field(TextEditingController c, {bool required = false, bool isNum = false, bool isEmail = false, String? hint, int maxLines = 1}) => TextFormField(
    controller: c,
    maxLines: maxLines,
    keyboardType: isNum ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
    validator: (v) => (required && (v == null || v.trim().isEmpty)) ? 'Requerido' : null,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      hintText: hint, 
      isDense: true, 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
    ),
  );
}