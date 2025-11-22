
class Review {
  final String id;
  final String userName;
  final int rating;
  final String comment;
  final DateTime date;
  final String? avatar;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    this.avatar,
  });
}

class Activity {
  final String id;
  final String name;
  final double price;
  final String location;
  final String image;
  final String description;
  final String type;
  final List<String> images;
  final List<String> availableSlots;
  final List<Review> reviews;
  final double rating;
  final Map<String, double> coordinates;
  final bool? hasPromotion;
  final String? promotionText;

  Activity({
    required this.id,
    required this.name,
    required this.price,
    required this.location,
    required this.image,
    required this.description,
    required this.type,
    required this.images,
    required this.availableSlots,
    required this.reviews,
    required this.rating,
    required this.coordinates,
    this.hasPromotion,
    this.promotionText,
  });
}

class Reservation {
  final String id;
  final String activityId;
  final DateTime date;
  final String time;
  final String status; // 'upcoming' | 'past'
  final int participants;
  final double totalPrice;

  Reservation({
    required this.id,
    required this.activityId,
    required this.date,
    required this.time,
    required this.status,
    required this.participants,
    required this.totalPrice,
  });
}

class User {
  final String name;
  final String email;
  final String? avatar;
  final List<String> favoriteIds;
  final List<Reservation> reservations;

  User({
    required this.name,
    required this.email,
    this.avatar,
    required this.favoriteIds,
    required this.reservations,
  });
}
