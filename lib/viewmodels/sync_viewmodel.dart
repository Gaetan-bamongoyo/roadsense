import 'package:flutter/foundation.dart';
import 'package:roadsense/services/sync_service.dart';

class SyncViewModel extends ChangeNotifier {
  bool _isConnected = false;
  bool _isSyncing = false;
  String? _lastSyncMessage;

  bool get isConnected => _isConnected;
  bool get isSyncing => _isSyncing;
  String? get lastSyncMessage => _lastSyncMessage;

  Future<void> checkConnectivity() async {
    _isConnected = await SyncService.instance.isConnected();
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _lastSyncMessage = null;
    notifyListeners();

    try {
      _isConnected = await SyncService.instance.isConnected();

      if (!_isConnected) {
        _lastSyncMessage = 'Pas de connexion Internet';
        _isSyncing = false;
        notifyListeners();
        return;
      }

      final result = await SyncService.instance.syncPaiements();
      final tarif = await SyncService.instance.syncEngins();
      String message = '';

      if (tarif.total == 0) {
        message += 'Aucun tarif à synchroniser';
      } else if (result.failed == 0) {
        message += '${tarif.success} tarif synchronisés avec succès';
      } else {
        message += '${tarif.success} synchronisés, ${result.failed} échoués';
      }

      if (result.total == 0) {
        message += 'Aucun paiement à synchroniser';
      } else if (result.failed == 0) {
        message += '${result.success} paiements synchronisés avec succès';
      } else {
        message += '${result.success} synchronisés, ${result.failed} échoués';
      }

      _lastSyncMessage = message.trim();

      _isSyncing = false;
      notifyListeners();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Erreur de synchronisation: $e');
        print(stackTrace);
      }
      _lastSyncMessage = 'Erreur de synchronisation : ${e.toString()}';
      _isSyncing = false;
      notifyListeners();
    }
  }

  void clearMessage() {
    _lastSyncMessage = null;
    notifyListeners();
  }
}
