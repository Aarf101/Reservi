import 'package:cloud_firestore/cloud_firestore.dart';
import '../types.dart';

class RecommendationService {
  // Very simple recommendation: prefer activities that match user's favorite activity types
  // or high-rated activities when no preferences are available.
  static Future<List<Activity>> recommendForUser(String? uid) async {
    try {
      final activitiesSnap = await FirebaseFirestore.instance.collection('activities').get();
      final activities = activitiesSnap.docs.map((doc) {
        final data = doc.data();
        return Activity(
          id: doc.id,
          name: (data['name'] ?? '') as String,
          price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
          location: (data['location'] ?? '') as String,
          image: (data['image'] ?? '') as String,
          description: (data['description'] ?? '') as String,
          type: (data['type'] ?? 'Loisir') as String,
          images: List<String>.from(data['images'] ?? []),
          availableSlots: List<String>.from(data['availableSlots'] ?? []),
          reviews: [],
          rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0,
          coordinates: Map<String, double>.from((data['coordinates'] ?? {}).map((k, v) => MapEntry(k as String, (v as num).toDouble()))),
          hasPromotion: data['hasPromotion'] as bool?,
          promotionText: data['promotionText'] as String?,
        );
      }).toList();

      List<String> preferredTypes = [];
      if (uid != null) {
        try {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
          final udata = userDoc.data();
          if (udata != null && udata['favoriteIds'] is List) {
            final favIds = List<String>.from(udata['favoriteIds']);
            // collect types of favorited activities
            for (final f in activities) {
              if (favIds.contains(f.id) && !preferredTypes.contains(f.type)) preferredTypes.add(f.type);
            }
          }
          // custom preferences field optional
          if (udata != null && udata['preferredTypes'] is List) {
            for (final t in (udata['preferredTypes'] as List)) {
              if (t is String && !preferredTypes.contains(t)) preferredTypes.add(t);
            }
          }
        } catch (e) {
          // ignore
        }
      }

      // Score activities
      final scored = activities.map((a) {
        int score = 0;
        if (preferredTypes.contains(a.type)) score += 10;
        score += (a.rating * 2).toInt();
        if (a.hasPromotion ?? false) score += 3;
        return {'activity': a, 'score': score};
      }).toList();

      scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
      return scored.take(6).map((s) => s['activity'] as Activity).toList();
    } catch (e) {
      print('RecommendationService failed: $e');
      return [];
    }
  }
}
