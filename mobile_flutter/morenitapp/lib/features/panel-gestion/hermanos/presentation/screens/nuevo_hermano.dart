import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
// Asumo que tienes un provider para las calles, si no, usa el ID 1 para probar
// import 'package:morenitapp/features/panel-gestion/calles/presentation/providers/calles_provider.dart'; 
import 'package:morenitapp/shared/infrastructure/inputs/inputs.dart';

class NuevoHermano extends ConsumerStatefulWidget {
  const NuevoHermano({super.key});

  @override
  ConsumerState<NuevoHermano> createState() => _NuevoHermanoState();
}

class _NuevoHermanoState extends ConsumerState<NuevoHermano> {
  final _formKey = GlobalKey<FormState>();

  // --- ESTADO ---
  String sexo = 'Hombre';
  String metodoPago = 'Metálico';
  bool esResponsable = false;
  DateTime fechaAltaDate = DateTime.now();
  DateTime? fechaNacimientoDate;
  
  // IMPORTANTE: ID de la calle para Odoo
  int? calleSeleccionadaId; 

  final numeroCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final apellido1Ctrl = TextEditingController();
  final apellido2Ctrl = TextEditingController();
  final dniCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final calleCtrl = TextEditingController(); // Nombre visual
  final pisoCtrl = TextEditingController();
  final puertaCtrl = TextEditingController();
  final ibanCtrl = TextEditingController();
  final sucursalCtrl = TextEditingController();
  final cuentaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hermanos = ref.read(hermanosListadoProvider).value ?? [];
      if (hermanos.isNotEmpty) {
        final maxNum = hermanos
            .map((h) => h.numeroHermano)
            .reduce((a, b) => a > b ? a : b);
        numeroCtrl.text = (maxNum + 1).toString();
      } else {
        numeroCtrl.text = "1";
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    numeroCtrl.dispose(); nombreCtrl.dispose(); apellido1Ctrl.dispose();
    apellido2Ctrl.dispose(); dniCtrl.dispose(); emailCtrl.dispose();
    telefonoCtrl.dispose(); calleCtrl.dispose(); pisoCtrl.dispose();
    puertaCtrl.dispose(); ibanCtrl.dispose(); sucursalCtrl.dispose();
    cuentaCtrl.dispose();
    super.dispose();
  }

