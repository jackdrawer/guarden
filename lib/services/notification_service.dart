import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bank_account.dart';
import '../models/web_password.dart';

final notificationProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
            requestAlertPermission: false, // We request manually
            requestBadgePermission: false,
            requestSoundPermission: false,
          );

      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
              // Handle notification tap here
            },
      );

      _initialized = true;
    } on PlatformException catch (e) {
      debugPrint('Notification init failed: $e');
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  Future<void> requestPermissions() async {
    try {
      await init();
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImplementation?.requestNotificationsPermission();

      final iosImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } on PlatformException catch (e) {
      debugPrint('Notification permissions failed: $e');
    } catch (e) {
      debugPrint('Notification permissions error: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await init();
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'guarden_expiration_channel',
            'Password Rotation Notifications',
            channelDescription: 'Reminds you of expiring passwords.',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
        payload: 'item_id',
      );
    } on PlatformException catch (e) {
      debugPrint('Notification display failed: $e');
    } catch (e) {
      debugPrint('Notification display error: $e');
    }
  }

  /// Check all bank accounts for expired or soon-to-expire rotation periods.
  /// Dispatches local notifications: expired, 1-day warning, 7-day warning.
  Future<void> checkPasswordExpirations(
    List<BankAccount> banks,
    List<WebPassword> passes,
  ) async {
    int expiredCount = 0;
    int soonCount = 0;
    final now = DateTime.now();

    for (var bank in banks) {
      if (bank.periodMonths <= 0) continue;

      final expireDate = bank.lastChangedAt.add(
        Duration(days: bank.periodMonths * 30),
      );
      final daysLeft = expireDate.difference(now).inDays;

      if (daysLeft < 0) {
        expiredCount++;
      } else if (daysLeft <= 1) {
        soonCount++;
      } else if (daysLeft <= 7) {
        soonCount++;
      }
    }

    if (expiredCount > 0) {
      await showNotification(
        id: 100,
        title: 'Password Rotation Alert!',
        body:
            '$expiredCount bank passwords are due for rotation. Please update them for security.',
      );
    }

    if (soonCount > 0) {
      await showNotification(
        id: 101,
        title: 'Password Rotation Coming Soon',
        body: '$soonCount bank passwords will expire within 7 days.',
      );
    }
  }
}
