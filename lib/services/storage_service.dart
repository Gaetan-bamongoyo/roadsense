import 'dart:convert';

import 'package:roadsense/models/categorie.dart';
import 'package:roadsense/models/engin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService instance = StorageService._init();
  SharedPreferences? _prefs;

  StorageService._init();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveUserSession(
    int userId,
    String nomPoste,
    String agentNom,
  ) async {
    await _prefs?.setInt('user_id', userId);
    await _prefs?.setString('nom_poste', nomPoste);
    await _prefs?.setString('agent_nom', agentNom);
    await _prefs?.setBool('is_logged_in', true);
  }

  Future<List<Categorie>> loadCategorie() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('categories');
    // print(data);

    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => Categorie.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<void> saveCategorie(List<Categorie> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = categories.map((s) => s.toJson()).toList();
    await prefs.setString('categories', jsonEncode(jsonList));
  }

  Future<List<Taxe>> loadTarif() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tarifs');
    print(data);

    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => Taxe.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<void> saveTarif(List<Taxe> tarifs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tarifs.map((s) => s.toJson()).toList();
    await prefs.setString('tarifs', jsonEncode(jsonList));
  }

  Future<void> clearUserSession() async {
    await _prefs?.remove('user_id');
    await _prefs?.remove('nom_poste');
    await _prefs?.remove('agent_nom');
    await _prefs?.setBool('is_logged_in', false);
  }

  bool get isLoggedIn => _prefs?.getBool('is_logged_in') ?? false;
  int? get userId => _prefs?.getInt('user_id');
  String? get nomPoste => _prefs?.getString('nom_poste');
  String? get agentNom => _prefs?.getString('agent_nom');
}
