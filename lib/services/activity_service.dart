import 'package:cloud_firestore/cloud_firestore.dart';
import '../types.dart';
import '../data/mock_data.dart';

class ActivityService {
  static Map<String, dynamic> _activityToMap(Activity a) {
    return {
      'name': a.name,
      'price': a.price,
      'location': a.location,
      'image': a.image,
      'description': a.description,
      'type': a.type,
      'images': a.images,
      'availableSlots': a.availableSlots,
      'rating': a.rating,
      'coordinates': a.coordinates,
      'hasPromotion': a.hasPromotion,
      'promotionText': a.promotionText,
    };
  }

  static Stream<List<Activity>> activitiesStream() {
    return FirebaseFirestore.instance.collection('activities').snapshots().map((snap) {
      return snap.docs.map((doc) {
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
    });
  }

  // Seed Firestore with mock activities if collection is empty.
  static Future<void> seedActivitiesIfEmpty() async {
    final col = FirebaseFirestore.instance.collection('activities');
    final snapshot = await col.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final a in mockActivities) {
      final docRef = col.doc(a.id);
      batch.set(docRef, _activityToMap(a));
    }
    await batch.commit();
  }

  // Add any mock activities that are missing, without touching existing docs.
  static Future<void> syncMissingMockActivities() async {
    final col = FirebaseFirestore.instance.collection('activities');
    try {
      print('syncMissingMockActivities: fetching existing activities');
      final snapshot = await col.get();
      final existingIds = snapshot.docs.map((d) => d.id).toSet();

      final missing = mockActivities.where((a) => !existingIds.contains(a.id)).toList();
      if (missing.isEmpty) {
        print('syncMissingMockActivities: no missing activities to add');
        return;
      }

      print('syncMissingMockActivities: adding ${missing.length} activities');
      final batch = FirebaseFirestore.instance.batch();
      for (final a in missing) {
        batch.set(col.doc(a.id), _activityToMap(a));
      }

      await batch.commit();
      print('syncMissingMockActivities: added ${missing.length} activities');
    } catch (e) {
      print('syncMissingMockActivities error: $e');
    }
  }
}
