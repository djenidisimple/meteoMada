class Ville {
  final String id;
  final String nom;
  final String region;
  final double latitude;
  final double longitude;
  final int altitude;
  final String fuseauHoraire;
  final bool estCotiere;

  Ville({
    required this.id,
    required this.nom,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.fuseauHoraire,
    required this.estCotiere,
  });

  factory Ville.fromMap(Map<String, dynamic> map) => Ville(
        id: map['id'] as String,
        nom: map['nom'] as String,
        region: map['region'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        altitude: map['altitude'] as int,
        fuseauHoraire: map['fuseau_horaire'] as String,
        estCotiere: (map['est_cotiere'] as int) == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nom': nom,
        'region': region,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'fuseau_horaire': fuseauHoraire,
        'est_cotiere': estCotiere ? 1 : 0,
      };

  Ville copyWith({
    String? id,
    String? nom,
    String? region,
    double? latitude,
    double? longitude,
    int? altitude,
    String? fuseauHoraire,
    bool? estCotiere,
  }) =>
      Ville(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        region: region ?? this.region,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        altitude: altitude ?? this.altitude,
        fuseauHoraire: fuseauHoraire ?? this.fuseauHoraire,
        estCotiere: estCotiere ?? this.estCotiere,
      );
}
