import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Entidades
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/evento.dart';

// Providers
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
// Asegúrate de que la ruta del archivo que me pasaste sea esta:
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';

// Widgets
import 'package:morenitapp/shared/widgets/side_menu.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    // 1. Escuchamos los providers
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final hermanosAsync = ref.watch(hermanosListadoProvider);
    
    // Usamos el eventosProvider que definiste en tu código
    final eventosAsync = ref.watch(eventosProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(scaffoldKey: _scaffoldKey),
      body: _MainContent(
        colors: colors,
        user: user,
        hermanosAsync: hermanosAsync,
        eventosAsync: eventosAsync,
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final ColorScheme colors;
  final User? user;
  final AsyncValue<List<Hermano>> hermanosAsync;
  final AsyncValue<List<Evento>> eventosAsync;

  const _MainContent({
    required this.colors,
    required this.user,
    required this.hermanosAsync,
    required this.eventosAsync,
  });

  @override
  Widget build(BuildContext context) {
    // Total de hermanos reactivo
    final totalHermanos = hermanosAsync.when(
      data: (list) => list.length.toString(),
      loading: () => '...',
      error: (_, __) => '0',
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
                          (user != null)
                              ? '${user!.nombre} ${user!.apellido1}'
                              : 'Admin',
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

                  // --- ESTADÍSTICAS ---
                  _buildStatCards(totalHermanos),

                  const SizedBox(height: 25),
                  const _SectionTitle(title: 'Resumen de actividad'),
                  const _ActivityCard(
                    description: 'Se registró un nuevo hermano: Juan Pérez',
                    time: 'Hace 10 min',
                  ),

                  const SizedBox(height: 25),
                  const _SectionTitle(title: 'Próximos eventos'),

                  // --- LÓGICA DE EVENTOS DINÁMICA ---
                  eventosAsync.when(
                    data: (eventos) {
                      if (eventos.isEmpty) {
                        return const _NoEventsWidget();
                      }

                      // Mostramos el evento más cercano
                      final proximo = eventos.first;
                      return _EventTile(
                        title: proximo.nombre, // Cambia a 'nombre' o 'titulo' según tu entidad
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

  Widget _buildStatCards(String total) {
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
              value: total,
              icon: Icons.people_alt_rounded,
              color: colors.primary,
            ),
            const _StatCard(
              title: 'Anunciantes',
              value: '12',
              icon: Icons.ads_click,
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }
}

// --- SUB-WIDGETS ---

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
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          FittedBox(child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), textAlign: TextAlign.center),
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
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );
}

class _ActivityCard extends StatelessWidget {
  final String description;
  final String time;
  const _ActivityCard({required this.description, required this.time});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.grey.shade100,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: ListTile(
      title: Text(description, style: const TextStyle(fontSize: 14)),
      subtitle: Text(time, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_right),
    ),
  );
}

class _EventTile extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  const _EventTile({required this.title, required this.date, required this.icon});

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
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}