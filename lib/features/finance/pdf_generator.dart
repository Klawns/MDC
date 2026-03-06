
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../core/models/ride.dart';
import '../../core/models/client.dart';

class PdfGenerator {
  static Future<void> generateAndPrintReport({
    required List<Ride> rides,
    required List<Client> clients,
    required DateTime startDate,
    required DateTime endDate,
    required String title,
  }) async {
    final pdf = pw.Document();
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    final totalValue = rides.fold(0.0, (sum, r) => sum + r.value);

    // Get client name helper
    String getClientName(int id) {
      try {
        return clients.firstWhere((c) => c.id == id).name;
      } catch (_) {
        return 'Cliente Excluído';
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Mohamed Delivery Control',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                title,
                style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: ['Data/Hora', 'Cliente', 'Status', 'Valor (R\$)'],
                data: rides.map((r) {
                  return [
                    dateFormatter.format(r.date),
                    getClientName(r.clientId),
                    r.isPaid ? 'Pago' : 'Pendente',
                    currencyFormatter.format(r.value),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total de Corridas: ${rides.length}',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Total Ganho: ${currencyFormatter.format(totalValue)}',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'MDC_Relatorio_$title.pdf',
    );
  }
}
