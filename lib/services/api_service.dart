import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roadsense/models/engin.dart';
import 'package:roadsense/models/paiement.dart';
import 'package:roadsense/services/storage_service.dart';

class ApiService {
  static final ApiService instance = ApiService._init();
  final String baseUrl = 'http://108.181.203.54:8081/roadsense';

  ApiService._init();

  Future<bool> syncPaiement(Paiement paiement) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/paiement/add'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "conducteur_nom": paiement.conducteurNom,
              "montant": paiement.montant,
              "date_paiement": paiement.datePaiement,
              "tarif_id": paiement.typeEnginId,
              "poste_id": paiement.posteId,
            }),
          )
          .timeout(Duration(seconds: 10));

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
      // print(data);
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
      body: jsonEncode({}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      StorageService.instance.saveUserSession(
        data['poste']['id'],
        data['poste']['nom_poste'],
        data['poste']['agent_nom'],
      );
      return true;
    } else {
      return false;
    }
  }
}