  String formatDate(DateTime? date) => (date == null)
      ? ""
      : "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final numeroActual = numeroCtrl.text.isEmpty ? "0" : numeroCtrl.text;
    final letraSexo = (sexo == 'Hombre') ? 'H' : 'M';
    final codigoGenerado = "$numeroActual$letraSexo";

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Nuevo Hermano', style: TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _onSave,
              icon: const Icon(Icons.save, size: 18),
              label: const Text("Guardar"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF714B67),
                  foregroundColor: Colors.white),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCard([
                _sectionTitle('DATOS DE HERMANO'),
                _buildNumberField('Número Hermano', numeroCtrl, (val) => setState(() {})),
                _buildDropdown('Sexo', sexo, ['Hombre', 'Mujer'], (val) => setState(() => sexo = val!)),
                _buildDateField('Fecha Alta', fechaAltaDate, (date) => setState(() => fechaAltaDate = date)),
                _buildReadOnly('Código Generado', codigoGenerado),
                _buildCheckbox('Responsable', esResponsable, (val) => setState(() => esResponsable = val!)),
                _buildDropdown('Método Pago', metodoPago, ['Metálico', 'Domiciliado'], (val) => setState(() => metodoPago = val!)),
                if (metodoPago == 'Domiciliado') ...[
                  const SizedBox(height: 15),
                  _buildBankSection()
                ],
              ]),
              const SizedBox(height: 16),
              _buildCard([
                _sectionTitle('DATOS PERSONALES'),
                _buildTextField('Nombre', nombreCtrl, validator: (v) => GeneralText.dirty(v ?? '').errorMessage),
                _buildTextField('1º Apellido', apellido1Ctrl, validator: (v) => GeneralText.dirty(v ?? '').errorMessage),
                _buildTextField('2º Apellido', apellido2Ctrl),
                _buildTextField('DNI', dniCtrl, validator: (v) => Dni.dirty(v ?? '').errorMessage),
                _buildDateField('Fecha de nacimiento', fechaNacimientoDate, (date) => setState(() => fechaNacimientoDate = date)),
                _buildTextField('Teléfono', telefonoCtrl),
                _buildTextField('Email', emailCtrl, validator: (v) => Email.dirty(v ?? '').errorMessage),
              ]),
              const SizedBox(height: 16),
              _buildCard([
                _sectionTitle('DIRECCIÓN'),
                // CAMBIO CLAVE: Selector de calle
                _buildCalleSelector(), 
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTextField('Piso', pisoCtrl)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTextField('Puerta', puertaCtrl)),
                  ],
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // --- NUEVO HELPER PARA SELECCIONAR CALLE ---
  Widget _buildCalleSelector() {
    return _baseRow('Calle', TextFormField(
      controller: calleCtrl,
      readOnly: true, // Para obligar a elegir de una lista
      onTap: () {
        // Aquí deberías abrir un buscador de calles o un simple diálogo
        // Por ahora, para que te funcione, asignamos un ID manual
        _mostrarSelectorCalle();
      },
      validator: (value) => (calleSeleccionadaId == null) ? 'Seleccione una calle' : null,
      decoration: const InputDecoration(
        hintText: 'Toca para buscar calle...',
        suffixIcon: Icon(Icons.search, size: 20),
      ),
    ));
  }

  void _mostrarSelectorCalle() {
    // ESTO ES TEMPORAL PARA QUE PRUEBES QUE EL ERROR 500 DESAPARECE
    // En el futuro, aquí abres un SearchDelegate o un modal con la lista de calles de Odoo
    setState(() {
      calleCtrl.text = "Calle Ficticia 1"; 
      calleSeleccionadaId = 1; // <--- Pon un ID que exista en tu Odoo
    });
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final datosParaOdoo = {
        "numero_hermano": int.tryParse(numeroCtrl.text) ?? 0,
        "nombre": nombreCtrl.text.trim(),
        "apellido1": apellido1Ctrl.text.trim(),
        "apellido2": apellido2Ctrl.text.trim(),
        "dni": dniCtrl.text.trim().toUpperCase(),
        "email": emailCtrl.text.trim(),
        "telefono": telefonoCtrl.text.trim(),
        "sexo": sexo, 
        "calle_id": calleSeleccionadaId, // EL CAMPO CRÍTICO
        "piso": pisoCtrl.text.trim(),
        "puerta": puertaCtrl.text.trim(),
        "fecha_alta": formatDate(fechaAltaDate),
        "fecha_nacimiento": (fechaNacimientoDate == null) ? false : formatDate(fechaNacimientoDate),
        "metodo_pago": (metodoPago == 'Metálico') ? 'metalico' : 'banco',
        "responsable": esResponsable,
      };

      await ref.read(hermanosListadoProvider.notifier).createHermano(datosParaOdoo);

      if (!mounted) return;
      Navigator.pop(context); // Quitar Loading
      context.pop(); // Volver atrás

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Hermano creado correctamente'),
          backgroundColor: Colors.green));
          
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Quitar Loading
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // --- WIDGET HELPERS (SIN CAMBIOS SIGNIFICATIVOS) ---

  Widget _buildCard(List<Widget> children) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _sectionTitle(String title) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
        const Divider(),
        const SizedBox(height: 8),
      ]);

  Widget _buildNumberField(String label, TextEditingController ctrl, Function(String) onChanged) =>
      _baseRow(label, TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
          ));

  Widget _buildTextField(String label, TextEditingController ctrl, {String? Function(String?)? validator}) =>
      _baseRow(label, TextFormField(controller: ctrl, validator: validator, decoration: const InputDecoration(isDense: true)));

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) =>
      _baseRow(label, DropdownButtonFormField<String>(
            value: value,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero),
          ));

  Widget _buildReadOnly(String label, String value) => _baseRow(label, Text(value,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF714B67), fontSize: 16)));

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) =>
      _baseRow(label, Checkbox(value: value, onChanged: onChanged, activeColor: const Color(0xFF714B67)));

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onSel) =>
      _baseRow(label, InkWell(
            onTap: () async {
              final p = await showDatePicker(
                  context: context,
                  initialDate: date ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100));
              if (p != null) onSel(p);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date == null ? 'Seleccionar...' : "${date.day}/${date.month}/${date.year}"),
                    const Icon(Icons.calendar_today, size: 16),
                  ]),
            ),
          ));

  Widget _buildBankSection() => Column(children: [
        const Text("DATOS BANCARIOS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _miniField('IBAN', ibanCtrl, 4)),
          const SizedBox(width: 4),
          Expanded(child: _miniField('Suc.', sucursalCtrl, 4)),
          const SizedBox(width: 4),
          Expanded(flex: 2, child: _miniField('Cuenta', cuentaCtrl, 10)),
        ])
      ]);

  Widget _miniField(String h, TextEditingController c, int l) => TextFormField(
      controller: c, maxLength: l,
      decoration: InputDecoration(hintText: h, counterText: "", isDense: true, border: const OutlineInputBorder()));

  Widget _baseRow(String l, Widget c) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(flex: 2, child: Text(l, style: const TextStyle(fontSize: 13))),
        Expanded(flex: 5, child: c)
      ]));
}