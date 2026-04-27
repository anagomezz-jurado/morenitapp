import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReporteGenerator {
  static Future<void> generarPDFInformativo({
    required String titulo,
    required List<String> headers,
    required List<List<String>> data,
    Uint8List? logoBytes,
  }) async {
    final pdf = pw.Document();

    // Función interna para la fecha formateada en español
    String obtenerFechaActual() {
      final meses = [
        'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
      ];
      final ahora = DateTime.now();
      return '${ahora.day} de ${meses[ahora.month - 1]} de ${ahora.year}';
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(35),
        header: (pw.Context context) => pw.Column(
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // LOGO IZQUIERDA
                pw.Container(
                  width: 55,
                  height: 55,
                  child: logoBytes != null 
                    ? pw.Image(pw.MemoryImage(logoBytes)) 
                    : pw.PdfLogo(), 
                ),
                pw.SizedBox(width: 15),

                // DATOS CENTRO
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Real Cofradía de Nuestra Señora\nla Virgen de la Cabeza de El Carpio',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'C/ El Santo, 38 - 14620 El Carpio (Córdoba)',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        'web: www.virgendelacabezaelcarpio.es',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue700),
                      ),
                      pw.Text(
                        'e-mail: cofradia@virgendelacabezaelcarpio.es',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ),

                // TÍTULO Y PÁGINA DERECHA
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      titulo,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Pág. ${context.pageNumber} de ${context.pagesCount}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      obtenerFechaActual(),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Divider(thickness: 1, color: PdfColors.black),
            pw.SizedBox(height: 15),
          ],
        ),
        build: (pw.Context context) => [
          // TABLA ESTILO OFICIAL
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellHeight: 22,
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: const pw.FixedColumnWidth(35), // Columna Nº
              1: const pw.FlexColumnWidth(2),   // Nombre
              2: const pw.FlexColumnWidth(3),   // Apellidos
            },
          ),
          
          // CUADRO RESUMEN (Igual al de la foto)
          pw.SizedBox(height: 25),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 200,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.5),
              ),
              child: pw.Column(
                children: [
                  pw.Container(
                    width: double.infinity,
                    color: PdfColors.grey200,
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text(
                        'RESUMEN DE LISTADO',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total de registros:', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text(
                          '${data.length}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Ejecutar la impresión/guardado
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Reporte_${titulo.replaceAll("\n", " ")}.pdf',
    );
  }
}