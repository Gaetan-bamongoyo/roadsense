import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadsense/viewmodels/historique_viewmodel.dart';
import 'package:roadsense/models/paiement.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class HistoriqueView extends StatefulWidget {
  const HistoriqueView({super.key});

  @override
  State<HistoriqueView> createState() => _HistoriqueViewState();
}

class _HistoriqueViewState extends State<HistoriqueView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoriqueViewModel>().loadPaiements();
    });
  }

  Future<void> _selectDate() async {
    final histoViewModel = context.read<HistoriqueViewModel>();
    final picked = await showDatePicker(
      context: context,
      initialDate: histoViewModel.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      histoViewModel.changeDate(picked);
    }
  }

  Future<void> _exportExcel() async {
    final histoViewModel = context.read<HistoriqueViewModel>();
    
    if (histoViewModel.paiements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucun paiement à exporter')),
      );
      return;
    }

    final filePath = await histoViewModel.exportToExcel();
    
    if (filePath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rapport Excel créé avec succès'),
          action: SnackBarAction(
            label: 'PARTAGER',
            onPressed: () {
              Share.shareXFiles([XFile(filePath)], text: 'Rapport journalier');
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final histoViewModel = context.watch<HistoriqueViewModel>();
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: Text('Historique'),
        actions: [
          IconButton(
            onPressed: _exportExcel,
            icon: Icon(Icons.file_download, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              color: theme.colorScheme.primaryContainer,
              child: Column(
                children: [
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                          SizedBox(width: 12),
                          Text(
                            dateFormat.format(histoViewModel.selectedDate),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          icon: Icons.receipt_long,
                          label: 'Paiements',
                          value: '${histoViewModel.nombrePaiements}',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          icon: Icons.cloud_done,
                          label: 'Synchronisés',
                          value: '${histoViewModel.nombreSynchronises}',
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          icon: Icons.cloud_off,
                          label: 'En attente',
                          value: '${histoViewModel.nombreNonSynchronises}',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${histoViewModel.total.toStringAsFixed(0)} CDF',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: histoViewModel.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : histoViewModel.paiements.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 80,
                                color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucun paiement ce jour',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => histoViewModel.loadPaiements(),
                          child: ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: histoViewModel.paiements.length,
                            itemBuilder: (context, index) {
                              final paiement = histoViewModel.paiements[index];
                              return PaiementCard(
                                paiement: paiement,
                                timeFormat: timeFormat,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const StatsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class PaiementCard extends StatelessWidget {
  final Paiement paiement;
  final DateFormat timeFormat;

  const PaiementCard({
    super.key,
    required this.paiement,
    required this.timeFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paiement.conducteurNom,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        paiement.typeEnginNom,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(paiement.montant * paiement.quantite).toStringAsFixed(0)} CDF',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      timeFormat.format(paiement.datePaiement),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  paiement.estSynchronise ? Icons.cloud_done : Icons.cloud_off,
                  size: 16,
                  color: paiement.estSynchronise ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 6),
                Text(
                  paiement.estSynchronise ? 'Synchronisé' : 'En attente de sync',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: paiement.estSynchronise ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Text(
                  'Reçu #${paiement.id}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
