import 'package:go_router/go_router.dart';
import 'package:morenitapp/screens/hermanos/hermano_screen.dart';
import 'package:morenitapp/screens/home_screen.dart';
import 'package:morenitapp/screens/inicio_sesion_screen.dart';
import 'package:morenitapp/screens/panel_usuario_screen.dart';
import 'package:morenitapp/screens/registrar_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/', // Opcional: define dónde empieza la app
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      // Verifica que en tu archivo inicio_sesion_screen.dart
      // la clase se llame InicioSesionScreen o LoginScreen
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/registrarse',
      builder: (context, state) => const RegistrarScreen(),
    ),
    GoRoute(
      path: '/hermanos',
      builder: (context, state) => const HermanosScreen(),
    ),    // En tu app_router.dart añade esta ruta:
    GoRoute(
      path: '/panel-usuario',
      builder: (context, state) => const PanelUsuarioScreen(),
    ),
  ],
);
