import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/notificacion.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class NotificacionesScreen extends ConsumerWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notisAsync = ref.watch(notificacionesProvider);

    return PlantillaVentanas(
      title: 'Historial de Notificaciones',
      isLoading: notisAsync.isLoading,
      onRefresh: () => ref.refresh(notificacionesProvider),
      onNuevo: () => _showEnvioForm(context, ref),
      columns: const [
        DataColumn(label: Text('ASUNTO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('TIPO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('FECHA', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: notisAsync.when(
        data: (notis) => notis.map((n) => DataRow(cells: [
          DataCell(Text(n.asunto)),
          DataCell(Text(n.tipoNombre ?? 'General')),
          DataCell(Text(n.fechaRegistro ?? '-')),
          DataCell(IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            tooltip: 'Eliminar notificación',
            onPressed: () async {
              final confirm = await _confirmarEliminacion(context);
              if (confirm && context.mounted) {
                ref.read(notificacionesProvider.notifier).eliminar(n.id!);
              }
            },
          )),
        ])).toList(),
        error: (e, _) => [
          const DataRow(cells: [
            DataCell(Text('Error al cargar notificaciones')),
            DataCell(Text('-')),
            DataCell(Text('-')),
            DataCell(Text('-')),
          ]),
        ],
        loading: () => [],
      ),
    );
  }

  Future<bool> _confirmarEliminacion(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text('¿Estás seguro de que quieres eliminar esta notificación?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showEnvioForm(BuildContext context, WidgetRef ref) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
          ),
          child: const Material(color: Colors.transparent, child: _NotificacionForm()),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FORMULARIO
// ─────────────────────────────────────────────
class _NotificacionForm extends ConsumerStatefulWidget {
  const _NotificacionForm();

  @override
  ConsumerState<_NotificacionForm> createState() => _NotificacionFormState();
}

class _NotificacionFormState extends ConsumerState<_NotificacionForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _asuntoCtrl = TextEditingController();
  final _mensajeCtrl = TextEditingController();
  int? _selectedTipoId;
  bool _enviando = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _asuntoCtrl.dispose();
    _mensajeCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiposAsync = ref.watch(notificacionTiposProvider);
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              children: [
                Icon(Icons.notifications_outlined, color: colors.primary),
                const SizedBox(width: 10),
                Text('NUEVO ENVÍO',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),

            // Asunto
            TextFormField(
              controller: _asuntoCtrl,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Asunto de la Notificación',
                border: UnderlineInputBorder(),
                prefixIcon: Icon(Icons.subject),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'El asunto es obligatorio' : null,
            ),
            const SizedBox(height: 16),

            // Tipo de Aviso
            tiposAsync.when(
              data: (tipos) => DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Aviso',
                  border: UnderlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                value: _selectedTipoId,
                items: tipos
                    .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedTipoId = val),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error cargando tipos'),
            ),
            const SizedBox(height: 16),

            // Tabs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Mensaje'),
                Tab(text: 'Destinatarios'),
              ],
            ),

            // Contenido tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMensajeTab(),
                  _buildDestinatariosTab(),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Botón enviar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                icon: _enviando
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.email_outlined),
                label: Text(_enviando ? 'Enviando...' : 'ENVIAR POR EMAIL'),
                onPressed: _enviando ? null : _enviar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMensajeTab() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: _mensajeCtrl,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          hintText: 'Escriba aquí el contenido de la notificación...',
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'El mensaje es obligatorio' : null,
      ),
    );
  }

  Widget _buildDestinatariosTab() {
    final usuariosAsync = ref.watch(usuariosConEmailProvider);
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera tabla
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('NOMBRE',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: colors.primary)),
                ),
                Expanded(
                  flex: 4,
                  child: Text('EMAIL',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: colors.primary)),
                ),
                Icon(Icons.mark_email_read_outlined, size: 16, color: colors.primary),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: usuariosAsync.when(
              data: (usuarios) {
                if (usuarios.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 40, color: colors.outline),
                        const SizedBox(height: 8),
                        Text('No hay usuarios con Email OK activado',
                            style: TextStyle(color: colors.outline, fontSize: 13)),
                      ],
                    ),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: ListView.separated(
                    itemCount: usuarios.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (_, i) {
                      final u = usuarios[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        colors.primary.withOpacity(0.1),
                                    child: Text(
                                      u.nombre.isNotEmpty
                                          ? u.nombre[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: colors.primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(u.nombre,
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(u.email,
                                  style: TextStyle(
                                      fontSize: 12, color: colors.outline),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const Icon(Icons.check_circle_outline,
                                size: 16, color: Colors.green),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error cargando destinatarios: $e',
                    style: const TextStyle(color: Colors.redAccent)),
              ),
            ),
          ),

          // Contador
          usuariosAsync.maybeWhen(
            data: (usuarios) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${usuarios.length} destinatario(s) recibirán este email',
                style: TextStyle(fontSize: 11, color: colors.outline),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      final noti = Notificacion(
        asunto: _asuntoCtrl.text.trim(),
        mensaje: _mensajeCtrl.text.trim(),
        tipoId: _selectedTipoId,
        usuarioIds: [],
      );
      final success =
          await ref.read(notificacionesProvider.notifier).enviar(noti);
      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('✅ Notificación enviada correctamente'),
                backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('❌ Error al enviar la notificación'),
                backgroundColor: Colors.redAccent),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }
}