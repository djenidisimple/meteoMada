class AlerteRegion {
  final String alerteId;
  final String region;

  AlerteRegion({required this.alerteId, required this.region});

  factory AlerteRegion.fromMap(Map<String, dynamic> map) => AlerteRegion(
        alerteId: map['alerte_id'] as String,
        region: map['region'] as String,
      );

  Map<String, dynamic> toMap() => {
        'alerte_id': alerteId,
        'region': region,
      };
}
