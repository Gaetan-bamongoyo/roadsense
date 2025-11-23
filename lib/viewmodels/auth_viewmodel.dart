import 'package:flutter/foundation.dart';
import 'package:roadsense/models/user.dart';
import 'package:roadsense/services/database_service.dart';
import 'package:roadsense/services/storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuthStatus() async {
    if (StorageService.instance.isLoggedIn && StorageService.instance.userId != null) {
      final nomPoste = StorageService.instance.nomPoste;
      if (nomPoste != null) {
        final user = await DatabaseService.instance.getPosteByNom(nomPoste);
        if (user != null) {
          _currentUser = user;
          notifyListeners();
        }
      }
    }
  }

  Future<bool> login(String nomPoste, String motDePasse) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await DatabaseService.instance.getPosteByNom(nomPoste);
      
      if (user == null) {
        _error = 'Poste non trouvé';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (user.motDePasse != motDePasse) {
        _error = 'Mot de passe incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      await StorageService.instance.saveUserSession(user.id!, user.nomPoste, user.agentNom);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur de connexion $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  } 

  Future<void> logout() async {
    await StorageService.instance.clearUserSession();
    _currentUser = null;
    notifyListeners();
  }
}
