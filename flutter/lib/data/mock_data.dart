
import '../types.dart';

final mockReviews1 = [
  Review(
    id: 'r1',
    userName: 'Sophie Martin',
    rating: 5,
    comment: 'Super expérience ! Les pistes sont en excellent état et l\'ambiance est géniale.',
    date: DateTime(2025, 10, 10),
    avatar: '👩',
  ),
  Review(
    id: 'r2',
    userName: 'Thomas Dubois',
    rating: 4,
    comment: 'Très bon moment entre amis. Juste un peu d\'attente le samedi soir.',
    date: DateTime(2025, 10, 8),
    avatar: '👨',
  ),
];

final mockActivities = [
  Activity(
    id: '1',
    name: 'Bowling Premium',
    price: 15,
    location: 'Centre Commercial Beaulieu',
    image: 'https://images.unsplash.com/photo-1660129071363-d13390de351f?auto=format&fit=crop&w=800&q=80',
    description: 'Profitez d\'une partie de bowling dans notre salle moderne avec 12 pistes équipées. Ambiance lumineuse et musicale garantie !',
    type: 'Sport',
    images: [],
    availableSlots: ['18:00', '19:00', '20:00'],
    reviews: mockReviews1,
    rating: 4.5,
    coordinates: {'lat': 47.2184, 'lng': -1.5536},
    hasPromotion: true,
    promotionText: '2e partie à -50%',
  ),
  Activity(
    id: '2',
    name: 'Escape Game',
    price: 25,
    location: 'Rue du Mystère',
    image: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
    description: 'Résolvez des énigmes en équipe dans des décors immersifs.',
    type: 'Loisir',
    images: [],
    availableSlots: ['16:00', '17:30', '19:00'],
    reviews: [],
    rating: 4.8,
    coordinates: {'lat': 47.2184, 'lng': -1.5536},
    hasPromotion: false,
    promotionText: null,
  ),
];

final mockUser = User(
  name: 'Utilisateur',
  email: 'user@email.com',
  avatar: null,
  favoriteIds: ['1'],
  reservations: [
    Reservation(
      id: 'res1',
      activityId: '1',
      date: DateTime(2025, 12, 15),
      time: '18:00',
      status: 'upcoming',
      participants: 2,
      totalPrice: 30,
    ),
    Reservation(
      id: 'res2',
      activityId: '2',
      date: DateTime(2025, 11, 20),
      time: '19:00',
      status: 'past',
      participants: 4,
      totalPrice: 100,
    ),
  ],
);
