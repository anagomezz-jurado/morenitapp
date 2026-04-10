import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/shared/widgets/menu_diseno.dart';

class SideMenu extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const SideMenu({super.key, required this.scaffoldKey});

  @override
  SideMenuState createState() => SideMenuState();
}

class SideMenuState extends ConsumerState<SideMenu> {
  int navDrawerIndex = 0;

  // Helper para cerrar el drawer después de navegar (se queda aquí por lógica, no por diseño)
  void _navigate(String path) {
    context.push(path);
    widget.scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 35;
    final colors = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).user;

    return NavigationDrawer(
      elevation: 0,
      backgroundColor: colors.surface,
      children: [
        MenuDiseno(
            userName: user?.fullName ?? 'Usuario',
            colors: colors,
            hasNotch: hasNotch),
        const SectionHeader(title: 'PRINCIPAL'),
        MenuTile(
          icon: Icons.dashboard_rounded,
          label: 'Panel Principal',
          isSelected: navDrawerIndex == 0,
          onTap: () {
            setState(() => navDrawerIndex = 0);
            context.go('/');
            widget.scaffoldKey.currentState?.closeDrawer();
          },
        ),
        const SectionHeader(title: 'GESTIÓN SECRETARÍA'),
        MenuExpansionGroup(
          icon: Icons.inventory_2_rounded,
          title: 'Secretaría',
          children: [
            MenuTile(
                icon: Icons.gavel_rounded,
                label: 'Autoridades',
                isSubItem: true,
                onTap: () => _navigate('/autoridades')),
            MenuTile(
                icon: Icons.badge_rounded,
                label: 'Cargos',
                isSubItem: true,
                onTap: () => _navigate('/cargos')),
            MenuTile(
                icon: Icons.account_balance_rounded,
                label: 'Cofradías',
                isSubItem: true,
                onTap: () => _navigate('/cofradias')),
          ],
        ),
        MenuExpansionGroup(
          icon: Icons.people_alt_rounded,
          title: 'Gestión de Hermanos',
          children: [
            MenuTile(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Hermanos activos',
                isSubItem: true,
                onTap: () => _navigate('/hermanos-activos')),
            MenuTile(
                icon: Icons.person_off_rounded,
                label: 'Hermanos no activos',
                isSubItem: true,
                onTap: () => _navigate('/hermanos-no-activos')),
          ],
        ),
        MenuExpansionGroup(
          icon: Icons.event_available_rounded,
          title: 'Eventos y Cultos',
          children: [
            MenuTile(
                icon: Icons.calendar_month_rounded,
                label: 'Calendario',
                isSubItem: true,
                onTap: () => _navigate('/calendario')),
            MenuTile(
                icon: Icons.list_alt_rounded,
                label: 'Listado de eventos',
                isSubItem: true,
                onTap: () => _navigate('/gestion-eventos')),
            MenuTile(
                icon: Icons.groups_rounded,
                label: 'Organizadores',
                isSubItem: true,
                onTap: () => _navigate('/organizadores')),
          ],
        ),
        const SectionHeader(title: 'ADMINISTRACIÓN DE TIPOS'),
        MenuExpansionGroup(
          icon: Icons.settings_suggest_rounded,
          title: 'Configuración de tipos',
          children: [
            MenuTile(
                icon: Icons.category_rounded,
                label: 'Tipo de evento',
                isSubItem: true,
                onTap: () => _navigate('/tipo-evento')),
            MenuTile(
                icon: Icons.admin_panel_settings_rounded,
                label: 'Gestión de Roles',
                isSubItem: true,
                onTap: () => _navigate('/roles')),
            MenuTile(
                icon: Icons.supervised_user_circle_rounded,
                label: 'Usuarios App',
                isSubItem: true,
                onTap: () => _navigate('/usuarios')),
          ],
        ),

         const SectionHeader(title: 'Ubicaciones'),
        MenuExpansionGroup(
          icon: Icons.menu_book_rounded,
          title: 'Provincias',
          children: [
            MenuTile(
                icon: Icons.book_rounded,
                label: 'Provincias',
                isSubItem: true,
                onTap: () => _navigate('/provincia')),
          ],
        ),
         MenuExpansionGroup(
          icon: Icons.menu_book_rounded,
          title: 'Localidades',
          children: [
            MenuTile(
                icon: Icons.book_rounded,
                label: 'Localidades',
                isSubItem: true,
                onTap: () => _navigate('/localidad')),
          ],
        ),
         MenuExpansionGroup(
          icon: Icons.menu_book_rounded,
          title: 'Códigos postales',
          children: [
            MenuTile(
                icon: Icons.book_rounded,
                label: 'Códigos postales',
                isSubItem: true,
                onTap: () => _navigate('/codigo-postal')),
          ],
        ),

         MenuExpansionGroup(
          icon: Icons.menu_book_rounded,
          title: 'Calles',
          children: [
            MenuTile(
                icon: Icons.book_rounded,
                label: 'Calles',
                isSubItem: true,
                onTap: () => _navigate('/calle')),
          ],
        ),

        const SectionHeader(title: 'CONTENIDO'),
        MenuExpansionGroup(
          icon: Icons.menu_book_rounded,
          title: 'Listar Libros',
          children: [
            MenuTile(
                icon: Icons.book_rounded,
                label: 'Libros',
                isSubItem: true,
                onTap: () => _navigate('/libros')),
          ],
        ),
        MenuExpansionGroup(
          icon: Icons.menu_book_rounded,
          title: 'Proveedores',
          children: [
            MenuTile(
                icon: Icons.book_rounded,
                label: 'Listado de proveedores',
                isSubItem: true,
                onTap: () => _navigate('/libros')),
            MenuTile(
                icon: Icons.newspaper_rounded,
                label: 'Anunciantes',
                isSubItem: true,
                onTap: () => _navigate('/anunciantes')),
          ],
        ),

         const SectionHeader(title: 'Gestión de Usuarios'),
        MenuExpansionGroup(
          icon: Icons.menu_book_rounded,
          title: 'Usuarios de la App',
          children: [
            MenuTile(
                icon: Icons.book_rounded,
                label: 'Usuarios de la App',
                isSubItem: true,
                onTap: () => _navigate('/usuarios')),
          ],
        ),

        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              MenuTile(
                  icon: Icons.account_circle_outlined,
                  label: 'Mi Panel de Usuario',
                  onTap: () => _navigate('/panel-usuario')),
              const SizedBox(height: 12),
              _LogoutButton(
                  onTap: () => ref.read(authProvider.notifier).logout()),
            ],
          ),
        ),
        const SizedBox(height: 30),
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
