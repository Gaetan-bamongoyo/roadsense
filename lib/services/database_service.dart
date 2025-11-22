import 'package:roadsense/models/categorie.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:roadsense/models/user.dart';
import 'package:roadsense/models/engin.dart';
import 'package:roadsense/models/paiement.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  /// Retourne la base de données initialisée ou la crée si nécessaire
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('roadsense.db');
    return _database!;
  }

  /// Initialise la base de données SQLite
  Future<Database> _initDB(String filePath) async {
    final dbPath =
        await getDatabasesPath(); // Nécessite WidgetsFlutterBinding.ensureInitialized()
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// Création des tables lors de la première initialisation
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE postes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom_poste TEXT NOT NULL UNIQUE,
        agent_nom TEXT NOT NULL,
        mot_de_passe TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        designation TEXT NOT NULL UNIQUE,
        icon_name TEXT,
        description TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE engins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        tarif REAL NOT NULL,
        icon_name TEXT NOT NULL,
        categorie_id INTEGER,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (categorie_id) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE paiements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conducteur_nom TEXT NOT NULL,
        type_engin_id INTEGER NOT NULL,
        type_engin_nom TEXT NOT NULL,
        quantite INTERGER NOT NULL,
        montant REAL NOT NULL,
        date_paiement TEXT NOT NULL,
        statut_sync INTEGER DEFAULT 0,
        poste_id INTEGER NOT NULL,
        nom_poste TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (type_engin_id) REFERENCES engins (id),
        FOREIGN KEY (poste_id) REFERENCES postes (id)
      )
    ''');

    await _insertDefaultData(db);
  }

  /// Insertion des données initiales
  Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert('postes', {
      'nom_poste': 'A1',
      'agent_nom': 'Agent Demo',
      'mot_de_passe': 'demo123',
      'createdAt': now,
      'updatedAt': now,
    });

    final engins = [
      {
        'nom': 'Moto',
        'tarif': 500.0,
        'icon_name': 'two_wheeler',
        'categorie_id': 1,
      },
      {
        'nom': 'Tricycle',
        'tarif': 300.0,
        'icon_name': 'pedal_bike',
        'categorie_id': 1,
      },
      {
        'nom': 'Voiture',
        'tarif': 1000.0,
        'icon_name': 'directions_car',
        'categorie_id': 2,
      },
      {
        'nom': 'Camionnette',
        'tarif': 1500.0,
        'icon_name': 'airport_shuttle',
        'categorie_id': 2,
      },
      {
        'nom': 'Bus',
        'tarif': 2500.0,
        'icon_name': 'directions_bus',
        'categorie_id': 3,
      },
      {
        'nom': 'Camion',
        'tarif': 3500.0,
        'icon_name': 'local_shipping',
        'categorie_id': 4,
      },
    ];

    for (var engin in engins) {
      await db.insert('engins', {
        ...engin,
        'createdAt': now,
        'updatedAt': now,
      });
    }

    final categories = [
      {
        'id': 1,
        'designation': 'Deux Roues',
        'icon_name': 'two_wheeler',
        'description': 'Motos, tricycles, etc.',
      },
      {
        'id': 2,
        'designation': 'Voitures',
        'icon_name': 'directions_car',
        'description': 'Véhicules légers',
      },
      {
        'id': 3,
        'designation': 'Transport',
        'icon_name': 'directions_bus',
        'description': 'Bus et minibus',
      },
      {
        'id': 4,
        'designation': 'Camions',
        'icon_name': 'local_shipping',
        'description': 'Poids lourds',
      },
      {
        'id': 5,
        'designation': 'Autres',
        'icon_name': 'category',
        'description': 'Autres catégories',
      },
    ];
    for (var cat in categories) {
      await db.insert('categories', {
        ...cat,
        'createdAt': now,
        'updatedAt': now,
      });
    }
  }

  Future<List<Categorie>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'designation ASC');
    return maps.map((m) => Categorie.fromJson(m)).toList();
  }

  /// Rechercher un poste par nom
  Future<User?> getPosteByNom(String nomPoste) async {
    final db = await database;
    final maps = await db.query(
      'postes',
      where: 'nom_poste = ?',
      whereArgs: [nomPoste],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    // print(maps);
    return User.fromJson(maps.first);
  }

  /// Récupérer tous les engins
  Future<List<Taxe>> getAllEnginsById(int id) async {
    final db = await database;
    final maps = await db.query(
      'engins',
      where: 'categorie_id = ?',
      whereArgs: [id],
    );
    // print(maps);
    return maps.map((map) => Taxe.fromJson(map)).toList();
  }

  /// Récupérer un engin par ID
  Future<Taxe?> getEnginById(int id) async {
    final db = await database;
    final maps = await db.query(
      'engins',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Taxe.fromJson(maps.first);
  }

  /// Insérer un paiement
  Future<int> insertPaiement(Paiement paiement) async {
    final db = await database;
    return await db.insert('paiements', paiement.toJson());
  }

  /// Récupérer les paiements d’une date donnée
  Future<List<Paiement>> getPaiementsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final maps = await db.query(
      'paiements',
      where: 'date_paiement >= ? AND date_paiement < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'date_paiement DESC',
    );

    return maps.map((map) => Paiement.fromJson(map)).toList();
  }

  /// Récupérer les paiements non synchronisés
  Future<List<Paiement>> getPaiementsNonSynchronises() async {
    final db = await database;
    final maps = await db.query(
      'paiements',
      where: 'statut_sync = ?',
      whereArgs: [0],
    );
    print(maps);
    return maps.map((map) => Paiement.fromJson(map)).toList();
  }

  /// Mettre à jour le statut de synchronisation d’un paiement
  Future<int> updatePaiementStatutSync(int id, int statut) async {
    final db = await database;
    return await db.update(
      'paiements',
      {'statut_sync': statut, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Obtenir le total des paiements pour une date donnée
  Future<double> getTotalPaiementsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT SUM(montant * quantite) as total FROM paiements WHERE date_paiement >= ? AND date_paiement < ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Fermer la base
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:roadsense/models/user.dart';
// import 'package:roadsense/models/engin.dart';
// import 'package:roadsense/models/paiement.dart';
// import 'package:roadsense/models/categorie.dart';

// class DatabaseService {
//   static final DatabaseService instance = DatabaseService._init();
//   static Database? _database;

//   DatabaseService._init();

//   /// Retourne la base de données initialisée ou la crée si nécessaire
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('roadsent.db');
//     return _database!;
//   }

//   /// Initialise la base de données SQLite
//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath(); // Nécessite WidgetsFlutterBinding.ensureInitialized()
//     final path = join(dbPath, filePath);
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _createDB,
//     );
//   }

//   /// Création des tables lors de la première initialisation
//   Future<void> _createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE postes (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         nom_poste TEXT NOT NULL UNIQUE,
//         agent_nom TEXT NOT NULL,
//         mot_de_passe TEXT NOT NULL,
//         created_at TEXT NOT NULL,
//         updated_at TEXT NOT NULL
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE categories (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         designation TEXT NOT NULL UNIQUE,
//         icon_name TEXT,
//         description TEXT,
//         created_at TEXT NOT NULL,
//         updated_at TEXT NOT NULL
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE engins (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         nom TEXT NOT NULL,
//         tarif REAL NOT NULL,
//         icon_name TEXT NOT NULL,
//         categorie_id INTEGER,
//         created_at TEXT NOT NULL,
//         updated_at TEXT NOT NULL,
//         FOREIGN KEY (categorie_id) REFERENCES categories (id)
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE paiements (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         conducteur_nom TEXT NOT NULL,
//         type_engin_id INTEGER NOT NULL,
//         type_engin_nom TEXT NOT NULL,
//         montant REAL NOT NULL,
//         quantite INTEGER NOT NULL DEFAULT 1,
//         date_paiement TEXT NOT NULL,
//         statut_sync INTEGER DEFAULT 0,
//         poste_id INTEGER NOT NULL,
//         nom_poste TEXT NOT NULL,
//         created_at TEXT NOT NULL,
//         updated_at TEXT NOT NULL,
//         FOREIGN KEY (type_engin_id) REFERENCES engins (id),
//         FOREIGN KEY (poste_id) REFERENCES postes (id)
//       )
//     ''');

