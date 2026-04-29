import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/evento.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/notificacion.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';
import 'package:morenitapp/shared/widgets/menu_usuario.dart';

class PanelUsuarioScreen extends ConsumerWidget {
  const PanelUsuarioScreen({super.key});

  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).user;
    final eventosAsync = ref.watch(eventosProvider);
    final notisAsync = ref.watch(notificacionesProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuUsuario(scaffoldKey: _scaffoldKey),
      body: _MainContent(
        colors: colors,
        user: user,
        eventosAsync: eventosAsync,
        notisAsync: notisAsync,
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final ColorScheme colors;
  final User? user;
  final AsyncValue<List<Evento>> eventosAsync;
  final AsyncValue<List<Notificacion>> notisAsync;

  const _MainContent({
    required this.colors,
    required this.user,
    required this.eventosAsync,
    required this.notisAsync,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _WelcomeBanner(user: user, colors: colors),
                  const SizedBox(height: 20),
                  const _SectionTitle(title: 'Accesos Directos'),
                  _QuickActionsGrid(colors: colors, user: user),
                  const SizedBox(height: 10),
                  const _SectionTitle(title: 'Recordatorios Importantes'),
                  _NotificacionesImportantes(notisAsync: notisAsync),
                  const SizedBox(height: 20),
                  
                  const _SectionTitle(title: 'Próximo Evento'),
                  eventosAsync.when(
                    data: (eventos) => eventos.isEmpty
                        ? const _NoEventsWidget()
                        : _EventTile(
                            title: eventos.first.nombre,
                            date: eventos.first.fechaInicio
                                .toString()
                                .substring(0, 10),
                            icon: Icons.event_available_rounded,
                          ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) =>
                        const Text('No se pudieron cargar los eventos'),
                  ),
                  const SizedBox(height: 20),

                
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(Icons.notes_rounded, size: 30),
          onPressed: () =>
              PanelUsuarioScreen._scaffoldKey.currentState?.openDrawer(),
        ),
      ),
    );
  }
}

class _NotificacionesImportantes extends StatelessWidget {
  final AsyncValue<List<Notificacion>> notisAsync;

  const _NotificacionesImportantes({required this.notisAsync});

  @override
  Widget build(BuildContext context) {
    return notisAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
      data: (notis) {
        if (notis.isEmpty) return const SizedBox.shrink();

        final importantes = notis.take(5).toList();

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: importantes.length,
            itemBuilder: (context, i) {
              final noti = importantes[i];
              final estilo = _getEstiloPorTipo(noti.tipoNombre);

              return Container(
                width: MediaQuery.of(context).size.width * 0.75,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: estilo['bg'],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: estilo['color'].withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          estilo['color'].withOpacity(0.2),
                      child: Icon(estilo['icon'],
                          color: estilo['color']),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            noti.asunto,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: estilo['color'],
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _stripHtml(noti.mensaje),
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  Map<String, dynamic> _getEstiloPorTipo(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'urgente':
        return {
          'color': Colors.red,
          'bg': Colors.red.shade50,
          'icon': Icons.warning_rounded,
        };
      case 'recordatorio':
        return {
          'color': Colors.orange,
          'bg': Colors.orange.shade50,
          'icon': Icons.access_time,
        };
      case 'info':
        return {
          'color': Colors.blue,
          'bg': Colors.blue.shade50,
          'icon': Icons.info_outline,
        };
      default:
        return {
          'color': Colors.green,
          'bg': Colors.green.shade50,
          'icon': Icons.notifications,
        };
    }
  }
}

// ── NUEVA SECCIÓN PREVIEW EN EL PANEL ──
class _NotificacionesPreview extends StatelessWidget {
  final AsyncValue<List<Notificacion>> notisAsync;
  const _NotificacionesPreview({required this.notisAsync});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return notisAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
      data: (notis) {
        if (notis.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Text('No hay notificaciones aún',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w500)),
            ),
          );
        }

        // Mostramos las 3 más recientes
        final recientes = notis.take(3).toList();

        return Column(
          children: recientes
              .map((n) => _NotificacionPreviewTile(noti: n, colors: colors))
              .toList(),
        );
      },
    );
  }
}

