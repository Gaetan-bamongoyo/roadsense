import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:roadsense/services/database_service.dart';
import 'package:roadsense/services/api_service.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService._init();

  void startAutoSync() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        syncPaiements();
      }
    });
  }

  void stopAutoSync() {
    _connectivitySubscription?.cancel();
  }

  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty && results.first != ConnectivityResult.none;
  }

  Future<SyncResult> syncPaiements() async {
    if (_isSyncing) return SyncResult(success: 0, failed: 0, total: 0);
    
    _isSyncing = true;
    int success = 0;
    int failed = 0;

    try {
      if (!await isConnected()) {
        _isSyncing = false;
        return SyncResult(success: 0, failed: 0, total: 0);
      }

      final paiements = await DatabaseService.instance.getPaiementsNonSynchronises();
      
      for (var paiement in paiements) {
        final synced = await ApiService.instance.syncPaiement(paiement);
        if (synced && paiement.id != null) {
          await DatabaseService.instance.updatePaiementStatutSync(paiement.id!, 1);
          success++;
        } else {
          failed++;
        }
      }

      return SyncResult(success: success, failed: failed, total: paiements.length);
    } finally {
      _isSyncing = false;
    }
  }

  Future<SyncResult> syncEngins() async {
    if (_isSyncing) return SyncResult(success: 0, failed: 0, total: 0);
    
    _isSyncing = true;
    int success = 0;
    int failed = 0;

    try {
      if (!await isConnected()) {
        _isSyncing = false;
        return SyncResult(success: 0, failed: 0, total: 0);
      }

      final result = await ApiService.instance.syncEngin();
      final categorie = await ApiService.instance.syncCategorie();

      if (result != false && categorie != false){
        success++;
      }

      return SyncResult(success: success, failed: failed, total: success);
    } finally {
      _isSyncing = false;
    }
  }
}

class SyncResult {
  final int success;
  final int failed;
  final int total;

  SyncResult({required this.success, required this.failed, required this.total});
}
