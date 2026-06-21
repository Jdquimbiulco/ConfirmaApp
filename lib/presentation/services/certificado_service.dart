import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/usuario.dart';

class CertificadoService {
  static Future<void> generarYMostrarCertificado(Usuario usuario, String nombreEvento) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue900, width: 10),
            ),
            child: pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('CERTIFICADO DE ASISTENCIA', style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  pw.SizedBox(height: 40),
                  pw.Text('Se otorga el presente certificado a:', style: const pw.TextStyle(fontSize: 20)),
                  pw.SizedBox(height: 20),
                  pw.Text(usuario.nombre.toUpperCase(), style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text('Por su valiosa participación en el evento:', style: const pw.TextStyle(fontSize: 20)),
                  pw.SizedBox(height: 10),
                  pw.Text(nombreEvento, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                  pw.SizedBox(height: 40),
                  pw.Text('Fecha: ${DateTime.now().toString().substring(0, 10)}', style: const pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 40),
                  pw.Container(width: 200, child: pw.Divider(color: PdfColors.grey)),
                  pw.Text('Firma Digital del Organizador', style: const pw.TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
