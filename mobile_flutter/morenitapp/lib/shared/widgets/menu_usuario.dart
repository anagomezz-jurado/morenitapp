import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/shared/widgets/menu_diseno.dart';

class MenuUsuario extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const MenuUsuario({super.key, required this.scaffoldKey});

  @override
  MenuUsuarioState createState() => MenuUsuarioState();
}

class MenuUsuarioState extends ConsumerState<MenuUsuario> {
  int navDrawerIndex = 0;

  void _navigate(String path, int index) {
    setState(() => navDrawerIndex = index);
    context.go(path);
    widget.scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 35;
    final colors = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.isAdmin == true;

    return NavigationDrawer(
      elevation: 0,
      backgroundColor: colors.surface,
      selectedIndex:
          navDrawerIndex, // Añadido para que el Drawer gestione visualmente la selección
      children: [
        MenuDiseno(
          userName: user?.fullName ?? 'Usuario',
          subTitulo: 'Gestión de Usuario',
          colors: colors,
          hasNotch: hasNotch,
        ),
        const SectionHeader(title: 'MI ÁREA PERSONAL'),
        MenuTile(
          icon: Icons.dashboard_customize_outlined,
          label: 'Mi Panel Principal',
          isSelected: navDrawerIndex == 0,
          onTap: () {
            setState(() => navDrawerIndex = 0);
            context.go('/panel-usuario');
            widget.scaffoldKey.currentState?.closeDrawer();
          },
        ),
        MenuTile(
          icon: Icons.account_circle_rounded,
          label: 'Mi Perfil',
          isSelected: navDrawerIndex == 1,
          onTap: () => _navigate('/mi-perfil', 1),
        ),
        const SectionHeader(title: 'CONTENIDO Y EVENTOS'),
        MenuTile(
          icon: Icons.menu_book_rounded,
          label: 'Libros Anuales',
          isSelected: navDrawerIndex == 2,
          onTap: () => _navigate('/listado-libros', 2),
        ),
        MenuTile(
          icon: Icons.event_note_rounded,
          label: 'Próximos Eventos',
          isSelected: navDrawerIndex == 3,
          onTap: () => _navigate('/calendario', 3),
        ),
        const Divider(indent: 20, endIndent: 20),
        if (isAdmin) ...[
          const SectionHeader(title: 'ADMINISTRACIÓN'),
          MenuTile(
            icon: Icons.admin_panel_settings_rounded,
            label: 'Panel de Gestión',
            isSelected: navDrawerIndex == 99,
            onTap: () {
              setState(() => navDrawerIndex = 99);
              context.go('/'); // o /home o tu panel real
              widget.scaffoldKey.currentState?.closeDrawer();
            },
          ),
        ],
        Padding(
          padding: const EdgeInsets.all(16),
          child: _LogoutButton(
              onTap: () => ref.read(authProvider.notifier).logout()),
        ),
      ],
    );
  }
}


class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            SizedBox(width: 10),
            Text('Cerrar Sesión',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
