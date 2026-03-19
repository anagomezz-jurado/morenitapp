import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/config/theme/main_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 1. Llave global para controlar el Scaffold desde cualquier parte del árbol
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey, // 2. Asignamos la llave al Scaffold
      drawer: const _SideMenu(),
      body: MainBackground(
        title: 'Dashboard',
        child: SafeArea(
          child: Column(
            children: [
              // --- BOTÓN DE MENÚ ---
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                    onPressed: () {
                      // 3. Usamos la llave para abrir el Drawer
                      _scaffoldKey.currentState?.openDrawer();
                    },
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
                      const Text(
                        'Bienvenido de nuevo,',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const Text(
                        'Administrador',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // --- CUADRÍCULA DE ESTADÍSTICAS ---
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        children: [
                          _StatCard(
                            title: 'Total Hermanos',
                            value: '124',
                            icon: Icons.people_alt_rounded,
                            color: colors.primary,
                          ),
                          _StatCard(
                            title: 'Anunciantes',
                            value: '12',
                            icon: Icons.ads_click,
                            color: Colors.orange,
                          ),
                        ],
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
        ),
      ),
    );
  }
}

// --- MENÚ LATERAL ---
class _SideMenu extends StatelessWidget {
  const _SideMenu();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF051906)),
              child: const Center(
                child: Icon(Icons.church, size: 80, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ExpansionTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Gestión de Hermanos'),
              childrenPadding: const EdgeInsets.only(left: 20),
              children: [
                ListTile(
                  leading: const Icon(Icons.list_alt_rounded, size: 20),
                  title: const Text('Hermanos Activos'),
                  onTap: () {
                    Navigator.pop(context); // Cierra el menú
                    context.push('/hermanos'); // Navega
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_off_outlined, size: 20),
                  title: const Text('Hermanos Inactivos'),
                  onTap: () {},
                ),
              ],
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                context.go('/login');
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 35),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(date, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}