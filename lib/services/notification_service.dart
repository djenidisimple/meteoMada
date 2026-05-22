import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:meteomada/models/alerte_cyclone.dart';
import 'package:meteomada/models/calendrier_cultural.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialiser() async {
    if (kIsWeb) return;
  }

  void creerNotificationAlerte(AlerteCyclone alerte) {
    if (kIsWeb) return;
  }

  void creerNotificationMiseAJour(AlerteCyclone alerte) {
    if (kIsWeb) return;
  }

  void creerConseilCultural(CalendrierCultural calendrier) {
    if (kIsWeb) return;
  }
}
