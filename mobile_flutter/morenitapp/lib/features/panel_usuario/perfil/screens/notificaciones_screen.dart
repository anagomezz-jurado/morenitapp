import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/notificacion.dart';

class NotificacionesUsuarioScreen extends ConsumerWidget {
  const NotificacionesUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notisAsync = ref.watch(notificacionesProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        centerTitle: true,
        backgroundColor: colors.primary,
        foregroundColor: Colors.white, 
        iconTheme: const IconThemeData(
            color: Colors.white), 
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(notificacionesProvider),
            color: Colors.white,
          ),
        ],
      ),
      body: notisAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 12),
              Text('Error al cargar notificaciones',
                  style: TextStyle(color: colors.error)),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => ref.refresh(notificacionesProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (notis) {
          if (notis.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: colors.outline),
                  const SizedBox(height: 16),
                  Text('No hay notificaciones',
                      style: TextStyle(
                          fontSize: 16,
                          color: colors.outline,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notis.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _NotificacionCard(noti: notis[i]),
          );
        },
      ),
    );
  }
}

class _NotificacionCard extends StatelessWidget {
  final Notificacion noti;
  const _NotificacionCard({required this.noti});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: tipo + fecha
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    noti.tipoNombre ?? 'General',
                    style: TextStyle(
                        fontSize: 11,
                        color: colors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Icon(Icons.schedule, size: 13, color: colors.outline),
                const SizedBox(width: 4),
                Text(
                  noti.fechaRegistro ?? '-',
                  style: TextStyle(fontSize: 11, color: colors.outline),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Asunto
            Text(
              noti.asunto,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            // Preview del mensaje (máx 2 líneas)
            Text(
              _stripHtml(noti.mensaje),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),

            // Footer: destinatarios + botón ver más
            Row(
              children: [
                Icon(Icons.people_outline, size: 15, color: colors.outline),
                const SizedBox(width: 4),
                Text(
                  '${noti.usuarioIds.length} destinatario(s)',
                  style: TextStyle(fontSize: 12, color: colors.outline),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Ver detalle'),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => _showDetalle(context, noti),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
  }

  void _showDetalle(BuildContext context, Notificacion noti) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: ListView(
            controller: controller,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tipo badge
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      noti.tipoNombre ?? 'General',
                      style: TextStyle(
                          color: colors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.schedule, size: 14, color: colors.outline),
                  const SizedBox(width: 4),
                  Text(
                    noti.fechaRegistro ?? '-',
                    style: TextStyle(fontSize: 12, color: colors.outline),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Asunto
              Text(
                noti.asunto,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 28),

              // Mensaje completo
              Text(
                'Mensaje',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.outline),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _stripHtml(noti.mensaje),
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
