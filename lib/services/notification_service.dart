import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'storage_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android 13+ bildirim izni
    await _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await StorageService.initialize();
  }

  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final parts = payload.split('|');
    if (parts.isEmpty) return;

    final prayerName = parts[0];

    if (response.actionId == 'yes') {
      _addScore(prayerName);
    } else if (response.actionId == 'no' || response.actionId == null) {
      _addDebt(prayerName);
    }
  }

  static void _addScore(String prayerName) async {
    final currentScore = StorageService.getInt('total_score', defaultValue: 0);
    await StorageService.setInt('total_score', currentScore + 10);

    // Namaza göre skor ekle
    final key = '${_normalizePrayerName(prayerName)}_score';
    final prayerScore = StorageService.getInt(key, defaultValue: 0);
    await StorageService.setInt(key, prayerScore + 10);
  }

  static void _addDebt(String prayerName) async {
    final key = '${_normalizePrayerName(prayerName)}_debt';
    final currentDebt = StorageService.getInt(key, defaultValue: 0);
    await StorageService.setInt(key, currentDebt + 1);
  }

  static String _normalizePrayerName(String name) {
    return name.toLowerCase()
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ı', 'i')
        .replaceAll('ç', 'c');
  }

  static Future<void> schedulePrayerNotification(
    String prayerName,
    DateTime prayerTime,
  ) async {
    final notifyTime = prayerTime.add(const Duration(minutes: 15));
    if (notifyTime.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'namaz_bildirimleri',
      'Namaz Bildirimleri',
      channelDescription: 'Namaz vakti bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Namaz Bildirimi',
      actions: [
        AndroidNotificationAction(
          'yes',
          'Evet (+10 Puan)',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'no',
          'Hayır (Borç)',
          showsUserInterface: true,
        ),
      ],
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'namaz_category',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzTime = tz.TZDateTime.from(notifyTime, tz.local);

    await _notifications.zonedSchedule(
      prayerName.hashCode,
      'Namazınızı Kıldınız mı?',
      '$prayerName namazınızı kıldınız mı?',
      tzTime,
      details,
      payload: prayerName,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
