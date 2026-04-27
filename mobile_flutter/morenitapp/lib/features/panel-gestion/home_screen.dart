import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Entidades
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/evento.dart';

// Providers
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';
// Importante para que el contador de anunciantes sea real
import 'package:morenitapp/features/panel-gestion/proveedores/presentation/providers/proveedor_providers.dart';

// Widgets
import 'package:morenitapp/shared/widgets/side_menu.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    // Escuchamos los providers
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final hermanosAsync = ref.watch(hermanosListadoProvider);
    final eventosAsync = ref.watch(eventosProvider);
    
    // Vinculación real con la lista de anunciantes
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
class _MainContent extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE FILTRADO PARA LOS CONTADORES ---
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
          // --- BOTÓN DE MENÚ ---
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87, size: 30),
                onPressed: () => HomeScreen._scaffoldKey.currentState?.openDrawer(),
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
                  // --- BANNER DE BIENVENIDA ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido de nuevo,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (user != null) ? '${user!.nombre} ${user!.apellido1}' : 'Admin',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- ESTADÍSTICAS ACTUALIZADAS (3 TARJETAS) ---
                  _buildStatCards(
                    statsHermanos['activos']!, 
                    statsHermanos['bajas']!, 
                    totalAnunciantes
                  ),

                  const SizedBox(height: 25),
                  const _SectionTitle(title: 'Resumen de actividad'),
                  
                  // --- ACTIVIDAD DINÁMICA ---
                  hermanosAsync.when(
                    data: (list) {
                      if (list.isEmpty) return const _ActivityCard(description: 'No hay registros recientes', time: '-');
                      // Mostramos el último independientemente de si es alta o baja
                      final ultimo = list.last;
                      final esBaja = ultimo.estado == 'baja';
                      return _ActivityCard(
                        description: esBaja 
                          ? 'Se tramitó la baja de: ${ultimo.nombre} ${ultimo.apellido1}'
                          : 'Nuevo hermano activo: ${ultimo.nombre} ${ultimo.apellido1}',
                        time: 'Recientemente',
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const _ActivityCard(description: 'Error al cargar actividad', time: 'Error'),
                  ),

                  const SizedBox(height: 25),
                  const _SectionTitle(title: 'Próximos eventos'),

                  // --- LÓGICA DE EVENTOS ---
                  eventosAsync.when(
                    data: (eventos) {
                      final ahora = DateTime.now();
                      final hoy = DateTime(ahora.year, ahora.month, ahora.day);
                      final proximosEventos = eventos.where((e) {
                        final fechaEvento = DateTime(e.fechaInicio.year, e.fechaInicio.month, e.fechaInicio.day);
                        return fechaEvento.isAtSameMomentAs(hoy) || fechaEvento.isAfter(hoy);
                      }).toList();

                      proximosEventos.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));

                      if (proximosEventos.isEmpty) return const _NoEventsWidget();

                      final proximo = proximosEventos.first;
                      return _EventTile(
                        title: proximo.nombre,
                        date: proximo.fechaInicio.toString().substring(0, 10),
                        icon: Icons.calendar_month,
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => const Text('Error al conectar con Odoo'),
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

  // --- GRID DE 3 TARJETAS ---
  Widget _buildStatCards(String activos, String bajas, String totalA) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200, // Ajustado para que quepan 3 o se reorganicen
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          children: [
            _StatCard(
              title: 'Activos',
              value: activos,
              icon: Icons.person_add_alt_1_rounded,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Bajas',
              value: bajas,
              icon: Icons.person_off_rounded,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Anunciantes',
              value: totalA,
              icon: Icons.ads_click,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }
}

  Widget _buildStatCards(String totalH, String totalA) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: isMobile ? (constraints.maxWidth / 2) - 5 : 300,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: isMobile ? 1.0 : 1.5,
          ),
          children: [
            _StatCard(
              title: 'Total Hermanos',
              value: totalH,
              icon: Icons.people_alt_rounded,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Anunciantes',
              value: totalA, // Vinculado a la lógica de proveedores
              icon: Icons.ads_click,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }


// --- SUB-WIDGETS (CON TU DISEÑO ORIGINAL) ---

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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
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

  const _EventTile({
    required this.title,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(18),
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
          Icon(icon, color: colors.onPrimaryContainer, size: 26),
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
