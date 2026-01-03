import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    try {
      // Request permissions on supported platforms
      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((message) {
        print('FCM onMessage: ${message.notification?.title} - ${message.notification?.body}');
      });

      // Optional: handle background messages via onBackgroundMessage (requires a top-level handler in web/native)
    } catch (e) {
      print('Messaging init failed: $e');
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

  /// Send a reservation notification to the user
  /// In production, this would be called from a backend server using FCM Admin SDK
  /// For now, we store notification data in Firestore
  static Future<void> sendReservationNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': title,
        'body': body,
        'type': 'reservation',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }
}