//     await _insertDefaultData(db);
//   }

//   /// Insertion des données initiales
//   Future<void> _insertDefaultData(Database db) async {
//     final now = DateTime.now().toIso8601String();

//     await db.insert('postes', {
//       'nom_poste': 'A1',
//       'agent_nom': 'Agent Demo',
//       'mot_de_passe': 'demo123',
//       'created_at': now,
//       'updated_at': now,
//     });

//     // Seed categories with fixed IDs for easy FK assignment
//     final categories = [
//       {'id': 1, 'designation': 'Deux Roues', 'icon_name': 'two_wheeler', 'description': 'Motos, tricycles, etc.'},
//       {'id': 2, 'designation': 'Voitures', 'icon_name': 'directions_car', 'description': 'Véhicules légers'},
//       {'id': 3, 'designation': 'Transport', 'icon_name': 'directions_bus', 'description': 'Bus et minibus'},
//       {'id': 4, 'designation': 'Camions', 'icon_name': 'local_shipping', 'description': 'Poids lourds'},
//       {'id': 5, 'designation': 'Autres', 'icon_name': 'category', 'description': 'Autres catégories'},
//     ];
//     for (var cat in categories) {
//       await db.insert('categories', {
//         ...cat,
//         'created_at': now,
//         'updated_at': now,
//       });
//     }

