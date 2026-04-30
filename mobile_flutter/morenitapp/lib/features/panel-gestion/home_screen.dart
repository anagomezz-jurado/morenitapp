import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Entidades
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/panel-gestion/activity_log.dart';
import 'package:morenitapp/features/panel-gestion/activity_log_provider.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/evento.dart';

// Providers
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/presentation/providers/proveedor_providers.dart';

// Widgets
import 'package:morenitapp/shared/widgets/side_menu.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; 


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final authState = ref.watch(authProvider);
    final user = authState.user;
    final hermanosAsync = ref.watch(hermanosListadoProvider);
    final eventosAsync = ref.watch(eventosProvider);
    final anunciantesData = ref.watch(listaSoloAnunciantes);

    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(scaffoldKey: _scaffoldKey),
      body: _MainContent(
        colors: colors,
        user: user,
        hermanosAsync: hermanosAsync,
        eventosAsync: eventosAsync,
        totalAnunciantes: anunciantesData.length.toString(),
      ),
    );
  }
}

class _MainContent extends ConsumerWidget {
  final ColorScheme colors;
  final User? user;
  final AsyncValue<List<Hermano>> hermanosAsync;
  final AsyncValue<List<Evento>> eventosAsync;
  final String totalAnunciantes;

  const _MainContent({
    required this.colors,
    required this.user,
    required this.hermanosAsync,
    required this.eventosAsync,
    required this.totalAnunciantes,
  });

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} horas';
    return DateFormat('dd/MM HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(activityLogProvider);

    final statsHermanos = hermanosAsync.when(
      data: (list) {
        final activos = list.where((h) => h.estado == 'activo').length;
        final bajas = list.where((h) => h.estado == 'baja').length;
        return {'activos': activos.toString(), 'bajas': bajas.toString()};
      },
      loading: () => {'activos': '...', 'bajas': '...'},
      error: (_, __) => {'activos': '0', 'bajas': '0'},
    );

    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87, size: 30),
                onPressed: () =>
                    HomeScreen._scaffoldKey.currentState?.openDrawer(),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bienvenido de nuevo,',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7))),
                        const SizedBox(height: 4),
                        Text(
                          (user != null)
                              ? '${user!.nombre} ${user!.apellido1}'
                              : 'Admin',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildStatCards(statsHermanos['activos']!,
                      statsHermanos['bajas']!, totalAnunciantes),

                  const SizedBox(height: 25),
                  const _SectionTitle(title: 'Resumen de actividad'),

                  if (logs.isEmpty)
                    const _ActivityCard(
                        description: 'Sin actividad reciente', time: '-')
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: logs.length > 5 ? 5 : logs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return _ActivityCard(
                          description:
                              '${log.userName} ${_actionText(log.action)} ${log.entityName}',
                          time: _formatTime(log.createdAt),
                        );
                      },
                    ),

                  const SizedBox(height: 25),
                  const _SectionTitle(title: 'Próximos eventos'),

                  eventosAsync.when(
                    data: (eventos) {
                      final hoy = DateTime.now();

                      final proximosEventos = eventos
                          .where((e) =>
                              e.fechaInicio.isAfter(hoy) ||
                              (e.fechaInicio.year == hoy.year &&
                                  e.fechaInicio.month == hoy.month &&
                                  e.fechaInicio.day == hoy.day))
                          .toList();

                      proximosEventos.sort(
                          (a, b) => a.fechaInicio.compareTo(b.fechaInicio));

                      if (proximosEventos.isEmpty)
                        return const _NoEventsWidget();

                      final listaReducida = proximosEventos.take(3).toList();

                      return Column(
                        children: listaReducida.map((evento) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 12), 
                            child: _EventTile(
                              title: evento.nombre,
                              date: DateFormat('dd/MM/yyyy HH:mm')
                                  .format(evento.fechaInicio),
                              icon: Icons.calendar_month,
                              color: evento.colorVisual,
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) =>
                        const Text('Error al conectar con Odoo'),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _actionText(ActionType action) {
    switch (action) {
      case ActionType.create:
        return 'creó';
      case ActionType.update:
        return 'actualizó';
      case ActionType.delete:
        return 'eliminó';
    }
  }

  Widget _buildStatCards(String activos, String bajas, String totalA) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
            title: 'Activos',
            value: activos,
            icon: Icons.person_add,
            color: Colors.green),
        _StatCard(
            title: 'Bajas',
            value: bajas,
            icon: Icons.person_off,
            color: Colors.green),
        _StatCard(
            title: 'Anunciantes',
            value: totalA,
            icon: Icons.ads_click,
            color: Colors.green),
      ],
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: color, size: 20), 
          ),
          const SizedBox(height: 6), 
          Text(
            value,
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines:
                1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11, 
              color: colors.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );
}

class _ActivityCard extends StatelessWidget {
  final String description;
  final String time;

  const _ActivityCard({required this.description, required this.time});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.update, color: colors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 18, color: colors.onSurface.withOpacity(0.3)),
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
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: TextStyle(
                    color: colors.onPrimaryContainer.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
