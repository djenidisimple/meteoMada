class Utilisateur {
  final String id;
  final String pseudo;
  final String typeUtilisateur;
  final bool alertesCycloneActivees;
  final bool alertesPluieActivees;

  Utilisateur({
    required this.id,
    required this.pseudo,
    this.typeUtilisateur = 'citoyen',
    this.alertesCycloneActivees = true,
    this.alertesPluieActivees = false,
  });

  factory Utilisateur.fromMap(Map<String, dynamic> map) => Utilisateur(
        id: map['id'] as String,
        pseudo: map['pseudo'] as String,
        typeUtilisateur: map['type_utilisateur'] as String? ?? 'citoyen',
        alertesCycloneActivees:
            (map['alertes_cyclone_activees'] as int? ?? 1) == 1,
        alertesPluieActivees:
            (map['alertes_pluie_activees'] as int? ?? 0) == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'pseudo': pseudo,
        'type_utilisateur': typeUtilisateur,
        'alertes_cyclone_activees': alertesCycloneActivees ? 1 : 0,
        'alertes_pluie_activees': alertesPluieActivees ? 1 : 0,
      };

  Utilisateur copyWith({
    String? id,
    String? pseudo,
    String? typeUtilisateur,
    bool? alertesCycloneActivees,
    bool? alertesPluieActivees,
  }) =>
      Utilisateur(
        id: id ?? this.id,
        pseudo: pseudo ?? this.pseudo,
        typeUtilisateur: typeUtilisateur ?? this.typeUtilisateur,
        alertesCycloneActivees:
            alertesCycloneActivees ?? this.alertesCycloneActivees,
        alertesPluieActivees:
            alertesPluieActivees ?? this.alertesPluieActivees,
      );
}
