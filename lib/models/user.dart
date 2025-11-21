class User {
  final int? id;
  final String nomPoste;
  final String agentNom;
  final String motDePasse;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.nomPoste,
    required this.agentNom,
    required this.motDePasse,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom_poste': nomPoste,
    'agent_nom': agentNom,
    'mot_de_passe': motDePasse,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int?,
    nomPoste: json['nom_poste'] as String,
    agentNom: json['agent_nom'] as String,
    motDePasse: json['mot_de_passe'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  User copyWith({
    int? id,
    String? nomPoste,
    String? agentNom,
    String? motDePasse,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    nomPoste: nomPoste ?? this.nomPoste,
    agentNom: agentNom ?? this.agentNom,
    motDePasse: motDePasse ?? this.motDePasse,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
