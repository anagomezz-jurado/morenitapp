import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class ExcelService {
  static void descargarExcel({
    required String nombreArchivo,
    required List<String> cabeceras,
    required List<List<dynamic>> filas,
  }) {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Sheet1'];

    sheet.appendRow(cabeceras.map((e) => TextCellValue(e)).toList());

    for (var fila in filas) {
      sheet.appendRow(fila.map((e) => TextCellValue(e.toString())).toList());
    }

    final bytes = excel.save();

    if (kIsWeb && bytes != null) {
      final blob = html.Blob([bytes],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "$nombreArchivo.xlsx")
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }
}
