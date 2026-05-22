class Favori {
  final String id;
  final String utilisateurId;
  final String villeId;
  final String? surnom;
  final bool notificationsActives;
  final int ordreAffichage;
  final DateTime dateAjout;

  Favori({
    required this.id,
    required this.utilisateurId,
    required this.villeId,
    this.surnom,
    this.notificationsActives = true,
    this.ordreAffichage = 0,
    required this.dateAjout,
  });

  factory Favori.fromMap(Map<String, dynamic> map) => Favori(
        id: map['id'] as String,
        utilisateurId: map['utilisateur_id'] as String,
        villeId: map['ville_id'] as String,
        surnom: map['surnom'] as String?,
        notificationsActives: (map['notifications_actives'] as int? ?? 1) == 1,
        ordreAffichage: map['ordre_affichage'] as int? ?? 0,
        dateAjout: DateTime.parse(map['date_ajout'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'utilisateur_id': utilisateurId,
        'ville_id': villeId,
        'surnom': surnom,
        'notifications_actives': notificationsActives ? 1 : 0,
        'ordre_affichage': ordreAffichage,
        'date_ajout': dateAjout.toIso8601String(),
      };

  Favori copyWith({
    String? id,
    String? utilisateurId,
    String? villeId,
    String? surnom,
    bool? notificationsActives,
    int? ordreAffichage,
    DateTime? dateAjout,
  }) =>
      Favori(
        id: id ?? this.id,
        utilisateurId: utilisateurId ?? this.utilisateurId,
        villeId: villeId ?? this.villeId,
        surnom: surnom ?? this.surnom,
        notificationsActives: notificationsActives ?? this.notificationsActives,
        ordreAffichage: ordreAffichage ?? this.ordreAffichage,
        dateAjout: dateAjout ?? this.dateAjout,
      );
}
