import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:morenitapp/shared/widgets/plantilla_formularios.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/evento.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';

class NuevoEvento extends ConsumerStatefulWidget {
  final Evento? eventoAEditar;
  const NuevoEvento({super.key, this.eventoAEditar});

  @override
  ConsumerState<NuevoEvento> createState() => _NuevoEventoState();
}

class _NuevoEventoState extends ConsumerState<NuevoEvento> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController codCtrl, nombreCtrl, lugarCtrl, descripcionCtrl;

  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now().add(const Duration(hours: 2));

  int? _tipoEventoId;
  int? _organizadorId;

  @override
  void initState() {
    super.initState();
    final e = widget.eventoAEditar;

    codCtrl = TextEditingController(text: e?.codEvento ?? '');
    nombreCtrl = TextEditingController(text: e?.nombre ?? '');
    lugarCtrl = TextEditingController(text: e?.lugar ?? '');
    descripcionCtrl = TextEditingController(text: e?.descripcion ?? '');

    if (e != null) {
      _fechaInicio = e.fechaInicio;
      _fechaFin = e.fechaFin;
      _tipoEventoId = e.tipoEventoId;
      _organizadorId = e.organizadorId;
    }
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaFin.isBefore(_fechaInicio)) {
      _showErrorDialog("La fecha fin no puede ser anterior al inicio");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final datos = {
        "cod_evento": codCtrl.text.trim(),
        "nombre": nombreCtrl.text.trim(),
        "lugar": lugarCtrl.text.trim(),
        "descripcion": descripcionCtrl.text.trim(),

        // Odoo prefiere formato YYYY-MM-DD HH:MM:SS
        "fecha_inicio": DateFormat('yyyy-MM-dd HH:mm:ss').format(_fechaInicio),
        "fecha_fin": DateFormat('yyyy-MM-dd HH:mm:ss').format(_fechaFin),

        "organizador_id": _organizadorId,
        "tipoevento_id": _tipoEventoId,
      };

      if (widget.eventoAEditar == null) {
        await ref.read(eventosProvider.notifier).crear(datos);
      } else {
        await ref
            .read(eventosProvider.notifier)
            .editar(widget.eventoAEditar!.id, datos);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento guardado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;
    final organizadoresAsync = ref.watch(organizadoresProvider);

    return PlantillaWrapper(
      isLoading: _isLoading,
      title: widget.eventoAEditar != null ? 'Editar Evento' : 'Nuevo Evento',
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // 🔹 INFO GENERAL
            _buildCard(title: 'INFORMACIÓN GENERAL', children: [
              _buildRow('Código', _textFormField(codCtrl, required: true)),
              _buildRow('Nombre', _textFormField(nombreCtrl, required: true)),
              _buildRow('Lugar', _textFormField(lugarCtrl)),
              _buildRow(
                'Organizador',
                organizadoresAsync.when(
                  data: (lista) {
                    // VALIDACIÓN CRÍTICA:
                    // Si el ID seleccionado no existe en la lista que llegó, lo ponemos en null
                    // para evitar que la app explote.
                    final bool existeId =
                        lista.any((o) => o.id == _organizadorId);
                    final int? valorSeguro = existeId ? _organizadorId : null;

                    return DropdownButtonFormField<int>(
                      value: valorSeguro, // Usamos el valor validado
                      isExpanded: true,
                      items: lista
                          .map((o) => DropdownMenuItem(
                              value: o.id, child: Text(o.nombre)))
                          .toList(),
                      onChanged: (v) => setState(() => _organizadorId = v),
                      decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text("Error al cargar"),
                ),
              ),
              _buildRow(
                'Tipo Evento',
                DropdownButtonFormField<int>(
                  // VALIDACIÓN: Si _tipoEventoId es 3 y no está en la lista de abajo, fallará.
                  // Aquí agregamos el 3 o validamos que sea null si no es 1 o 2.
                  value: (_tipoEventoId == 1 || _tipoEventoId == 2)
                      ? _tipoEventoId
                      : null,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Culto")),
                    DropdownMenuItem(value: 2, child: Text("Procesión")),
                    // Si en tu base de datos existe el ID 3, deberías agregarlo aquí:
                    // DropdownMenuItem(value: 3, child: Text("Otro")),
                  ],
                  onChanged: (v) => setState(() => _tipoEventoId = v),
                  decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ),
            ]),

            // 🔹 FECHAS
            _buildCard(title: 'PROGRAMACIÓN', children: [
              _buildRow('Inicio', _datePicker(true)),
              const Divider(),
              _buildRow('Fin', _datePicker(false)),
            ]),

            // 🔹 DESCRIPCIÓN
            _buildCard(title: 'DESCRIPCIÓN ADICIONAL', children: [
              const SizedBox(height: 8),
              _textFormField(descripcionCtrl,
                  maxLines: 4, hint: 'Escribe detalles del evento...'),
            ]),

            const SizedBox(height: 24),
            _buildSubmitButton(primary, widget.eventoAEditar != null),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES VISUALES ADAPTADOS ---

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    fontSize: 11)),
            const Divider(),
            ...children
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(fontSize: 13, color: Colors.black54))),
          Expanded(flex: 5, child: child),
        ],
      ),
    );
  }

  Widget _textFormField(TextEditingController ctrl,
      {bool required = false, int maxLines = 1, String? hint}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      validator: (v) =>
          required && (v == null || v.isEmpty) ? "Obligatorio" : null,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _datePicker(bool inicio) {
    final fecha = inicio ? _fechaInicio : _fechaFin;
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: fecha,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date == null) return;

        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(fecha),
        );
        if (time == null) return;

        setState(() {
          final nueva =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
          if (inicio) {
            _fechaInicio = nueva;
          } else {
            _fechaFin = nueva;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd/MM/yyyy HH:mm').format(fecha),
                style: const TextStyle(fontSize: 14)),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Color color, bool esEdicion) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _isLoading ? null : _onSave,
        child: Text(
          esEdicion ? 'GUARDAR CAMBIOS' : 'CREAR EVENTO',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
