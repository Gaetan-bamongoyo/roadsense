import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadsense/viewmodels/auth_viewmodel.dart';
import 'package:roadsense/viewmodels/sync_viewmodel.dart';
import 'package:roadsense/views/home/categorie_view.dart';
import 'package:roadsense/views/historique/historique_view.dart';
import 'package:roadsense/views/auth/login_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SyncViewModel>().checkConnectivity();
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthViewModel>().logout();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  Future<void> _handleSync() async {
    final syncViewModel = context.read<SyncViewModel>();
    await syncViewModel.syncNow();
    
    if (mounted && syncViewModel.lastSyncMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(syncViewModel.lastSyncMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.watch<AuthViewModel>();
    final syncViewModel = context.watch<SyncViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('RoadSense'),
            if (authViewModel.currentUser != null)
              Text(
                authViewModel.currentUser!.nomPoste,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _handleSync,
            icon: syncViewModel.isSyncing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Icon(
                    syncViewModel.isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: Colors.white,
                  ),
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bienvenue,',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                authViewModel.currentUser?.agentNom ?? 'Agent',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              HomeActionCard(
                icon: Icons.payment,
                iconColor: theme.colorScheme.primary,
                title: 'Nouveau Paiement',
                description: 'Enregistrer une taxe routière',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OperationChoiceScreen()),
                  );
                },
              ),
              SizedBox(height: 20),
              HomeActionCard(
                icon: Icons.history,
                iconColor: theme.colorScheme.tertiary,
                title: 'Historique',
                description: 'Consulter les paiements',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoriqueView()),
                  );
                },
              ),
              SizedBox(height: 20),
              HomeActionCard(
                icon: Icons.sync,
                iconColor: theme.colorScheme.secondary,
                title: 'Synchroniser',
                description: 'Synchroniser avec le serveur',
                onTap: _handleSync,
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      syncViewModel.isConnected ? Icons.wifi : Icons.wifi_off,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            syncViewModel.isConnected ? 'Connecté' : 'Hors ligne',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            syncViewModel.isConnected
                                ? 'Synchronisation automatique active'
                                : 'Les paiements seront synchronisés plus tard',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  const HomeActionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: iconColor),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: theme.colorScheme.secondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
