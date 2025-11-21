class Categorie {
  final int? id;
  final String designation;
  final String iconName;
  final String description;

  Categorie({
    this.id,
    required this.designation,
    required this.iconName,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'designation': designation,
        'icon_name': iconName,
        'description': description,
      };

  factory Categorie.fromJson(Map<String, dynamic> json) => Categorie(
        id: json['id'] as int?,
        designation: (json['designation'] ?? json['nom']) as String,
        iconName: (json['icon_name'] ?? '') as String,
        description: (json['description'] ?? '') as String,
      );

  Categorie copyWith({
    int? id,
    String? designation,
    String? iconName,
    String? description,
  }) => Categorie(
        id: id ?? this.id,
        designation: designation ?? this.designation,
        iconName: iconName ?? this.iconName,
        description: description ?? this.description,
      );
}
