class NotificationLocale {
  final String id;
  final String titre;
  final String message;
  final String type;
  final DateTime dateEnvoi;
  final bool estLue;
  final String? villeConcernee;

  NotificationLocale({
    required this.id,
    required this.titre,
    required this.message,
    required this.type,
    required this.dateEnvoi,
    this.estLue = false,
    this.villeConcernee,
  });

  NotificationLocale copyWith({
    String? id,
    String? titre,
    String? message,
    String? type,
    DateTime? dateEnvoi,
    bool? estLue,
    String? villeConcernee,
  }) =>
      NotificationLocale(
        id: id ?? this.id,
        titre: titre ?? this.titre,
        message: message ?? this.message,
        type: type ?? this.type,
        dateEnvoi: dateEnvoi ?? this.dateEnvoi,
        estLue: estLue ?? this.estLue,
        villeConcernee: villeConcernee ?? this.villeConcernee,
      );

  factory NotificationLocale.fromMap(Map<String, dynamic> map) =>
      NotificationLocale(
        id: map['id'] as String,
        titre: map['titre'] as String,
        message: map['message'] as String,
        type: map['type'] as String,
        dateEnvoi: DateTime.parse(map['date_envoi'] as String),
        estLue: (map['est_lue'] as int? ?? 0) == 1,
        villeConcernee: map['ville_concernee'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'titre': titre,
        'message': message,
        'type': type,
        'date_envoi': dateEnvoi.toIso8601String(),
        'est_lue': estLue ? 1 : 0,
        'ville_concernee': villeConcernee,
      };
}
