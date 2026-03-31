import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
import 'package:morenitapp/shared/widgets/side_menu.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    
    // Escuchamos el estado de autenticación (Persistente)
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    // Escuchamos la lista de hermanos desde el repositorio
    final hermanosAsync = ref.watch(hermanosListadoProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(scaffoldKey: _scaffoldKey),
      body: _MainContent(
        colors: colors, 
        user: user, 
        hermanosAsync: hermanosAsync
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final ColorScheme colors;
  final User? user; 
  final AsyncValue<List<Hermano>> hermanosAsync;

  const _MainContent({
    required this.colors, 
    required this.user, 
    required this.hermanosAsync
  });

  @override
  Widget build(BuildContext context) {
    // Cálculo reactivo del total
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
                          user?.fullName ?? 'Admin',
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

                  // --- TARJETAS DE ESTADÍSTICAS ---
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: LayoutBuilder(
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
                                value: totalHermanos,
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
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  const _SectionTitle(title: 'Resumen de actividad'),
                  const _ActivityCard(
                    description: 'Se registró un nuevo hermano: Juan Pérez',
                    time: 'Hace 10 min',
                  ),
                  const _ActivityCard(
                    description: 'Anuncio actualizado: "Evento Caridad"',
                    time: 'Hace 1 hora',
                  ),
                  
                  const SizedBox(height: 25),
                  const _SectionTitle(title: 'Próximos eventos'),
                  const _EventTile(
                    title: 'Reunión General',
                    date: '25 Mar, 2026',
                    icon: Icons.calendar_month,
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
}

// --- COMPONENTES DE APOYO ---

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
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

class _ActivityCard extends StatelessWidget {
  final String description;
  final String time;
  const _ActivityCard({required this.description, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                date,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }
}