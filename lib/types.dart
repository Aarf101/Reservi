
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
  final String center;

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
    required this.center,
  });
}

class Reservation {
  final String id;
  final String activityId;
  final DateTime date;
  final String time;
  final String status; // 'pending' | 'validated' | 'paid' | 'upcoming' | 'past'
  final int participants;
  final double totalPrice;
  final bool isPaid;

  Reservation({
    required this.id,
    required this.activityId,
    required this.date,
    required this.time,
    required this.status,
    required this.participants,
    required this.totalPrice,
    this.isPaid = false,
  });
}

class User {
  String name;
  String email;
  String? avatar;
  String? phone;
  String? address;
  final List<String> favoriteIds;
  final List<Reservation> reservations;

  User({
    required this.name,
    required this.email,
    this.avatar,
    this.phone,
    this.address,
    required this.favoriteIds,
    required this.reservations,
  });
}
