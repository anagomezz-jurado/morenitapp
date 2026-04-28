import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

// Importaciones de tu proyecto
import 'package:morenitapp/features/panel-gestion/libros/domain/entities/libro_adjunto.dart';
import 'package:morenitapp/features/panel-gestion/libros/presentation/providers/libro_provider.dart';
import 'package:morenitapp/shared/widgets/visualizar_imagenes.dart'; // Asegúrate de que aquí esté ImagePreviewScreen

class LibrosListadoScreen extends ConsumerWidget {
  const LibrosListadoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final librosAsync = ref.watch(librosProvider);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Libros",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: librosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
          data: (libros) {
            if (libros.isEmpty) {
              return const Center(child: Text("No hay libros disponibles"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: libros.length,
              itemBuilder: (context, index) {
                final libro = libros[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(
                      libro.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Año: ${libro.anio}"),
                    children: [
                      _buildAdjuntos(context, libro.archivos), // Pasamos context
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // --- ICONO SEGÚN EXTENSIÓN ---
  IconData _getIconoPorExtension(String nombreArchivo) {
    final extension = nombreArchivo.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'png':
      case 'jpg':
      case 'jpeg': return Icons.image;
      case 'docx':
      case 'doc': return Icons.description;
      default: return Icons.insert_drive_file;
    }
  }

  // --- LISTADO DE ADJUNTOS ---
  Widget _buildAdjuntos(BuildContext context, List<LibroAdjunto> archivos) {
    if (archivos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text("Sin archivos adjuntos", style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: archivos.map((archivo) {
        return ListTile(
          leading: Icon(_getIconoPorExtension(archivo.nombre), color: Colors.blueGrey),
          title: Text(archivo.nombre),
          subtitle: Text(archivo.nombre.split('.').last.toUpperCase()),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón VER
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: archivo.base64 == null 
                    ? null 
                    : () => _abrirArchivo(context, archivo), // Corregido el envío de context
              ),
              // Botón DESCARGAR
              IconButton(
                icon: const Icon(Icons.download, color: Colors.green),
                onPressed: archivo.base64 == null 
                    ? null 
                    : () => _descargarArchivo(archivo),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- LÓGICA DE APERTURA ---
  Future<void> _abrirArchivo(BuildContext context, LibroAdjunto archivo) async {
    try {
      final base64Str = limpiarBase64(archivo.base64!);
      final bytes = base64Decode(base64Str);
      final extension = archivo.nombre.toLowerCase().split('.').last;

      if (kIsWeb) {
        final blob = html.Blob([bytes], _getMimeType(extension));
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.window.open(url, "_blank");
        html.Url.revokeObjectUrl(url);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${archivo.nombre}');
        await file.writeAsBytes(bytes, flush: true);

        if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ImagePreviewScreen(file: file)),
          );
        } else {
          await OpenFilex.open(file.path);
        }
      }
    } catch (e) {
      debugPrint(" Error abrir archivo: $e");
    }
  }

  // --- LÓGICA DE DESCARGA ---
  Future<void> _descargarArchivo(LibroAdjunto archivo) async {
    try {
      final base64Str = limpiarBase64(archivo.base64!);
      final bytes = base64Decode(base64Str);

      if (kIsWeb) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", archivo.nombre)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${archivo.nombre}');
        await file.writeAsBytes(bytes, flush: true);
        
        // Notificar al usuario (puedes usar un SnackBar aquí)
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      debugPrint(" Error descarga: $e");
    }
  }

  String _getMimeType(String ext) {
    switch (ext) {
      case 'pdf': return 'application/pdf';
      case 'png': return 'image/png';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      default: return 'application/octet-stream';
    }
  }

  String limpiarBase64(String data) {
    return data.contains(',') ? data.split(',').last : data;
  }
}