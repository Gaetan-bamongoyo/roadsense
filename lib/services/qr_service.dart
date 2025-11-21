import 'package:roadsense/models/paiement.dart';

class QrService {
  static final QrService instance = QrService._init();

  QrService._init();

  String generateQrData(Paiement paiement) => paiement.toQrString();

  Map<String, String>? parseQrData(String qrData) {
    try {
      final parts = qrData.split('|');
      if (parts.length != 7 || parts[0] != 'RoadTax') return null;
      
      return {
        'conducteur': parts[1],
        'engin': parts[2],
        'montant': parts[3],
        'date': parts[4],
        'poste': parts[5],
        'id': parts[6],
      };
    } catch (e) {
      return null;
    }
  }
}
