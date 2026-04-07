import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/calle_search_delegate.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';

class NuevoHermano extends ConsumerStatefulWidget {
  final Hermano? hermanoAEditar;
  const NuevoHermano({super.key, this.hermanoAEditar});

  @override
  ConsumerState<NuevoHermano> createState() => _NuevoHermanoState();
}

class _NuevoHermanoState extends ConsumerState<NuevoHermano> {
  final _formKey = GlobalKey<FormState>();

  String sexo = 'Hombre';
  String metodoPago = 'Metálico';
  bool esResponsable = false;
  DateTime fechaAltaDate = DateTime.now();
  DateTime? fechaNacimientoDate;
  int? calleSeleccionadaId;

  late TextEditingController numeroCtrl, nombreCtrl, apellido1Ctrl, apellido2Ctrl,
      dniCtrl, emailCtrl, telefonoCtrl, calleCtrl, pisoCtrl, puertaCtrl;
  late TextEditingController bancoCtrl, sucursalCtrl, cuentaCtrl;

  @override
  void initState() {
    super.initState();
    final h = widget.hermanoAEditar;

    numeroCtrl = TextEditingController(text: h?.numeroHermano.toString() ?? '');
    nombreCtrl = TextEditingController(text: h?.nombre ?? '');
    apellido1Ctrl = TextEditingController(text: h?.apellido1 ?? '');
    apellido2Ctrl = TextEditingController(text: h?.apellido2 ?? '');
    dniCtrl = TextEditingController(text: h?.dni ?? '');
    emailCtrl = TextEditingController(text: h?.email ?? '');
    telefonoCtrl = TextEditingController(text: h?.telefono ?? '');
    calleCtrl = TextEditingController(text: h?.calleNombre ?? '');
    pisoCtrl = TextEditingController(text: h?.piso ?? '');
    puertaCtrl = TextEditingController(text: h?.puerta ?? '');

    String b = '', s = '', c = '';
    if (h != null && h.iban.isNotEmpty) {
      final cleanIban = h.iban.replaceAll(' ', '');
      if (cleanIban.length >= 20) {
        b = cleanIban.substring(0, 4);
        s = cleanIban.substring(4, 8);
        c = cleanIban.substring(cleanIban.length - 10);
      } else {
        c = cleanIban;
      }
    }
    bancoCtrl = TextEditingController(text: b);
    sucursalCtrl = TextEditingController(text: s);
    cuentaCtrl = TextEditingController(text: c);

    if (h != null) {
      sexo = h.sexo;
      metodoPago = (h.metodoPago == 'banco' || h.metodoPago == 'Domiciliado') ? 'Domiciliado' : 'Metálico';
      esResponsable = h.responsable;
      calleSeleccionadaId = h.calleId;
      try {
        if (h.fechaAlta.isNotEmpty) fechaAltaDate = DateTime.parse(h.fechaAlta);
        if (h.fechaNacimiento.isNotEmpty && h.fechaNacimiento != "false") {
          fechaNacimientoDate = DateTime.parse(h.fechaNacimiento);
        }
      } catch (_) {}
    } else {
      _cargarSiguienteNumero();
    }
  }

