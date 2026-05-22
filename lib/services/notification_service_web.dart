import 'package:meteomada/models/alerte_cyclone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialiser() async {}

  Future<void> creerNotificationAlerte(AlerteCyclone alerte) async {}

  Future<void> creerNotificationMiseAJour(AlerteCyclone alerte) async {}
}
