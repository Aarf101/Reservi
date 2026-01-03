import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../types.dart';
import 'messaging_service.dart';

class ReservationService {
  /// Validate and create a reservation (before payment)
  static Future<String> validateReservation({
    required String activityId,
    required DateTime date,
    required String time,
    required int participants,
    required double totalPrice,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be signed in to create a reservation');
    }

    try {
      final reservationsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reservations');
      
      final docRef = await reservationsRef.add({
        'activityId': activityId,
        'date': Timestamp.fromDate(date),
        'time': time,
        'status': 'validated',
        'participants': participants,
        'totalPrice': totalPrice,
        'isPaid': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send notification
      await MessagingService.sendReservationNotification(
        userId: user.uid,
        title: 'Réservation validée',
        body: 'Votre réservation a été validée avec succès !',
      );

      return docRef.id;
    } catch (e) {
      print('Failed to validate reservation: $e');
      rethrow;
    }
  }

  /// Mark a reservation as paid
  static Future<void> markReservationAsPaid(String reservationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be signed in');
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reservations')
          .doc(reservationId)
          .update({
        'isPaid': true,
        'status': 'paid',
        'paidAt': FieldValue.serverTimestamp(),
      });

      // Send notification
      await MessagingService.sendReservationNotification(
        userId: user.uid,
        title: 'Paiement confirmé',
        body: 'Votre paiement a été confirmé avec succès !',
      );
    } catch (e) {
      print('Failed to mark reservation as paid: $e');
      rethrow;
    }
  }

  /// Get available time slots for an activity on a specific date
  static Future<List<String>> getAvailableSlots({
    required String activityId,
    required DateTime date,
  }) async {
    try {
      // Get activity to know all possible slots
      final activityDoc = await FirebaseFirestore.instance
          .collection('activities')
          .doc(activityId)
          .get();
      
      if (!activityDoc.exists) {
        return [];
      }
      
      final activityData = activityDoc.data()!;
      final allSlots = List<String>.from(activityData['availableSlots'] ?? []);
      
      // Calculate start and end of the selected date
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      final startTimestamp = Timestamp.fromDate(startOfDay);
      final endTimestamp = Timestamp.fromDate(endOfDay);
      
      // Get all reservations for this activity on this date
      // Note: This is simplified - in production, you'd use a backend service or collection group query
      final reservedSlots = <String>{};
      
      try {
        // Query reservations collection group (requires proper Firestore rules)
        // For now, we'll check current user's reservations and return all slots
        // In production, use a backend service to check all reservations
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final reservationsSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('reservations')
              .where('activityId', isEqualTo: activityId)
              .where('date', isGreaterThanOrEqualTo: startTimestamp)
              .where('date', isLessThanOrEqualTo: endTimestamp)
              .get();
          
          for (final resDoc in reservationsSnapshot.docs) {
            final data = resDoc.data();
            final resDate = (data['date'] as Timestamp?)?.toDate();
            if (resDate != null && 
                resDate.year == date.year &&
                resDate.month == date.month &&
                resDate.day == date.day) {
              final time = data['time'] as String?;
              if (time != null) {
                reservedSlots.add(time);
              }
            }
          }
        }
      } catch (e) {
        print('Error querying reservations: $e');
        // Continue with all slots if query fails
      }
      
      // Return only available (not reserved) slots
      return allSlots.where((slot) => !reservedSlots.contains(slot)).toList();
    } catch (e) {
      print('Error getting available slots: $e');
      // Fallback: return all slots from activity
      try {
        final activityDoc = await FirebaseFirestore.instance
            .collection('activities')
            .doc(activityId)
            .get();
        if (activityDoc.exists) {
          final activityData = activityDoc.data()!;
          return List<String>.from(activityData['availableSlots'] ?? []);
        }
      } catch (_) {}
      return [];
    }
  }
}
