import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
    final user = ref.watch(authProvider).user;
    final eventosAsync = ref.watch(eventosProvider);
    final notisAsync = ref.watch(notificacionesProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuUsuario(scaffoldKey: _scaffoldKey),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 50.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: colors.surface,
            leading: IconButton(
              icon: Icon(Icons.sort_rounded, color: colors.primary, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 10),

                _WelcomeBanner(user: user, colors: colors),

                const SizedBox(height: 30),
                const _SectionHeader(title: 'Servicios rápidos'),
                _QuickActionsGrid(colors: colors, user: user),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionHeader(title: 'Avisos del Cabildo'),
                    TextButton(
                      onPressed: () => context.push('/notificaciones-usuario'),
                      child: const Text('Ver todos'),
                    )
                  ],
                ),
                _NotificacionesImportantes(notisAsync: notisAsync),

                const SizedBox(height: 30),

                const _SectionHeader(title: 'Próximos eventos'),
                _UpcomingEventsList(eventosAsync: eventosAsync),

                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingEventsList extends StatelessWidget {
  final AsyncValue<List<Evento>> eventosAsync;

  const _UpcomingEventsList({required this.eventosAsync});

  @override
  Widget build(BuildContext context) {
    return eventosAsync.when(
      data: (eventos) {
        final hoy = DateTime.now();
        final proximos = eventos
            .where((e) =>
                e.fechaInicio.isAfter(hoy) || e.fechaInicio.day == hoy.day)
            .toList();

        proximos.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));

        if (proximos.isEmpty) return const _NoEventsWidget();

        final listaReducida = proximos.take(3).toList();

        return Column(
          children: listaReducida.map((evento) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EventTile(
                title: evento.nombre,
                date: DateFormat('dd/MM/yyyy HH:mm').format(evento.fechaInicio),
                icon: Icons.calendar_month,
                color: evento.colorVisual,
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error al cargar agenda'),
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
        child: Text(
          'No hay próximos eventos',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bienvenido a MorenitApp,',
              style: TextStyle(
                  fontSize: 16, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(
            user?.nombre ?? 'Hermano',
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 15),
          _MembershipBadge(user: user, colors: colors),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final Color color;

  const _EventTile({
    required this.title,
    required this.date,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: color, width: 5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(date,
                    style: TextStyle(
                        color: colors.onSurface.withOpacity(0.6),
                        fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipBadge extends StatelessWidget {
  final User? user;
  final ColorScheme colors;
  const _MembershipBadge({required this.user, required this.colors});

  @override
  Widget build(BuildContext context) {
    final bool isLinked = user?.numeroHermano != null &&
        user!.numeroHermano!.isNotEmpty &&
        user!.numeroHermano != 'No vinculado';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.onPrimary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.onPrimary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isLinked ? Icons.verified_user : Icons.help_outline,
              color: colors.onPrimary, size: 18),
          const SizedBox(width: 10),
          Text(
            isLinked
                ? 'Hermano Nº ${user!.numeroHermano}'
                : 'Vincular mi perfil',
            style: TextStyle(
                color: colors.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14),
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
    final isAdmin = user?.isAdmin ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionCircle(
            icon: Icons.person_outline,
            label: 'Perfil',
            color: colors.primary,
            onTap: () => context.push('/mi-perfil')),
        _ActionCircle(
            icon: Icons.menu_book,
            label: 'Libros',
            color: colors.primary,
            onTap: () => context.push('/listado-libros')),
        _ActionCircle(
            icon: Icons.calendar_month,
            label: 'Agenda',
            color: colors.primary,
            onTap: () => context.push('/calendario')),
        _ActionCircle(
            icon: Icons.notifications_none,
            label: 'Avisos',
            color: colors.primary,
            onTap: () => context.push('/notificaciones-usuario')),
        if (isAdmin)
          _ActionCircle(
              icon: Icons.settings_suggest,
              label: 'Admin',
              color: colors.error,
              onTap: () => context.push('/')),
      ],
    );
  }
}

class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCircle(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _NotificacionesImportantes extends StatelessWidget {
  final AsyncValue<List<Notificacion>> notisAsync;
  const _NotificacionesImportantes({required this.notisAsync});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return notisAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (notis) {
        if (notis.isEmpty)
          return const _EmptyState(text: 'Todo en orden por aquí');

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: notis.take(5).length,
            itemBuilder: (context, i) {
              final noti = notis[i];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16, bottom: 4, top: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: colors.outlineVariant.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colors.secondaryContainer,
                      child: Icon(Icons.campaign_outlined,
                          color: colors.onSecondaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(noti.asunto,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 14),
                              maxLines: 1),
                          const SizedBox(height: 4),
                          Text(
                            noti.mensaje.replaceAll(RegExp(r'<[^>]*>'), ''),
                            style: TextStyle(
                                fontSize: 12, color: colors.onSurfaceVariant),
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
}

class _UpcomingEventSection extends StatelessWidget {
  final AsyncValue<List<Evento>> eventosAsync;
  final ColorScheme colors;
  const _UpcomingEventSection(
      {required this.eventosAsync, required this.colors});

  @override
  Widget build(BuildContext context) {
    return eventosAsync.when(
      data: (eventos) => eventos.isEmpty
          ? const _EmptyState(text: 'No hay eventos programados')
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.secondaryContainer, colors.surface],
                  begin: Alignment.topLeft,
                ),
                borderRadius: BorderRadius.circular(28),
                border:
                    Border.all(color: colors.outlineVariant.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                        color: colors.secondary,
                        borderRadius: BorderRadius.circular(18)),
                    child: Icon(Icons.event_note, color: colors.onSecondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(eventos.first.nombre,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                          eventos.first.fechaInicio.toString().substring(0, 10),
                          style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: colors.primary, size: 16),
                ],
              ),
            ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Ocurrió un error'),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant, width: 1),
      ),
      child: Center(
        child: Text(text,
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
