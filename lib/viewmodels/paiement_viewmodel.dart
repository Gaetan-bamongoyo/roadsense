// import 'package:flutter/foundation.dart';
// import 'package:roadsense/models/engin.dart';
// import 'package:roadsense/models/paiement.dart';
// import 'package:roadsense/services/database_service.dart';
// import 'package:roadsense/services/qr_service.dart';
// import 'package:roadsense/services/print_service.dart';
// import 'package:roadsense/services/storage_service.dart';

// class PaiementViewModel extends ChangeNotifier {
//   List<Taxe> _engins = [];
//   Taxe? _selectedEngin;
//   String _conducteurNom = '';
//   bool _isLoading = false;
//   String? _error;
//   Paiement? _lastPaiement;
//   String? _lastQrData;

//   List<Taxe> get engins => _engins;
//   Taxe? get selectedEngin => _selectedEngin;
//   String get conducteurNom => _conducteurNom;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   Paiement? get lastPaiement => _lastPaiement;
//   String? get lastQrData => _lastQrData;
//   bool get canSubmit => _selectedEngin != null && _conducteurNom.isNotEmpty;

//   Future<void> loadEngins() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       _engins = await StorageService.instance.loadTarif();
//       _isLoading = false;
//       notifyListeners();
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         print('Erreur de synchronisation: $e');
//         print(stackTrace);
//       }
//       _error = 'Erreur de chargement des engins ${e.toString()}';
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void selectEngin(Taxe engin) {
//     _selectedEngin = engin;
//     notifyListeners();
//   }

//   void setConducteurNom(String nom) {
//     _conducteurNom = nom;
//     notifyListeners();
//   }

//   Future<bool> enregistrerPaiement(int posteId, String nomPoste, int quantite) async {
//     if (!canSubmit) return false;

//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final paiement = Paiement(
//         conducteurNom: _conducteurNom,
//         typeEnginId: _selectedEngin!.id!,
//         typeEnginNom: _selectedEngin!.nom,
//         montant: _selectedEngin!.tarif,
//         quantite: quantite,
//         datePaiement: DateTime.now(),
//         statutSync: 0,
//         posteId: posteId,
//         nomPoste: nomPoste,
//       );

//       final id = await DatabaseService.instance.insertPaiement(paiement);
//       _lastPaiement = paiement.copyWith(id: id);
//       _lastQrData = QrService.instance.generateQrData(_lastPaiement!);

//       reset();
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _error = 'Erreur lors de l\'enregistrement';
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<void> printReceipt() async {
//     if (_lastPaiement != null && _lastQrData != null) {
//       await PrintService.instance.printReceipt(_lastPaiement!, _lastQrData!);
//     }
//   }

//   Future<void> shareReceipt() async {
//     if (_lastPaiement != null && _lastQrData != null) {
//       await PrintService.instance.sharePdf(_lastPaiement!, _lastQrData!);
//     }
//   }

//   void reset() {
//     _selectedEngin = null;
//     _conducteurNom = '';
//     _error = null;
//   }

//   void clearLastPaiement() {
//     _lastPaiement = null;
//     _lastQrData = null;
//     notifyListeners();
//   }
// }

// import 'package:flutter/foundation.dart';
// import 'package:roadsense/models/engin.dart';
// import 'package:roadsense/models/paiement.dart';
// import 'package:roadsense/services/database_service.dart';
// import 'package:roadsense/services/qr_service.dart';
// import 'package:roadsense/services/print_service.dart';
// import 'package:roadsense/models/categorie.dart';

// class PaiementViewModel extends ChangeNotifier {
//   List<Taxe> _engins = [];
//   Taxe? _selectedEngin;
//   String _conducteurNom = '';
//   int _quantite = 1;
//   String _searchQuery = '';
//   int? _selectedCategorieId; // null = Tous
//   bool _isLoading = false;
//   String? _error;
//   Paiement? _lastPaiement;
//   String? _lastQrData;
//   List<Categorie> _categories = [];

//   List<Taxe> get engins => _engins;
//   Taxe? get selectedEngin => _selectedEngin;
//   String get conducteurNom => _conducteurNom;
//   int get quantite => _quantite;
//   String get searchQuery => _searchQuery;
//   int? get selectedCategorieId => _selectedCategorieId;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   Paiement? get lastPaiement => _lastPaiement;
//   String? get lastQrData => _lastQrData;
//   bool get canSubmit => _selectedEngin != null && _conducteurNom.isNotEmpty;

//   List<Categorie> get categories => _categories;

//   List<Taxe> get filteredEngins {
//     return _engins.where((e) {
//       final matchCat = _selectedCategorieId == null || e.categorieId == _selectedCategorieId;
//       final matchSearch = _searchQuery.isEmpty || e.nom.toLowerCase().contains(_searchQuery.toLowerCase());
//       return matchCat && matchSearch;
//     }).toList();
//   }

//   Future<void> loadEngins() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final db = DatabaseService.instance;
//       _categories = await db.getAllCategories();
//       _engins = await db.getAllEngins();
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _error = 'Erreur de chargement des engins';
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void selectEngin(Taxe engin) {
//     _selectedEngin = engin;
//     notifyListeners();
//   }

//   void setConducteurNom(String nom) {
//     _conducteurNom = nom;
//     notifyListeners();
//   }

//   void setQuantite(int value) {
//     if (value < 1) value = 1;
//     _quantite = value;
//     notifyListeners();
//   }

//   void incrementQuantite() {
//     _quantite += 1;
//     notifyListeners();
//   }

//   void decrementQuantite() {
//     if (_quantite > 1) {
//       _quantite -= 1;
//       notifyListeners();
//     }
//   }

//   void setSearchQuery(String query) {
//     _searchQuery = query;
//     notifyListeners();
//   }

//   void setCategorieId(int? catId) {
//     _selectedCategorieId = catId;
//     notifyListeners();
//   }

//   Future<bool> enregistrerPaiement(int posteId, String nomPoste) async {
//     if (!canSubmit) return false;

//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final paiement = Paiement(
//         conducteurNom: _conducteurNom,
//         typeEnginId: _selectedEngin!.id!,
//         typeEnginNom: _selectedEngin!.nom,
//         montant: _selectedEngin!.tarif * _quantite,
//         quantite: _quantite,
//         datePaiement: DateTime.now(),
//         statutSync: 0,
//         posteId: posteId,
//         nomPoste: nomPoste,
//       );

//       final id = await DatabaseService.instance.insertPaiement(paiement);
//       _lastPaiement = paiement.copyWith(id: id);
//       _lastQrData = QrService.instance.generateQrData(_lastPaiement!);

//       reset();
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _error = 'Erreur lors de l\'enregistrement';
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<void> printReceipt() async {
//     if (_lastPaiement != null && _lastQrData != null) {
//       await PrintService.instance.printReceipt(_lastPaiement!, _lastQrData!);
//     }
//   }

//   Future<void> shareReceipt() async {
//     if (_lastPaiement != null && _lastQrData != null) {
//       await PrintService.instance.sharePdf(_lastPaiement!, _lastQrData!);
//     }
//   }

//   void reset() {
//     _selectedEngin = null;
//     _conducteurNom = '';
//     _quantite = 1;
//     _error = null;
//   }

//   void clearLastPaiement() {
//     _lastPaiement = null;
//     _lastQrData = null;
//     notifyListeners();
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:roadsense/models/engin.dart';
import 'package:roadsense/models/paiement.dart';
import 'package:roadsense/services/database_service.dart';
import 'package:roadsense/services/qr_service.dart';
import 'package:roadsense/services/print_service.dart';
import 'package:roadsense/models/categorie.dart';
import 'package:roadsense/services/storage_service.dart';

class PaiementViewModel extends ChangeNotifier {
  List<Taxe> _engins = [];
  Taxe? _selectedEngin;
  String _conducteurNom = '';
  int _quantite = 1;
  String _searchQuery = '';
  int? _selectedCategorieId; // null = Tous
  bool _isLoading = false;
  String? _error;
  Paiement? _lastPaiement;
  String? _lastQrData;
  List<Categorie> _categories = [];

  List<Taxe> get engins => _engins;
  Taxe? get selectedEngin => _selectedEngin;
  String get conducteurNom => _conducteurNom;
  int get quantite => _quantite;
  String get searchQuery => _searchQuery;
  int? get selectedCategorieId => _selectedCategorieId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Paiement? get lastPaiement => _lastPaiement;
  String? get lastQrData => _lastQrData;
  bool get canSubmit => _selectedEngin != null && _conducteurNom.isNotEmpty;

  List<Categorie> get categories => _categories;

  List<Taxe> get filteredEngins {
    return _engins.where((e) {
      final matchCat =
          _selectedCategorieId == null || e.categorieId == _selectedCategorieId;
      final matchSearch =
          _searchQuery.isEmpty ||
          e.nom.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

    Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = StorageService.instance;
      _categories = await db.loadCategorie();
      // final db = DatabaseService.instance;
      // _categories = await db.getAllCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur de chargement des engins';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> loadEngins() async {
  //   _isLoading = true;
  //   notifyListeners();

  //   try {
  //     final db = DatabaseService.instance;
  //     _categories = await db.getAllCategories();
  //     _engins = await db.getAllEngins();
  //     _isLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     _error = 'Erreur de chargement des engins';
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> getEnginById(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseService.instance;
      _engins = await db.getAllEnginsById(id);
      // print(_engins);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur de chargement des engins $e';
      // print(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectEngin(Taxe engin) {
    _selectedEngin = engin;
    notifyListeners();
  }

  void setConducteurNom(String nom) {
    _conducteurNom = nom;
    notifyListeners();
  }

  void setQuantite(int value) {
    if (value < 1) value = 1;
    _quantite = value;
    notifyListeners();
  }

  void incrementQuantite() {
    _quantite += 1;
    notifyListeners();
  }

  void decrementQuantite() {
    if (_quantite > 1) {
      _quantite -= 1;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategorieId(int? catId) {
    _selectedCategorieId = catId;
    notifyListeners();
  }

  Future<bool> enregistrerPaiement(int posteId, String nomPoste, String nomAgent) async {
    if (!canSubmit) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final paiement = Paiement(
        conducteurNom: _conducteurNom,
        typeEnginId: _selectedEngin!.id!,
        typeEnginNom: _selectedEngin!.nom,
        montant: _selectedEngin!.tarif,
        quantite: _quantite,
        datePaiement: DateTime.now(),
        statutSync: 0,
        posteId: posteId,
        nomPoste: nomPoste,
        nomAgent: nomAgent
      );

      final id = await DatabaseService.instance.insertPaiement(paiement);
      _lastPaiement = paiement.copyWith(id: id);
      _lastQrData = QrService.instance.generateQrData(_lastPaiement!);

      reset();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'enregistrement';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> printReceipt() async {
    if (_lastPaiement != null && _lastQrData != null) {
      await PrintService.instance.printReceipt(_lastPaiement!, _lastQrData!);
    }
  }

  Future<void> shareReceipt() async {
    if (_lastPaiement != null && _lastQrData != null) {
      await PrintService.instance.sharePdf(_lastPaiement!, _lastQrData!);
    }
  }

  void reset() {
    _selectedEngin = null;
    _conducteurNom = '';
    _quantite = 1;
    _error = null;
  }

  void clearLastPaiement() {
    _lastPaiement = null;
    _lastQrData = null;
    notifyListeners();
  }
}
