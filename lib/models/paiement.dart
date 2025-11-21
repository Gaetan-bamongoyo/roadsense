class Paiement {
  final int? id;
  final String conducteurNom;
  final int typeEnginId;
  final String typeEnginNom;
  final double montant;
  final int quantite;
  final DateTime datePaiement;
  final int statutSync;
  final int posteId;
  final String nomPoste;
  final DateTime createdAt;
  final DateTime updatedAt;

  Paiement({
    this.id,
    required this.conducteurNom,
    required this.typeEnginId,
    required this.typeEnginNom,
    required this.montant,
    this.quantite = 1,
    required this.datePaiement,
    this.statutSync = 0,
    required this.posteId,
    required this.nomPoste,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  bool get estSynchronise => statutSync == 1;

  Map<String, dynamic> toJson() => {
    'id': id,
    'conducteur_nom': conducteurNom,
    'type_engin_id': typeEnginId,
    'type_engin_nom': typeEnginNom,
    'montant': montant,
    'quantite': quantite,
    'date_paiement': datePaiement.toIso8601String(),
    'statut_sync': statutSync,
    'poste_id': posteId,
    'nom_poste': nomPoste,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Paiement.fromJson(Map<String, dynamic> json) => Paiement(
    id: json['id'] as int?,
    conducteurNom: json['conducteur_nom'] as String,
    typeEnginId: json['type_engin_id'] as int,
    typeEnginNom: json['type_engin_nom'] as String,
    montant: (json['montant'] as num).toDouble(),
    quantite: (json['quantite'] as int?) ?? 1,
    datePaiement: DateTime.parse(json['date_paiement'] as String),
    statutSync: json['statut_sync'] as int,
    posteId: json['poste_id'] as int,
    nomPoste: json['nom_poste'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Paiement copyWith({
    int? id,
    String? conducteurNom,
    int? typeEnginId,
    String? typeEnginNom,
    double? montant,
    int? quantite,
    DateTime? datePaiement,
    int? statutSync,
    int? posteId,
    String? nomPoste,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Paiement(
    id: id ?? this.id,
    conducteurNom: conducteurNom ?? this.conducteurNom,
    typeEnginId: typeEnginId ?? this.typeEnginId,
    typeEnginNom: typeEnginNom ?? this.typeEnginNom,
    montant: montant ?? this.montant,
    quantite: quantite ?? this.quantite,
    datePaiement: datePaiement ?? this.datePaiement,
    statutSync: statutSync ?? this.statutSync,
    posteId: posteId ?? this.posteId,
    nomPoste: nomPoste ?? this.nomPoste,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  String toQrString() => 'RoadTax|$conducteurNom|$typeEnginNom|$montant|${datePaiement.toIso8601String()}|$nomPoste|${id ?? 0}|$quantite';
}
