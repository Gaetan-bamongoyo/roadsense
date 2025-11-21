import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:roadsense/viewmodels/paiement_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:roadsense/services/storage_service.dart';

class ReceiptView extends StatelessWidget {
  const ReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paiementViewModel = context.watch<PaiementViewModel>();
    final paiement = paiementViewModel.lastPaiement;
    final qrData = paiementViewModel.lastQrData;
    final agentNom = StorageService.instance.agentNom ?? '';

    if (paiement == null || qrData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Reçu')),
        body: Center(child: Text('Aucun reçu disponible')),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: Text('Reçu de Paiement'),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            paiementViewModel.clearLastPaiement();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    width: 320, // simulate 80mm roll on screen
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'mRecettes',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.5),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'QUITTANCE',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 6),
                        Text('--------------------------------', textAlign: TextAlign.center, style: theme.textTheme.labelSmall),
                        SizedBox(height: 6),
                        _TicketLine(label: 'Centre de perception', value: paiement.nomPoste),
                        _TicketLine(label: 'Date', value: dateFormat.format(paiement.datePaiement)),
                        _TicketLine(label: 'Ref Quitt', value: '${paiement.id ?? ''}'),
                        SizedBox(height: 8),
                        _TicketLine(label: 'Assujeti', value: paiement.conducteurNom),
                        _TicketLine(label: 'Montant encaissé', value: '${(paiement.montant * paiement.quantite).toStringAsFixed(0)} CDF'),
                        _TicketLine(label: 'Mode', value: 'Espèces'),
                        SizedBox(height: 10),
                        Text('Liste des tarifs / Description', style: theme.textTheme.bodySmall, textAlign: TextAlign.left),
                        SizedBox(height: 6),
                        Text('1. ${paiement.typeEnginNom}', style: theme.textTheme.bodyMedium),
                        SizedBox(height: 4),
                        _TicketLine(label: 'Prix', value: '${paiement.montant.toStringAsFixed(0)} CDF'),
                        _TicketLine(label: 'Qt', value: '${paiement.quantite}'),
                        SizedBox(height: 10),
                        _TicketLine(label: 'Guichet', value: agentNom.isNotEmpty ? agentNom : '—'),
                        SizedBox(height: 14),
                        Align(
                          alignment: Alignment.center,
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 160,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await paiementViewModel.printReceipt();
                    },
                    icon: Icon(Icons.print, color: Colors.white),
                    label: Text('IMPRIMER'),
                  ),
                  SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await paiementViewModel.shareReceipt();
                    },
                    icon: Icon(Icons.share),
                    label: Text('PARTAGER'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketLine extends StatelessWidget {
  final String label;
  final String value;

  const _TicketLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final styleLabel = Theme.of(context).textTheme.bodySmall;
    final styleValue = Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: styleLabel)),
          const SizedBox(width: 8),
          Flexible(child: Text(value, style: styleValue, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

