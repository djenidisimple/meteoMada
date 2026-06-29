class Prevision {
  final String id;
  final String villeId;
  final String condition;
  final String directionVent;
  final String icone;
  final String leverSoleil;
  final String coucherSoleil;
  final DateTime dateHeure;
  final DateTime dateCreation;
  final double temperature;
  final double temperatureRessentie;
  final double temperatureMin;
  final double temperatureMax;
  final double humidite;
  final double vitesseVent;
  final double probabilitePluie;
  final double indiceUV;

  Prevision({
    required this.id,
    required this.villeId,
    required this.condition,
    this.directionVent = '',
    this.icone = '',
    this.leverSoleil = '',
    this.coucherSoleil = '',
    required this.dateHeure,
    required this.dateCreation,
    this.temperature = 0,
    this.temperatureRessentie = 0,
    this.temperatureMin = 0,
    this.temperatureMax = 0,
    this.humidite = 0,
    this.vitesseVent = 0,
    this.probabilitePluie = 0,
    this.indiceUV = 0,
  });

  bool estExpiree() =>
      DateTime.now().difference(dateCreation).inMinutes > 30;

  Prevision copyWith({
    String? id,
    String? villeId,
    String? condition,
    String? directionVent,
    String? icone,
    String? leverSoleil,
    String? coucherSoleil,
    DateTime? dateHeure,
    DateTime? dateCreation,
    double? temperature,
    double? temperatureRessentie,
    double? temperatureMin,
    double? temperatureMax,
    double? humidite,
    double? vitesseVent,
    double? probabilitePluie,
    double? indiceUV,
  }) =>
      Prevision(
        id: id ?? this.id,
        villeId: villeId ?? this.villeId,
        condition: condition ?? this.condition,
        directionVent: directionVent ?? this.directionVent,
        icone: icone ?? this.icone,
        leverSoleil: leverSoleil ?? this.leverSoleil,
        coucherSoleil: coucherSoleil ?? this.coucherSoleil,
        dateHeure: dateHeure ?? this.dateHeure,
        dateCreation: dateCreation ?? this.dateCreation,
        temperature: temperature ?? this.temperature,
        temperatureRessentie: temperatureRessentie ?? this.temperatureRessentie,
        temperatureMin: temperatureMin ?? this.temperatureMin,
        temperatureMax: temperatureMax ?? this.temperatureMax,
        humidite: humidite ?? this.humidite,
        vitesseVent: vitesseVent ?? this.vitesseVent,
        probabilitePluie: probabilitePluie ?? this.probabilitePluie,
        indiceUV: indiceUV ?? this.indiceUV,
      );

  factory Prevision.fromMap(Map<String, dynamic> map) => Prevision(
        id: map['id'] as String,
        villeId: map['ville_id'] as String,
        condition: map['condition'] as String,
        directionVent: map['direction_vent'] as String? ?? '',
        icone: map['icone'] as String? ?? '',
        leverSoleil: map['lever_soleil'] as String? ?? '',
        coucherSoleil: map['coucher_soleil'] as String? ?? '',
        dateHeure: DateTime.parse(map['date_heure'] as String),
        dateCreation: DateTime.parse(map['date_creation'] as String),
        temperature: (map['temperature'] as num?)?.toDouble() ?? 0,
        temperatureRessentie: (map['temperature_ressentie'] as num?)?.toDouble() ?? 0,
        temperatureMin: (map['temperature_min'] as num?)?.toDouble() ?? 0,
        temperatureMax: (map['temperature_max'] as num?)?.toDouble() ?? 0,
        humidite: (map['humidite'] as num?)?.toDouble() ?? 0,
        vitesseVent: (map['vitesse_vent'] as num?)?.toDouble() ?? 0,
        probabilitePluie: (map['probabilite_pluie'] as num?)?.toDouble() ?? 0,
        indiceUV: (map['indice_uv'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'ville_id': villeId,
        'condition': condition,
        'direction_vent': directionVent,
        'icone': icone,
        'lever_soleil': leverSoleil,
        'coucher_soleil': coucherSoleil,
        'date_heure': dateHeure.toIso8601String(),
        'date_creation': dateCreation.toIso8601String(),
        'temperature': temperature,
        'temperature_ressentie': temperatureRessentie,
        'temperature_min': temperatureMin,
        'temperature_max': temperatureMax,
        'humidite': humidite,
        'vitesse_vent': vitesseVent,
        'probabilite_pluie': probabilitePluie,
        'indice_uv': indiceUV,
      };
}
