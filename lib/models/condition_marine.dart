class ConditionMarine {
  final String id;
  final String villeId;
  final String etatMaree;
  final String ventMarin;
  final double hauteurVagues;
  final double temperatureEau;
  final double houle;
  final bool baignadeDangereuse;
  final bool pechePossible;

  ConditionMarine({
    required this.id,
    required this.villeId,
    required this.etatMaree,
    required this.ventMarin,
    required this.hauteurVagues,
    required this.temperatureEau,
    required this.houle,
    required this.baignadeDangereuse,
    required this.pechePossible,
  });

  ConditionMarine copyWith({
    String? id,
    String? villeId,
    String? etatMaree,
    String? ventMarin,
    double? hauteurVagues,
    double? temperatureEau,
    double? houle,
    bool? baignadeDangereuse,
    bool? pechePossible,
  }) =>
      ConditionMarine(
        id: id ?? this.id,
        villeId: villeId ?? this.villeId,
        etatMaree: etatMaree ?? this.etatMaree,
        ventMarin: ventMarin ?? this.ventMarin,
        hauteurVagues: hauteurVagues ?? this.hauteurVagues,
        temperatureEau: temperatureEau ?? this.temperatureEau,
        houle: houle ?? this.houle,
        baignadeDangereuse: baignadeDangereuse ?? this.baignadeDangereuse,
        pechePossible: pechePossible ?? this.pechePossible,
      );

  factory ConditionMarine.fromMap(Map<String, dynamic> map) =>
      ConditionMarine(
        id: map['id'] as String,
        villeId: map['ville_id'] as String,
        etatMaree: map['etat_maree'] as String,
        ventMarin: map['vent_marin'] as String,
        hauteurVagues: (map['hauteur_vagues'] as num).toDouble(),
        temperatureEau: (map['temperature_eau'] as num).toDouble(),
        houle: (map['houle'] as num).toDouble(),
        baignadeDangereuse: (map['baignade_dangereuse'] as int) == 1,
        pechePossible: (map['peche_possible'] as int) == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'ville_id': villeId,
        'etat_maree': etatMaree,
        'vent_marin': ventMarin,
        'hauteur_vagues': hauteurVagues,
        'temperature_eau': temperatureEau,
        'houle': houle,
        'baignade_dangereuse': baignadeDangereuse ? 1 : 0,
        'peche_possible': pechePossible ? 1 : 0,
      };
}
