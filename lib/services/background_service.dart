import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'notification_service.dart';
import 'prayer_times_service.dart';
import 'location_service.dart';

class BackgroundService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'namaz_foreground',
        initialNotificationTitle: 'İslam Dünyam',
        initialNotificationContent: 'Namaz takibi aktif',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    await service.startService();
    _scheduleDailyPrayers();
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
      service.setForegroundNotificationInfo(
        title: 'İslam Dünyam',
        content: 'Namaz takibi aktif',
      );
    }

    Timer.periodic(const Duration(minutes: 30), (timer) async {
      await _scheduleDailyPrayers();
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    await _scheduleDailyPrayers();
    return true;
  }

  static Future<void> _scheduleDailyPrayers() async {
    await NotificationService.initialize();

    final position = await LocationService.getCurrentPosition();
    if (position == null) return;

    final now = DateTime.now();
    final prayers = PrayerTimesService.calculatePrayerTimes(
      position.latitude,
      position.longitude,
      now,
    );

    for (final entry in prayers.entries) {
      await NotificationService.schedulePrayerNotification(
        entry.key,
        entry.value,
      );
    }
  }
}
