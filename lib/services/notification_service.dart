import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meteomada/models/alerte_cyclone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialiser() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  Future<void> creerNotificationAlerte(AlerteCyclone alerte) async {
    final couleur = _couleurPourNiveau(alerte.niveau);
    final androidDetails = AndroidNotificationDetails(
      'alertes_cyclone',
      'Alertes Cyclone',
      channelDescription: "Notifications d'alertes cyclone",
      importance: _importancePourNiveau(alerte.niveau),
      priority: _priorityPourNiveau(alerte.niveau),
      color: Color(couleur),
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      alerte.id.hashCode,
      'Alerte Cyclone : ${alerte.nomCyclone}',
      'Niveau ${alerte.niveau} - ${alerte.consignes}',
      details,
    );
  }

  Future<void> creerNotificationMiseAJour(AlerteCyclone alerte) async {
    final androidDetails = AndroidNotificationDetails(
      'maj_alertes',
      'Mise à jour alertes',
      channelDescription: 'Mises à jour des alertes cyclones',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      alerte.id.hashCode * 2,
      'Mise à jour : ${alerte.nomCyclone}',
      'Nouveau niveau : ${alerte.niveau}',
      details,
    );
  }

  Importance _importancePourNiveau(String niveau) {
    switch (niveau) {
      case 'AlerteRouge':
      case 'CycloneIntense':
        return Importance.max;
      case 'AlerteOrange':
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _priorityPourNiveau(String niveau) {
    switch (niveau) {
      case 'AlerteRouge':
      case 'CycloneIntense':
        return Priority.max;
      case 'AlerteOrange':
        return Priority.high;
      default:
        return Priority.defaultPriority;
    }
  }

  int _couleurPourNiveau(String niveau) {
    switch (niveau) {
      case 'AlerteJaune':
        return 0xFFFFFF00;
      case 'AlerteOrange':
        return 0xFFFFA500;
      case 'AlerteRouge':
      case 'CycloneIntense':
        return 0xFFFF0000;
      default:
        return 0xFF0000FF;
    }
  }
}
