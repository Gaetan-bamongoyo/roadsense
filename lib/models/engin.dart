class Taxe {
  final int? id;
  final String nom;
  final double tarif;
  final String iconName;
  final int categorieId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Taxe({
    this.id,
    required this.nom,
    required this.tarif,
    required this.iconName,
    required this.categorieId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'tarif': tarif,
    'icon_name': iconName,
    'categorie_id': categorieId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Taxe.fromJson(Map<String, dynamic> json) => Taxe(
    id: json['id'] as int?,
    nom: (json['nom'] ?? '') as String,
    tarif: (json['tarif'] as num).toDouble(),
    categorieId: json['categorie_id'] as int,
    iconName: (json['icon_name'] ?? '') as String,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  Taxe copyWith({
    int? id,
    String? nom,
    double? tarif,
    String? iconName,
    int? categorieId,
    DateTime? createdAt,
    DateTime? updatedAt, 
  }) => Taxe(
    id: id ?? this.id,
    nom: nom ?? this.nom,
    tarif: tarif ?? this.tarif,
    iconName: iconName ?? this.iconName,
    categorieId: categorieId ?? this.categorieId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
