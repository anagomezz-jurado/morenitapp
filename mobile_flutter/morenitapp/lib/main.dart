import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Añade esto

import 'package:morenitapp/config/constants/environment.dart';
import 'package:morenitapp/config/theme/app_theme.dart';
import 'package:morenitapp/config/router/app_router.dart'; 

void main() async {
  // 1. Asegura que Flutter esté listo para llamar a código nativo/async
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Carga las variables de entorno (.env)
  await Environment.initEnvironment();

  // 3. Envuelve toda la app en ProviderScope para que Riverpod funcione
  runApp(
    const ProviderScope(child: MyApp())
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    // 4. Escucha el provider del router (debe estar definido en app_router.dart)
    final appRouter = ref.watch( goRouterProvider );

    return MaterialApp.router(
      title: 'MorenitApp',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      
      // 5. CONFIGURACIÓN PARA IDIOMA ESPAÑOL (Para el calendario/DatePicker)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
      ],
    );
  }
}