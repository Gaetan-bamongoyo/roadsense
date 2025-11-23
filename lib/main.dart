import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadsense/print.dart';
import 'package:roadsense/theme.dart';
import 'package:roadsense/services/database_service.dart';
import 'package:roadsense/services/storage_service.dart';
import 'package:roadsense/services/sync_service.dart';
import 'package:roadsense/viewmodels/auth_viewmodel.dart';
import 'package:roadsense/viewmodels/paiement_viewmodel.dart';
import 'package:roadsense/viewmodels/historique_viewmodel.dart';
import 'package:roadsense/viewmodels/sync_viewmodel.dart';
import 'package:roadsense/views/auth/login_view.dart';
import 'package:roadsense/views/home/home_view.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await StorageService.instance.init();
  await DatabaseService.instance.database;
  await initializeDateFormatting('fr_FR', null);
  
  SyncService.instance.startAutoSync();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PaiementViewModel()),
        ChangeNotifierProvider(create: (_) => HistoriqueViewModel()),
        ChangeNotifierProvider(create: (_) => SyncViewModel()),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          authViewModel.checkAuthStatus();
          
          return MaterialApp(
            title: 'RoadSense',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            home: authViewModel.isAuthenticated ? const HomeView() : const LoginView(),
            // home: ButtonPrint(),
          );
        },
      ),
    );
  }
}

class ButtonPrint extends StatefulWidget {
  const ButtonPrint({super.key});

  @override
  State<ButtonPrint> createState() => _ButtonPrintState();
}

class _ButtonPrintState extends State<ButtonPrint> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => printPaiementTicket(),
          child: Text("Print"),
        ),
      ),
    );
  }
}
