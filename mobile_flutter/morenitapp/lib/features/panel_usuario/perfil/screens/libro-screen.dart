import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

import 'package:morenitapp/features/panel-gestion/libros/domain/entities/libro_adjunto.dart';
import 'package:morenitapp/features/panel-gestion/libros/presentation/providers/libro_provider.dart';
import 'package:morenitapp/shared/widgets/visualizar_imagenes.dart';

class LibrosListadoScreen extends ConsumerWidget {
  const LibrosListadoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final librosAsync = ref.watch(librosProvider);
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 50, bottom: 16),
              title: const Text(
                "Biblioteca Digital",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: librosAsync.when(
                loading: () => const SizedBox(
                  height: 400,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Center(child: Text("Error: $e")),
                data: (libros) {
                  if (libros.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text("No hay libros disponibles"),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: libros.length,
                    itemBuilder: (context, index) {
                      final libro = libros[index];
                      return _LibroCard(libro: libro, onFileTap: (archivo) => _abrirArchivo(context, archivo), onDownloadTap: _descargarArchivo);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirArchivo(BuildContext context, LibroAdjunto archivo) async {
    try {
      final base64Str = _limpiarBase64(archivo.base64!);
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => ImagePreviewScreen(file: file)));
        } else {
          await OpenFilex.open(file.path);
        }
      }
    } catch (e) {
      debugPrint("Error abrir archivo: $e");
    }
  }

  Future<void> _descargarArchivo(LibroAdjunto archivo) async {
    try {
      final base64Str = _limpiarBase64(archivo.base64!);
      final bytes = base64Decode(base64Str);
      if (kIsWeb) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)..setAttribute("download", archivo.nombre)..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${archivo.nombre}');
        await file.writeAsBytes(bytes, flush: true);
        ScaffoldMessenger.of(html.window.document as BuildContext).showSnackBar(SnackBar(content: Text("Descargado: ${archivo.nombre}")));
      }
    } catch (e) {
      debugPrint("Error descarga: $e");
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

  String _limpiarBase64(String data) => data.contains(',') ? data.split(',').last : data;
}

class _LibroCard extends StatelessWidget {
  final dynamic libro;
  final Function(LibroAdjunto) onFileTap;
  final Function(LibroAdjunto) onDownloadTap;

  const _LibroCard({required this.libro, required this.onFileTap, required this.onDownloadTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.menu_book_rounded, color: Theme.of(context).primaryColor),
          ),
          title: Text(
            libro.nombre,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436)),
          ),
          subtitle: Text(
            "Edición: ${libro.anio}",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: Column(
                children: (libro.archivos as List<LibroAdjunto>).map((archivo) {
                  return _FileRow(archivo: archivo, onFileTap: onFileTap, onDownloadTap: onDownloadTap);
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  final LibroAdjunto archivo;
  final Function(LibroAdjunto) onFileTap;
  final Function(LibroAdjunto) onDownloadTap;

  const _FileRow({required this.archivo, required this.onFileTap, required this.onDownloadTap});

  @override
  Widget build(BuildContext context) {
    final extension = archivo.nombre.split('.').last.toLowerCase();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _getIconForExtension(extension),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  archivo.nombre,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(extension.toUpperCase(), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue, size: 22),
            onPressed: () => onFileTap(archivo),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Colors.green, size: 22),
            onPressed: () => onDownloadTap(archivo),
          ),
        ],
      ),
    );
  }

  Widget _getIconForExtension(String ext) {
    IconData icon;
    Color color;
    switch (ext) {
      case 'pdf': icon = Icons.picture_as_pdf; color = Colors.red.shade400; break;
      case 'png':
      case 'jpg': icon = Icons.image_rounded; color = Colors.orange.shade400; break;
      case 'docx':
      case 'doc': icon = Icons.article_rounded; color = Colors.blue.shade400; break;
      default: icon = Icons.insert_drive_file_rounded; color = Colors.grey.shade400;
    }
    return Icon(icon, color: color, size: 28);
  }
}