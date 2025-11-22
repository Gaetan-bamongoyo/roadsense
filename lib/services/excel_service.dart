import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roadsense/models/paiement.dart';
import 'package:intl/intl.dart';

class ExcelService {
  static final ExcelService instance = ExcelService._init();

  ExcelService._init();

  Future<String> exportPaiementsToExcel(List<Paiement> paiements, DateTime date) async {
    final excel = Excel.createExcel();
    final sheet = excel['Rapport Journalier'];
    
    final dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm', 'fr_FR');
    
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('RAPPORT JOURNALIER - ${dateFormat.format(date)}');
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E1'));
    
    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('N°');
    sheet.cell(CellIndex.indexByString('B3')).value = TextCellValue('Conducteur');
    sheet.cell(CellIndex.indexByString('C3')).value = TextCellValue('Type d\'engin');
    sheet.cell(CellIndex.indexByString('D3')).value = TextCellValue('Montant (FCFA)');
    sheet.cell(CellIndex.indexByString('E3')).value = TextCellValue('Heure');
    
    int row = 4;
    double total = 0;
    
    for (int i = 0; i < paiements.length; i++) {
      final paiement = paiements[i];
      sheet.cell(CellIndex.indexByString('A$row')).value = IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(paiement.conducteurNom);
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(paiement.typeEnginNom);
      sheet.cell(CellIndex.indexByString('D$row')).value = DoubleCellValue(paiement.montant);
      sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(timeFormat.format(paiement.datePaiement));
      total += paiement.montant;
      row++;
    }
    
    row++;
    sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue('TOTAL:');
    sheet.cell(CellIndex.indexByString('D$row')).value = DoubleCellValue(total);
    
    final directory = Platform.isAndroid
    ? Directory('/storage/emulated/0/Download')
    : await getApplicationDocumentsDirectory();

    // final directory = await getApplicationDocumentsDirectory();
    final fileName = 'rapport_${dateFormat.format(date).replaceAll('/', '-')}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }
    
    return filePath;
  }
}
