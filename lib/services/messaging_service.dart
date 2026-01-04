import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
// Platform checks not required here; remove unused imports to silence analyzer

// Top-level background message handler. Must be a top-level function.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    final notification = message.notification;
    final title = notification?.title ?? 'Reservi';
    final body = notification?.body ?? '';

    // Try to show a local notification in the background. This may fail on
    // some platforms/isolate setups, so guard with try/catch.
    try {
      final local = FlutterLocalNotificationsPlugin();
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      final iosInit = DarwinInitializationSettings();
      await local.initialize(InitializationSettings(android: androidInit, iOS: iosInit));
      const androidDetails = AndroidNotificationDetails('reservi_channel', 'Reservi', channelDescription: 'Notifications de Reservi', importance: Importance.max, priority: Priority.high);
      const iosDetails = DarwinNotificationDetails();
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
      await local.show(message.hashCode, title, body, details);
    } catch (e) {
      print('Background local notification failed: $e');
    }

    // Optionally persist the notification in Firestore for later inspection
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'body': body,
        'data': message.data,
        'receivedAt': FieldValue.serverTimestamp(),
        'background': true,
      });
    } catch (e) {
      print('Failed to persist background notification: $e');
    }
  } catch (e) {
    print('Unhandled background message error: $e');
  }
}

class MessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      // Request permissions on supported platforms
      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      // Initialize local notifications
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      final iosInit = DarwinInitializationSettings();
      await _localNotif.initialize(
        InitializationSettings(android: androidInit, iOS: iosInit),
      );
      tzdata.initializeTimeZones();

      // Register background handler
      try {
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      } catch (e) {
        print('Failed to register background handler: $e');
      }

      // Handle foreground messages and show a local notification
      FirebaseMessaging.onMessage.listen((message) {
        final title = message.notification?.title ?? 'Nouvelle notification';
        final body = message.notification?.body ?? '';
        _showLocalNotification(title, body);
        print('FCM onMessage: $title - $body');
      });

      // Optional: handle background messages via onBackgroundMessage (requires a top-level handler in web/native)
    } catch (e) {
      print('Messaging init failed: $e');
    }
  }

  static Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails('reservi_channel', 'Reservi', channelDescription: 'Notifications de Reservi', importance: Importance.max, priority: Priority.high);
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotif.show(0, title, body, details);
  }

  // Schedule a reservation reminder at the specified DateTime (in local timezone).
  static Future<void> scheduleReservationReminder(DateTime scheduledDate, String title, String body) async {
    try {
      final now = DateTime.now();
      final diff = scheduledDate.difference(now);
      // If the scheduled time is very near (<=10s) use an immediate local show
      if (diff.inSeconds <= 10) {
        await _showLocalNotification(title, body);
        return;
      }

      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
      const androidDetails = AndroidNotificationDetails('reservi_channel', 'Reservi', channelDescription: 'Notifications de Reservi', importance: Importance.max, priority: Priority.high);
      const iosDetails = DarwinNotificationDetails();
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
      await _localNotif.zonedSchedule(
        scheduledDate.millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        tzDate,
        details,
        // Newer versions of `flutter_local_notifications` (>=19) require
        // an explicit `androidScheduleMode` and removed the iOS
        // `UILocalNotificationDateInterpretation` and
        // `androidAllowWhileIdle` parameters.
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print('Failed to schedule reservation reminder: $e');
    }
  }

  // Quick helper to send an immediate test notification (useful for a debug button)
  static Future<void> sendTestNotification({String title = 'Test notification', String body = 'Ceci est un test'}) async {
    try {
      await _showLocalNotification(title, body);
    } catch (e) {
      print('Failed to send test notification: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Failed to get FCM token: $e');
      return null;
    }
  }

  static Future<void> registerTokenForUser(String uid) async {
    final token = await getToken();
    if (token == null) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    try {
      await docRef.update({'fcmTokens': FieldValue.arrayUnion([token])});
    } catch (e) {
      await docRef.set({'fcmTokens': [token]}, SetOptions(merge: true));
    }
  }
}
