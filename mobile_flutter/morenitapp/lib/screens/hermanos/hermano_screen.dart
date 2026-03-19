import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/hermano.dart';
import '../../services/api_service.dart';

class HermanosScreen extends StatefulWidget {
  const HermanosScreen({super.key});

  @override
  State<HermanosScreen> createState() => _HermanosScreenState();
}

class _HermanosScreenState extends State<HermanosScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Hermano>> futureHermanos;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Método para cargar o recargar los datos
  void _loadData() {
    setState(() {
      futureHermanos = apiService.getHermanos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hermanos Activos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar lista',
            onPressed: _loadData,
          ),
        ],
      ),

      // BOTÓN FLOTANTE PARA CREAR
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF051906),
        onPressed: () async {
          // Si al volver de 'crear-hermano' recibimos 'true', recargamos la lista
          final bool? created = await context.push<bool>('/crear-hermano');
          if (created == true) {
            _loadData();
          }
        },
        label: const Text('Nuevo Hermano', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),

      body: FutureBuilder<List<Hermano>>(
        future: futureHermanos,
        builder: (context, snapshot) {
          // 1. Estado de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // 2. Estado de error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error al conectar con Odoo:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // 3. Si no hay datos
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No se encontraron hermanos.'),
                  TextButton(
                    onPressed: _loadData,
                    child: const Text('Actualizar ahora'),
                  )
                ],
              ),
            );
          }

          // 4. Lista de hermanos (Éxito)
          final hermanos = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 10, bottom: 80), // Espacio extra abajo por el FAB
              itemCount: hermanos.length,
              separatorBuilder: (context, index) => const Divider(indent: 70),
              itemBuilder: (context, index) {
                final hermano = hermanos[index];
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF051906),
                    child: Text(
                      hermano.nombre.isNotEmpty ? hermano.nombre[0].toUpperCase() : 'H',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    '${hermano.nombre} ${hermano.apellido1} ${hermano.apellido2}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.badge_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text('DNI: ${hermano.dni}'),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.phone_android, size: 14, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(hermano.telefono),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    // Navegar al detalle pasando el objeto hermano si lo necesitas
                    // context.push('/hermano-detalle', extra: hermano);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}