import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';

class CalleSearchDelegate extends SearchDelegate<dynamic> {

  final WidgetRef ref;

  CalleSearchDelegate({required this.ref});

  @override
  String get searchFieldLabel => 'Buscar calle...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildListado(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildListado(context);

  Widget _buildListado(BuildContext context) {
    final callesAsync = ref.watch(callesProvider);

    return callesAsync.when(
      data: (calles) {
        final filtradas = calles
            .where((c) =>
                c.nombreCalle.toLowerCase().contains(query.toLowerCase()))
            .toList();

        if (filtradas.isEmpty) {
          return const Center(child: Text('No se encontraron calles'));
        }

        return ListView.builder(
          itemCount: filtradas.length,
          itemBuilder: (context, index) {
            final calle = filtradas[index];
            return ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(calle.nombreCalle),
              subtitle: Text("ID: ${calle.id}"),
              onTap: () => close(context, calle),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}