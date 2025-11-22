import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:roadsense/models/paiement.dart';
import 'package:intl/intl.dart';
import 'package:roadsense/services/storage_service.dart';

class PrintService {
  static final PrintService instance = PrintService._init();

  PrintService._init();

  Future<void> printReceipt(Paiement paiement, String qrData) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
    final agentNom = StorageService.instance.agentNom ?? '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          pw.Widget line(String label, String value) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 1),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text(label, style: pw.TextStyle(fontSize: 10))),
                    pw.SizedBox(width: 6),
                    pw.Flexible(child: pw.Text(value, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
              );

          return pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text('mRecettes', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9)),
                pw.SizedBox(height: 2),
                pw.Text('QUITTANCE', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('--------------------------------', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9)),
                pw.SizedBox(height: 4),
                line('Centre de perception', paiement.nomPoste),
                line('Date', dateFormat.format(paiement.datePaiement)),
                line('Ref Quitt', '${paiement.id ?? ''}'),
                pw.SizedBox(height: 4),
                line('Assujeti', paiement.conducteurNom),
                line('Montant encaissé', '${(paiement.montant * paiement.quantite).toStringAsFixed(0)} CDF'),
                line('Mode', 'Espèces'),
                pw.SizedBox(height: 6),
                pw.Text('Liste des tarifs / Description', style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 2),
                pw.Text('1. ${paiement.typeEnginNom}', style: pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 2),
                line('Prix', '${paiement.montant.toStringAsFixed(0)} CDF'),
                line('Qt', '${paiement.quantite}'),
                pw.SizedBox(height: 6),
                line('Guichet', agentNom.isNotEmpty ? agentNom : '—'),
                pw.SizedBox(height: 10),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.BarcodeWidget(
                    data: qrData,
                    barcode: pw.Barcode.qrCode(),
                    width: 120,
                    height: 120,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> sharePdf(Paiement paiement, String qrData) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
    final agentNom = StorageService.instance.agentNom ?? '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          pw.Widget line(String label, String value) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text(label, style: pw.TextStyle(fontSize: 12))),
                    pw.SizedBox(width: 8),
                    pw.Flexible(child: pw.Text(value, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
              );

          return pw.Center(
            child: pw.Container(
              width: 320,
              padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text('mRecettes', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(height: 4),
                  pw.Text('QUITTANCE', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Text('--------------------------------', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(height: 6),
                  line('Centre de perception', paiement.nomPoste),
                  line('Date', dateFormat.format(paiement.datePaiement)),
                  line('Ref Quitt', '${paiement.id ?? ''}'),
                  pw.SizedBox(height: 8),
                  line('Assujeti', paiement.conducteurNom),
                  line('Montant encaissé', '${(paiement.montant * paiement.quantite).toStringAsFixed(0)} CDF'),
                  line('Mode', 'Espèces'),
                  pw.SizedBox(height: 10),
                  pw.Text('Liste des tarifs / Description', style: pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 4),
                  pw.Text('1. ${paiement.typeEnginNom}', style: pw.TextStyle(fontSize: 13)),
                  pw.SizedBox(height: 4),
                  line('Prix', '${paiement.montant.toStringAsFixed(0)} CDF'),
                  line('Qt', '${paiement.quantite}'),
                  pw.SizedBox(height: 10),
                  line('Guichet', agentNom.isNotEmpty ? agentNom : '—'),
                  pw.SizedBox(height: 14),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.BarcodeWidget(
                      data: qrData,
                      barcode: pw.Barcode.qrCode(),
                      width: 160,
                      height: 160,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'recu_${paiement.id}.pdf');
  }
}
