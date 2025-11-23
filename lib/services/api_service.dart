import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roadsense/models/categorie.dart';
import 'package:roadsense/models/engin.dart';
import 'package:roadsense/models/paiement.dart';
import 'package:roadsense/models/user.dart';
import 'package:roadsense/services/storage_service.dart';

class ApiService {
  static final ApiService instance = ApiService._init();
  // final String baseUrl = 'http://108.181.203.54:8081/roadsense';
  final String baseUrl = 'http://192.168.1.204:8081/roadsense';

  ApiService._init();

  Future<bool> syncPaiement(Paiement paiement) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/paiement/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "conducteur_nom": paiement.conducteurNom,
          "montant": paiement.montant,
          "date_paiement": paiement.datePaiement.toIso8601String(),
          "tarif_id": paiement.typeEnginId,
          "poste_id": paiement.posteId,
          "quantite": paiement.quantite,
          "nom_agent": paiement.nomAgent
        }),
      );
      print("Status ${paiement.nomAgent}: ${response.statusCode}");
      print("Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> syncEngin() async {
    final response = await http
        .get(Uri.parse('$baseUrl/tarif/show'))
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final convert = json as List<dynamic>;
      final data = convert.map((e) => Taxe.fromJson(e)).toList();
      await StorageService.instance.saveTarif(data);
      return true;
    } else {
      throw Exception('Echec de synchronisation');
    }
  }

  Future<bool> syncCategorie() async {
    final response = await http
        .get(Uri.parse('$baseUrl/categorietaxe/show'))
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final convert = json as List<dynamic>;
      final data = convert.map((e) => Categorie.fromJson(e)).toList();
      print(data);
      await StorageService.instance.saveCategorie(data);
      return true;
    } else {
      throw Exception('Echec de synchronisation');
    }
  }

  Future<bool> verifyQrCode(String qrData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/verify-qr'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'qr_data': qrData}),
          )
          .timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginuser(String nom, String motdepasse) async {
    final response = await http.post(
      Uri.parse('$baseUrl/poste/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "nom_poste":nom,
        "mot_de_passe":motdepasse
      }),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final convert = json['poste'] as List<dynamic>;
      final data = convert.map((e) => User.fromJson(e)).toList();
      await StorageService.instance.saveUserSessionOnLigne();
      print(data);
      return true;
    } else {
      return false;
    }
  }
}