  void _cargarSiguienteNumero() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hermanosListadoProvider).whenData((hermanos) {
        if (hermanos.isNotEmpty && widget.hermanoAEditar == null) {
          final maxNum = hermanos.map((h) => h.numeroHermano).reduce((a, b) => a > b ? a : b);
          numeroCtrl.text = (maxNum + 1).toString();
        }
      });
    });
  }

  // MÉTODO NUEVO: Abre el buscador y setea los valores
  void _abrirSelectorCalle() async {
    final calle = await showSearch<dynamic>(
      context: context,
      delegate: CalleSearchDelegate(ref: ref),
    );

    if (calle != null) {
      setState(() {
        calleSeleccionadaId = calle.id;
        calleCtrl.text = calle.nombreCalle;
      });
    }
  }

  @override
  void dispose() {
    numeroCtrl.dispose(); nombreCtrl.dispose(); apellido1Ctrl.dispose();
    apellido2Ctrl.dispose(); dniCtrl.dispose(); emailCtrl.dispose();
    telefonoCtrl.dispose(); calleCtrl.dispose(); pisoCtrl.dispose();
    puertaCtrl.dispose(); bancoCtrl.dispose(); sucursalCtrl.dispose();
    cuentaCtrl.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) => 
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (metodoPago == 'Domiciliado') {
      if (bancoCtrl.text.length < 4 || sucursalCtrl.text.length < 4 || cuentaCtrl.text.length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete los 20 dígitos bancarios'), backgroundColor: Colors.orange)
        );
        return;
      }
    }

    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (c) => const Center(child: CircularProgressIndicator(color: Color(0xFF714B67)))
    );

    final String ibanFinal = (metodoPago == 'Domiciliado') 
        ? "ES00${bancoCtrl.text}${sucursalCtrl.text}${cuentaCtrl.text}"
        : "";

    final datos = {
      "numero_hermano": int.tryParse(numeroCtrl.text) ?? 0,
      "nombre": nombreCtrl.text.trim(),
      "apellido1": apellido1Ctrl.text.trim(),
      "apellido2": apellido2Ctrl.text.trim(),
      "dni": dniCtrl.text.trim().toUpperCase(),
      "email": emailCtrl.text.trim(),
      "telefono": telefonoCtrl.text.trim(),
      "sexo": sexo,
      "fecha_alta": formatDate(fechaAltaDate),
      "fecha_nacimiento": fechaNacimientoDate != null ? formatDate(fechaNacimientoDate!) : false,
      "metodo_pago": (metodoPago == 'Domiciliado') ? 'banco' : 'metalico',
      "responsable": esResponsable,
      "calle_id": calleSeleccionadaId,
      "piso": pisoCtrl.text.trim(),
      "puerta": puertaCtrl.text.trim(),
      "iban": ibanFinal, 
    };

    try {
      if (widget.hermanoAEditar == null) {
        final nuevoHermano = Hermano.fromJson(datos);
        await ref.read(hermanosListadoProvider.notifier).createHermano(nuevoHermano);
      } else {
        await ref.read(hermanosListadoProvider.notifier).updateHermano(widget.hermanoAEditar!.id!, datos);
      }
      if (mounted) {
        Navigator.pop(context); 
        context.pop(); 
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.hermanoAEditar != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(esEdicion ? 'Modificar Hermano' : 'Nuevo Hermano'),
        actions: [IconButton(onPressed: _onSave, icon: const Icon(Icons.save, color: Color(0xFF714B67)))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCard([
                _sectionTitle('DATOS DE HERMANO'),
                _buildNumberField('Número', numeroCtrl),
                _buildDropdown('Sexo', sexo, ['Hombre', 'Mujer'], (val) => setState(() => sexo = val!)),
                _buildDateField('Fecha Alta', fechaAltaDate, (date) => setState(() => fechaAltaDate = date)),
                _buildCheckbox('Responsable', esResponsable, (val) => setState(() => esResponsable = val!)),
                _buildDropdown('Método Pago', metodoPago, ['Metálico', 'Domiciliado'], (val) => setState(() => metodoPago = val!)),
                if (metodoPago == 'Domiciliado') _buildBankSection(),
              ]),
              const SizedBox(height: 16),
              _buildCard([
                _sectionTitle('DATOS PERSONALES'),
                _buildTextField('Nombre', nombreCtrl, required: true),
                _buildTextField('1º Apellido', apellido1Ctrl, required: true),
                _buildTextField('2º Apellido', apellido2Ctrl),
                _buildTextField('DNI', dniCtrl, required: true),
                _buildTextField('Teléfono', telefonoCtrl),
                _buildTextField('Email', emailCtrl),
              ]),
              const SizedBox(height: 16),
              _buildCard([
                _sectionTitle('DIRECCIÓN'),
                _buildCalleSelector(), // USANDO EL NUEVO SELECTOR
                Row(children: [
                  Expanded(child: _buildTextField('Piso', pisoCtrl)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField('Puerta', puertaCtrl)),
                ]),
              ]),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF714B67),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  onPressed: _onSave,
                  child: Text(esEdicion ? 'GUARDAR CAMBIOS' : 'CREAR HERMANO', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- Helpers de UI Actualizados ---

  Widget _buildCalleSelector() {
    return _baseRow('Calle', TextFormField(
      controller: calleCtrl, 
      readOnly: true, 
      onTap: _abrirSelectorCalle, // Abre el buscador al tocar
      validator: (val) => (val == null || val.isEmpty) ? 'Seleccione una calle' : null,
      decoration: const InputDecoration(
        suffixIcon: Icon(Icons.search, color: Color(0xFF714B67)), 
        isDense: true, 
        border: OutlineInputBorder(),
        hintText: 'Toca para buscar...'
      )
    ));
  }

  // ... (Resto de tus helpers _buildTextField, _buildCard, etc. se mantienen igual)
  Widget _buildBankSection() => Column(children: [
    const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider()), 
    Row(children: [
      Expanded(child: _buildSmallField('Banco', bancoCtrl, 4)), 
      const SizedBox(width: 6),
      Expanded(child: _buildSmallField('Sucursal', sucursalCtrl, 4)), 
      const SizedBox(width: 6),
      Expanded(flex: 2, child: _buildSmallField('Nº Cuenta', cuentaCtrl, 10)),
    ])
  ]);

  Widget _buildSmallField(String label, TextEditingController ctrl, int len) => TextFormField(
    controller: ctrl, maxLength: len, keyboardType: TextInputType.number, 
    inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
    validator: (val) => (metodoPago == 'Domiciliado' && (val == null || val.isEmpty)) ? '*' : null,
    decoration: InputDecoration(labelText: label, counterText: "", isDense: true, border: const OutlineInputBorder())
  );

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false}) {
    return _baseRow(label, TextFormField(
      controller: controller,
      validator: (val) => (required && (val == null || val.isEmpty)) ? 'Obligatorio' : null,
      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
    ));
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return _baseRow(label, TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
    ));
  }

  Widget _buildCard(List<Widget> children) => Container(
    padding: const EdgeInsets.all(16), 
    margin: const EdgeInsets.only(bottom: 12), 
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(8),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
    ), 
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 13)),
  );

  Widget _baseRow(String l, Widget c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6), 
    child: Row(children: [
      Expanded(flex: 2, child: Text(l, style: const TextStyle(fontWeight: FontWeight.w500))), 
      Expanded(flex: 5, child: c)
    ])
  );

  Widget _buildDropdown(String l, String v, List<String> i, Function(String?) o) => _baseRow(l, DropdownButtonFormField(
    value: v, items: i.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
    onChanged: o, decoration: const InputDecoration(isDense: true, border: OutlineInputBorder())
  ));

  Widget _buildCheckbox(String l, bool v, Function(bool?) o) => _baseRow(l, Align(
    alignment: Alignment.centerLeft, child: Checkbox(value: v, onChanged: o, activeColor: const Color(0xFF714B67))
  ));

  Widget _buildDateField(String l, DateTime d, Function(DateTime) o) => _baseRow(l, OutlinedButton.icon(
    onPressed: () async { 
      final p = await showDatePicker(context: context, initialDate: d, firstDate: DateTime(1900), lastDate: DateTime(2100)); 
      if (p != null) o(p); 
    }, 
    icon: const Icon(Icons.calendar_today, size: 16),
    label: Text("${d.day}/${d.month}/${d.year}"),
    style: OutlinedButton.styleFrom(foregroundColor: Colors.black87)
  ));
}