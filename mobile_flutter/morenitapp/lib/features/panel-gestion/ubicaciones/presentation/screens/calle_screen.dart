import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';

class CallesGestionScreen extends ConsumerStatefulWidget {
  const CallesGestionScreen({super.key});

  @override
  ConsumerState<CallesGestionScreen> createState() => _CallesGestionScreenState();
}

class _CallesGestionScreenState extends ConsumerState<CallesGestionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  int? idProvincia, idLocalidad, idCP;
  final TextEditingController nombreCalleCtrl = TextEditingController();

  void _limpiarFormulario() {
    idProvincia = null; idLocalidad = null; idCP = null;
    nombreCalleCtrl.clear();
    ref.read(provinciaFiltroSeleccionadaProvider.notifier).state = null;
    ref.read(localidadFiltroSeleccionadaProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final callesAsync = ref.watch(callesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text('Configuración de Calles', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              _limpiarFormulario();
              _mostrarFormularioCalle(context);
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 30),
          )
        ],
      ),
      body: callesAsync.when(
        data: (calles) => ListView.separated(
          itemCount: calles.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final calle = calles[index];
            return ListTile(
              tileColor: Colors.white,
              leading: const CircleAvatar(child: Icon(Icons.map)),
              title: Text(calle.nombreCalle, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('ID: ${calle.id}'),
              onTap: () => _mostrarFormularioCalle(context, calleEdit: calle), // EDITAR
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmarEliminacion(context, calle),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _mostrarFormularioCalle(BuildContext context, {dynamic calleEdit}) {
    if (calleEdit != null) {
      // Si editamos, cargamos los valores actuales
      nombreCalleCtrl.text = calleEdit.nombreCalle;
      idLocalidad = calleEdit.localidadId;
      idCP = calleEdit.codPostalId;
      // Nota: idProvincia debe inferirse o manejarse según tu lógica de providers
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final provincias = ref.watch(provinciasProvider);
            final localidades = ref.watch(localidadesFiltradasProvider);
            final cps = ref.watch(codigosPostalesFiltradosProvider);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20, right: 20, top: 20
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(calleEdit == null ? "Nueva Calle" : "Editar Calle", 
                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    
                    // PROVINCIA
                    provincias.when(
                      data: (lista) => DropdownButtonFormField<int>(
                        value: idProvincia,
                        decoration: const InputDecoration(labelText: 'Provincia'),
                        items: lista.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))).toList(),
                        onChanged: (val) {
                          setModalState(() { idProvincia = val; idLocalidad = null; idCP = null; });
                          ref.read(provinciaFiltroSeleccionadaProvider.notifier).state = val;
                        },
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text("Error provincias"),
                    ),
                    
                    // LOCALIDAD
                    DropdownButtonFormField<int>(
                      value: idLocalidad,
                      decoration: const InputDecoration(labelText: 'Localidad'),
                      items: idProvincia == null ? [] : localidades.maybeWhen(
                        data: (lista) => lista.map((l) => DropdownMenuItem(value: l.id, child: Text(l.nombreLocalidad))).toList(),
                        orElse: () => [],
                      ),
                      onChanged: (val) {
                        setModalState(() { idLocalidad = val; idCP = null; });
                        ref.read(localidadFiltroSeleccionadaProvider.notifier).state = val;
                      },
                    ),

                    // CÓDIGO POSTAL
                    DropdownButtonFormField<int>(
                      value: idCP,
                      decoration: const InputDecoration(labelText: 'Código Postal'),
                      items: idLocalidad == null ? [] : cps.maybeWhen(
                        data: (lista) => lista.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        orElse: () => [],
                      ),
                      onChanged: (val) => setModalState(() => idCP = val),
                    ),

                    TextFormField(
                      controller: nombreCalleCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre de Calle'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: calleEdit == null ? Colors.blue : Colors.green,
                        minimumSize: const Size(double.infinity, 50)
                      ),
                      onPressed: () => _guardarAccion(context, calleId: calleEdit?.id),
                      child: Text(calleEdit == null ? "GUARDAR" : "ACTUALIZAR", 
                                  style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _guardarAccion(BuildContext context, {int? calleId}) async {
    if (!_formKey.currentState!.validate() || idLocalidad == null || idCP == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
      return;
    }

    final nombre = nombreCalleCtrl.text.trim();
    final notifier = ref.read(callesProvider.notifier);

    if (calleId == null) {
      await notifier.agregarCalle(nombre, idLocalidad!, idCP!);
    } else {
      await notifier.actualizarCalle(calleId, nombre, idLocalidad!, idCP!);
    }

    if (mounted) Navigator.pop(context);
    _limpiarFormulario();
  }

  void _confirmarEliminacion(BuildContext context, dynamic calle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Borrar "${calle.nombreCalle}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
          TextButton(onPressed: () async {
            await ref.read(callesProvider.notifier).borrarCalle(calle.id);
            if (mounted) Navigator.pop(context);
          }, child: const Text('SÍ', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}