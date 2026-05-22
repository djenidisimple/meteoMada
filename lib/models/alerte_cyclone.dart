import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class AlerteCyclone {
  final String id;
  final String nomCyclone;
  final String consignes;
  final String niveau;
  final DateTime dateEmission;
  final DateTime? dateFinPrevue;
  final bool estActive;
  final List<String> regions;

  AlerteCyclone({
    required this.id,
    required this.nomCyclone,
    this.consignes = '',
    required this.niveau,
    required this.dateEmission,
    this.dateFinPrevue,
    this.estActive = true,
    this.regions = const [],
  });

  Color get niveauColor => AppTheme.colorForNiveau(niveau);
  String get niveauLabel => AppTheme.labelForNiveau(niveau);

  factory AlerteCyclone.fromMap(Map<String, dynamic> map) => AlerteCyclone(
        id: map['id'] as String,
        nomCyclone: map['nom_cyclone'] as String,
        consignes: map['consignes'] as String? ?? '',
        niveau: map['niveau'] as String,
        dateEmission: DateTime.parse(map['date_emission'] as String),
        dateFinPrevue: map['date_fin_prevue'] != null
            ? DateTime.parse(map['date_fin_prevue'] as String)
            : null,
        estActive: (map['est_active'] as int? ?? 1) == 1,
        regions: map['regions'] != null
            ? (map['regions'] as List<dynamic>).cast<String>()
            : [],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nom_cyclone': nomCyclone,
        'consignes': consignes,
        'niveau': niveau,
        'date_emission': dateEmission.toIso8601String(),
        'date_fin_prevue': dateFinPrevue?.toIso8601String(),
        'est_active': estActive ? 1 : 0,
        'regions': regions,
      };
}