//     final engins = [
//       {'nom': 'Moto', 'tarif': 500.0, 'icon_name': 'two_wheeler', 'categorie_id': 1},
//       {'nom': 'Tricycle', 'tarif': 300.0, 'icon_name': 'pedal_bike', 'categorie_id': 1},
//       {'nom': 'Voiture', 'tarif': 1000.0, 'icon_name': 'directions_car', 'categorie_id': 2},
//       {'nom': 'Camionnette', 'tarif': 1500.0, 'icon_name': 'airport_shuttle', 'categorie_id': 2},
//       {'nom': 'Bus', 'tarif': 2500.0, 'icon_name': 'directions_bus', 'categorie_id': 3},
//       {'nom': 'Camion', 'tarif': 3500.0, 'icon_name': 'local_shipping', 'categorie_id': 4},
//     ];

//     for (var engin in engins) {
//       await db.insert('engins', {
//         ...engin,
//         'created_at': now,
//         'updated_at': now,
//       });
//     }
//   }

//   /// Rechercher un poste par nom
//   Future<User?> getPosteByNom(String nomPoste) async {
//     final db = await database;
//     final maps = await db.query(
//       'postes',
//       where: 'nom_poste = ?',
//       whereArgs: [nomPoste],
//       limit: 1,
//     );
//     if (maps.isEmpty) return null;
//     return User.fromJson(maps.first);
//   }

//   /// Récupérer tous les engins
//   Future<List<Taxe>> getAllEngins() async {
//     final db = await database;
//     final maps = await db.query('engins', orderBy: 'tarif ASC');
//     return maps.map((map) => Taxe.fromJson(map)).toList();
//   }

//   /// Récupérer un engin par ID
//   Future<Taxe?> getEnginById(int id) async {
//     final db = await database;
//     final maps = await db.query(
//       'engins',
//       where: 'id = ?',
//       whereArgs: [id],
//       limit: 1,
//     );
//     if (maps.isEmpty) return null;
//     return Taxe.fromJson(maps.first);
//   }

//   /// Récupérer toutes les catégories
//   Future<List<Categorie>> getAllCategories() async {
//     final db = await database;
//     final maps = await db.query('categories', orderBy: 'designation ASC');
//     return maps.map((m) => Categorie.fromJson(m)).toList();
//   }

//   /// Insérer un paiement
//   Future<int> insertPaiement(Paiement paiement) async {
//     final db = await database;
//     return await db.insert('paiements', paiement.toJson());
//   }

//   /// Récupérer les paiements d’une date donnée
//   Future<List<Paiement>> getPaiementsByDate(DateTime date) async {
//     final db = await database;
//     final startOfDay = DateTime(date.year, date.month, date.day);
//     final endOfDay = startOfDay.add(Duration(days: 1));

//     final maps = await db.query(
//       'paiements',
//       where: 'date_paiement >= ? AND date_paiement < ?',
//       whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
//       orderBy: 'date_paiement DESC',
//     );

//     return maps.map((map) => Paiement.fromJson(map)).toList();
//   }

//   /// Récupérer les paiements non synchronisés
//   Future<List<Paiement>> getPaiementsNonSynchronises() async {
//     final db = await database;
//     final maps = await db.query('paiements', where: 'statut_sync = ?', whereArgs: [0]);
//     return maps.map((map) => Paiement.fromJson(map)).toList();
//   }

//   /// Mettre à jour le statut de synchronisation d’un paiement
//   Future<int> updatePaiementStatutSync(int id, int statut) async {
//     final db = await database;
//     return await db.update(
//       'paiements',
//       {
//         'statut_sync': statut,
//         'updated_at': DateTime.now().toIso8601String(),
//       },
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   /// Obtenir le total des paiements pour une date donnée
//   Future<double> getTotalPaiementsByDate(DateTime date) async {
//     final db = await database;
//     final startOfDay = DateTime(date.year, date.month, date.day);
//     final endOfDay = startOfDay.add(Duration(days: 1));

//     final result = await db.rawQuery(
//       'SELECT SUM(montant) as total FROM paiements WHERE date_paiement >= ? AND date_paiement < ?',
//       [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
//     );

//     return (result.first['total'] as num?)?.toDouble() ?? 0.0;
//   }

//   /// Fermer la base
//   Future<void> close() async {
//     final db = await database;
//     await db.close();
//   }
// }
