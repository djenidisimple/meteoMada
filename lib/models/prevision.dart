class Prevision {
  final String id;
  final String villeId;
  final String condition;
  final String directionVent;
  final String icone;
  final DateTime dateHeure;
  final DateTime dateCreation;
  final double temperature;
  final double temperatureRessentie;
  final double humidite;
  final double vitesseVent;
  final double probabilitePluie;
  final double indiceUV;

  Prevision({
    required this.id,
    required this.villeId,
    required this.condition,
    required this.directionVent,
    required this.icone,
    required this.dateHeure,
    required this.dateCreation,
    required this.temperature,
    required this.temperatureRessentie,
    required this.humidite,
    required this.vitesseVent,
    required this.probabilitePluie,
    required this.indiceUV,
  });

  bool estExpiree() =>
      DateTime.now().difference(dateCreation).inMinutes > 30;

  factory Prevision.fromMap(Map<String, dynamic> map) => Prevision(
        id: map['id'] as String,
        villeId: map['ville_id'] as String,
        condition: map['condition'] as String,
        directionVent: map['direction_vent'] as String,
        icone: map['icone'] as String,
        dateHeure: DateTime.parse(map['date_heure'] as String),
        dateCreation: DateTime.parse(map['date_creation'] as String),
        temperature: (map['temperature'] as num).toDouble(),
        temperatureRessentie: (map['temperature_ressentie'] as num).toDouble(),
        humidite: (map['humidite'] as num).toDouble(),
        vitesseVent: (map['vitesse_vent'] as num).toDouble(),
        probabilitePluie: (map['probabilite_pluie'] as num).toDouble(),
        indiceUV: (map['indice_uv'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'ville_id': villeId,
        'condition': condition,
        'direction_vent': directionVent,
        'icone': icone,
        'date_heure': dateHeure.toIso8601String(),
        'date_creation': dateCreation.toIso8601String(),
        'temperature': temperature,
        'temperature_ressentie': temperatureRessentie,
        'humidite': humidite,
        'vitesse_vent': vitesseVent,
        'probabilite_pluie': probabilitePluie,
        'indice_uv': indiceUV,
      };
}
