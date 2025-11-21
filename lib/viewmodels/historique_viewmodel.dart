import 'package:flutter/foundation.dart';
import 'package:roadsense/models/paiement.dart';
import 'package:roadsense/services/database_service.dart';
import 'package:roadsense/services/excel_service.dart';

class HistoriqueViewModel extends ChangeNotifier {
  List<Paiement> _paiements = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;
  double _total = 0.0;

  List<Paiement> get paiements => _paiements;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get total => _total;

  Future<void> loadPaiements() async {
    _isLoading = true;
    notifyListeners();

    try {
      _paiements = await DatabaseService.instance.getPaiementsByDate(_selectedDate);
      _total = await DatabaseService.instance.getTotalPaiementsByDate(_selectedDate);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur de chargement de l\'historique';
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeDate(DateTime date) {
    _selectedDate = date;
    loadPaiements();
  }

  Future<String?> exportToExcel() async {
    try {
      final filePath = await ExcelService.instance.exportPaiementsToExcel(_paiements, _selectedDate);
      return filePath;
    } catch (e) {
      _error = 'Erreur lors de l\'export Excel';
      notifyListeners();
      return null;
    }
  }

  int get nombrePaiements => _paiements.length;
  int get nombreSynchronises => _paiements.where((p) => p.estSynchronise).length;
  int get nombreNonSynchronises => _paiements.where((p) => !p.estSynchronise).length;
}
