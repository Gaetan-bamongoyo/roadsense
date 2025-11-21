import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadsense/viewmodels/paiement_viewmodel.dart';
import 'package:roadsense/views/paiement/nouveau_paiement_view.dart';

class OperationChoiceScreen extends StatefulWidget {
  const OperationChoiceScreen({super.key});

  @override
  State<OperationChoiceScreen> createState() => _OperationChoiceScreenState();
}

class _OperationChoiceScreenState extends State<OperationChoiceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaiementViewModel>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paiementViewModel = context.watch<PaiementViewModel>();
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     // Handle back button press
        //   },
        // ),
        title: const Text('Choix de l\'opération'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blueAccent),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Faites ci-dessous le choix entre les différents types de '
                    'taxe (Péage Route, Pont ou Autres) que vous voulez '
                    'effectuer.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            paiementViewModel.categories.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      ...paiementViewModel.categories.map((cat) {
                        return _buildOperationCard(
                          icon: Icons.directions_car,
                          title: 'Taxation > ${cat.designation}',
                          description: cat.description,
                          id: cat.id!
                        );
                      }),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationCard({
    required IconData icon,
    required String title,
    required String description,
    required int id,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NouveauPaiementView(idcategorie: id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 40.0, color: Colors.blue[700]),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16.0,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