class _NotificacionPreviewTile extends StatelessWidget {
  final Notificacion noti;
  final ColorScheme colors;
  const _NotificacionPreviewTile(
      {required this.noti, required this.colors});

  String _stripHtml(String html) => html
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .trim();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/notificaciones-usuario'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colors.primary.withOpacity(0.1),
              child: Icon(Icons.notifications_outlined,
                  color: colors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    noti.asunto,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _stripHtml(noti.mensaje),
                    style: TextStyle(
                        fontSize: 12, color: colors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  noti.fechaRegistro?.substring(0, 10) ?? '',
                  style:
                      TextStyle(fontSize: 10, color: colors.outline),
                ),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right,
                    size: 16, color: colors.outline),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── RESTO DE WIDGETS SIN CAMBIOS ───────────────────────────────────────────

class _RemindersSection extends StatelessWidget {
  const _RemindersSection();

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Cuota Pendiente',
        'desc': 'Recuerda regularizar tu cuota anual antes del viernes.',
        'icon': Icons.priority_high_rounded,
        'color': Colors.orange.shade800,
        'bg': Colors.orange.shade50,
      },
      {
        'title': 'Reparto de Túnicas',
        'desc': 'Ya puedes solicitar tu cita para el tallaje.',
        'icon': Icons.info_outline_rounded,
        'color': Colors.blue.shade800,
        'bg': Colors.blue.shade50,
      },
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item['bg'] as Color,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: (item['color'] as Color).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      (item['color'] as Color).withOpacity(0.2),
                  child: Icon(item['icon'] as IconData,
                      color: item['color'] as Color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] as String,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: item['color'] as Color,
                              fontSize: 14)),
                      Text(item['desc'] as String,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final User? user;
  final ColorScheme colors;
  const _WelcomeBanner({required this.user, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [colors.primary, colors.primaryContainer]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Paz y Bien,',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 16)),
          Text('${user?.nombre ?? "Hermano"}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          if (user?.numeroHermano != null &&
              user!.numeroHermano != 'No vinculado' &&
              user!.numeroHermano!.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text('Hermano Nº ${user!.numeroHermano}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () => context.push('/mi-perfil'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white38),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link_rounded,
                        color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Text('Vincular número de hermano',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final ColorScheme colors;
  final User? user;
  const _QuickActionsGrid({required this.colors, required this.user});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user?.isAdmin == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 20,
        runSpacing: 15,
        children: [
          _QuickActionItem(
            icon: Icons.person_outline,
            label: 'Mi Perfil',
            color: colors.primary,
            onTap: () => context.push('/mi-perfil'),
          ),
          _QuickActionItem(
            icon: Icons.menu_book_outlined,
            label: 'Libros',
            color: colors.primary,
            onTap: () => context.push('/listado-libros'),
          ),
          _QuickActionItem(
            icon: Icons.calendar_today_outlined,
            label: 'Eventos',
            color: colors.primary,
            onTap: () => context.push('/calendario'),
          ),
          // ── NUEVO ACCESO DIRECTO ──
          _QuickActionItem(
            icon: Icons.notifications_outlined,
            label: 'Avisos',
            color: colors.primary,
            onTap: () => context.push('/notificaciones-usuario'),
          ),
          if (isAdmin)
            _QuickActionItem(
              icon: Icons.admin_panel_settings,
              label: 'Gestión',
              color: Colors.redAccent,
              onTap: () => context.push('/'),
            ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionItem(
      {required this.icon,
      required this.label,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
      );
}

class _EventTile extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  const _EventTile(
      {required this.title, required this.date, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF051906),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                Text(date,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _NoEventsWidget extends StatelessWidget {
  const _NoEventsWidget();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text('No hay próximos eventos',
            style: TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w500)),
      ),
    );
  }
}