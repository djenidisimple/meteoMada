class CalendrierCultural {
  final String id;
  final String region;
  final String typeCulture;
  final String conseilsMeteo;
  final int moisSemisDebut;
  final int moisSemisFin;
  final int moisRecolteDebut;
  final int moisRecolteFin;

  CalendrierCultural({
    required this.id,
    required this.region,
    required this.typeCulture,
    required this.conseilsMeteo,
    required this.moisSemisDebut,
    required this.moisSemisFin,
    required this.moisRecolteDebut,
    required this.moisRecolteFin,
  });

  factory CalendrierCultural.fromMap(Map<String, dynamic> map) =>
      CalendrierCultural(
        id: map['id'] as String,
        region: map['region'] as String,
        typeCulture: map['type_culture'] as String,
        conseilsMeteo: map['conseils_meteo'] as String? ?? '',
        moisSemisDebut: map['mois_semis_debut'] as int,
        moisSemisFin: map['mois_semis_fin'] as int,
        moisRecolteDebut: map['mois_recolte_debut'] as int,
        moisRecolteFin: map['mois_recolte_fin'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'region': region,
        'type_culture': typeCulture,
        'conseils_meteo': conseilsMeteo,
        'mois_semis_debut': moisSemisDebut,
        'mois_semis_fin': moisSemisFin,
        'mois_recolte_debut': moisRecolteDebut,
        'mois_recolte_fin': moisRecolteFin,
      };

  String get typeCultureEmoji {
    switch (typeCulture) {
      case 'vary':
        return '🌾';
      case 'katsaka':
        return '🌽';
      case 'mangahazo':
        return '🥔';
      case 'haricot':
        return '🌱';
      case 'pomme_de_terre':
        return '🥔';
      case 'vanille':
        return '🌿';
      case 'cafe':
        return '☕';
      case 'cacao':
        return '🍫';
      case 'arachide':
        return '🥜';
      case 'coton':
        return '🌿';
      default:
        return '🌾';
    }
  }

  String get typeCultureLabel {
    switch (typeCulture) {
      case 'vary':
        return 'Riz';
      case 'katsaka':
        return 'Maïs';
      case 'mangahazo':
        return 'Manioc';
      case 'haricot':
        return 'Haricot';
      case 'pomme_de_terre':
        return 'Pomme de terre';
      case 'vanille':
        return 'Vanille';
      case 'cafe':
        return 'Café';
      case 'cacao':
        return 'Cacao';
      case 'arachide':
        return 'Arachide';
      case 'coton':
        return 'Coton';
      default:
        return typeCulture;
    }
  }
}
