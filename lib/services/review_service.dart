import 'package:cloud_firestore/cloud_firestore.dart';
import '../types.dart';

class ReviewService {
  static Stream<List<Review>> streamReviews(String activityId) {
    return FirebaseFirestore.instance
        .collection('activities')
        .doc(activityId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return Review(
                id: data['userId'] ?? d.id, // Use userId from document, fallback to doc ID
                userName: data['userName'] ?? 'Anonyme',
                rating: (data['rating'] is int) ? data['rating'] as int : (data['rating'] is num ? (data['rating'] as num).toInt() : 0),
                comment: data['comment'] ?? '',
                date: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                avatar: data['avatar'] as String?,
              );
            }).toList());
  }

  static Future<void> addReview(String activityId, Review review) async {
    final colRef = FirebaseFirestore.instance.collection('activities').doc(activityId);
    final reviewsCol = colRef.collection('reviews');

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final activitySnap = await tx.get(colRef);
      final activityData = activitySnap.data() ?? {};
      final currentRating = (activityData['rating'] is num) ? (activityData['rating'] as num).toDouble() : 0.0;
      final currentCount = (activityData['ratingCount'] is int) ? activityData['ratingCount'] as int : (activityData['ratingCount'] is num ? (activityData['ratingCount'] as num).toInt() : 0);

      // Add review doc
      final newDocRef = reviewsCol.doc();
      tx.set(newDocRef, {
        'userName': review.userName,
        'rating': review.rating,
        'comment': review.comment,
        'createdAt': Timestamp.fromDate(review.date),
        'avatar': review.avatar,
        'userId': review.id, // store reviewer id for potential moderation
      });

      // Update aggregate
      final newCount = currentCount + 1;
      final newRating = (currentRating * currentCount + review.rating) / (newCount == 0 ? 1 : newCount);
      tx.update(colRef, {'rating': newRating, 'ratingCount': newCount});
    });
  }
}
