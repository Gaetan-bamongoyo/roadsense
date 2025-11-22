import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadsense/viewmodels/auth_viewmodel.dart';
import 'package:roadsense/viewmodels/paiement_viewmodel.dart';
import 'package:roadsense/models/engin.dart';
import 'package:roadsense/views/receipt/receipt_view.dart';

class NouveauPaiementView extends StatefulWidget {
  const NouveauPaiementView({super.key, required this.idcategorie});
  final int idcategorie;

  @override
  State<NouveauPaiementView> createState() => _NouveauPaiementViewState();
}

class _NouveauPaiementViewState extends State<NouveauPaiementView> {
  final _conducteurController = TextEditingController();

  IconData _iconFromName(String iconName) {
    switch (iconName) {
      case 'two_wheeler':
        return Icons.two_wheeler;
      case 'directions_car':
        return Icons.directions_car;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'pedal_bike':
        return Icons.pedal_bike;
      case 'airport_shuttle':
        return Icons.airport_shuttle;
      case 'category':
        return Icons.category;
      default:
        return Icons.category;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaiementViewModel>().getEnginById(widget.idcategorie);
    });
  }

  @override
  void dispose() {
    _conducteurController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final authViewModel = context.read<AuthViewModel>();
    final paiementViewModel = context.read<PaiementViewModel>();

    if (authViewModel.currentUser == null) return;

    final success = await paiementViewModel.enregistrerPaiement(
      authViewModel.currentUser!.id!,
      authViewModel.currentUser!.nomPoste,
    );

    if (success && mounted) {
      _conducteurController.clear();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReceiptView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paiementViewModel = context.watch<PaiementViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau Paiement'),
      ),
      body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Informations du paiement',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Nom du conducteur',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _conducteurController,
                      decoration: InputDecoration(
                        hintText: 'Entrer le nom du conducteur',
                        prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
                      ),
                      onChanged: (value) {
                        paiementViewModel.setConducteurNom(value);
                      },
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Rechercher un engin',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Tapez pour filtrer (ex: voiture, moto...)',
                        prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                      ),
                      onChanged: paiementViewModel.setSearchQuery,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Type d\'engin',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 12),
                    if (paiementViewModel.engins.isEmpty)
                      Center(
                        child: Text(
                          'Aucun engin disponible',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else
                      ...paiementViewModel.filteredEngins.map((engin) => EnginCard(
                        engin: engin,
                        isSelected: paiementViewModel.selectedEngin?.id == engin.id,
                        onTap: () => paiementViewModel.selectEngin(engin),
                      )),
                    SizedBox(height: 32),
                    if (paiementViewModel.selectedEngin != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Quantité',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: paiementViewModel.decrementQuantite,
                                  icon: Icon(Icons.remove, color: theme.colorScheme.primary),
                                ),
                                Text(
                                  '${paiementViewModel.quantite}',
                                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  onPressed: paiementViewModel.incrementQuantite,
                                  icon: Icon(Icons.add, color: theme.colorScheme.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Montant à \n payer",
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(paiementViewModel.selectedEngin!.tarif * paiementViewModel.quantite).toStringAsFixed(0)} FCFA',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                    ],
                    if (paiementViewModel.error != null) ...[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          paiementViewModel.error!,
                          style: TextStyle(color: theme.colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    ElevatedButton(
                      onPressed: paiementViewModel.canSubmit && !paiementViewModel.isLoading
                          ? _handleSubmit
                          : null,
                      child: paiementViewModel.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text('VALIDER LE PAIEMENT'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class EnginCard extends StatelessWidget {
  final Taxe engin;
  final bool isSelected;
  final VoidCallback onTap;

  const EnginCard({
    super.key,
    required this.engin,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'two_wheeler':
        return Icons.two_wheeler;
      case 'directions_car':
        return Icons.directions_car;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'pedal_bike':
        return Icons.pedal_bike;
      case 'airport_shuttle':
        return Icons.airport_shuttle;
      default:
        return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Card(
        color: isSelected ? theme.colorScheme.primaryContainer : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.2)
                        : theme.colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(engin.iconName),
                    size: 32,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        engin.nom,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${engin.tarif.toStringAsFixed(0)} FCFA',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
