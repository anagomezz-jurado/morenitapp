import 'package:flutter/material.dart';
import 'package:morenitapp/config/theme/app_theme.dart';
import 'package:morenitapp/config/router/app_router.dart'; // Importa tu nuevo router

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router es la forma correcta de usar GoRouter
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'Morenit App',
      theme: AppTheme().getTheme(),
    );
  }
}