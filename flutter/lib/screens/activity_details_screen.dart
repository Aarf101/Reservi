import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../data/mock_data.dart';
import '../types.dart';
import '../services/review_service.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onReserve;
  final Activity activity;
  const ActivityDetailsScreen({Key? key, required this.onBack, required this.onReserve, required this.activity}) : super(key: key);

  @override
  _ActivityDetailsScreenState createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  bool isFavorite = false;
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    isFavorite = mockUser.favoriteIds.contains(widget.activity.id);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _openGoogleMaps(double lat, double lng) {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ouverture de Google Maps: $url')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Image.network(
                        widget.activity.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      if (widget.activity.hasPromotion ?? false)
                        Positioned(
                          top: 80,
                          left: 16,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                            child: Text('🎉 ${widget.activity.promotionText}', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: widget.onBack,
                ),
                actions: [
                  IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        final id = widget.activity.id;
                        if (mockUser.favoriteIds.contains(id)) {
                          mockUser.favoriteIds.remove(id);
                        } else {
                          mockUser.favoriteIds.add(id);
                        }
                        isFavorite = mockUser.favoriteIds.contains(id);
                      });
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.activity.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                                              child: Text(widget.activity.type, style: TextStyle(color: Colors.blue[700], fontSize: 12, fontWeight: FontWeight.w500)),
                                            ),
                                            SizedBox(width: 12),
                                            Row(
                                              children: [
                                                Icon(Icons.star, size: 18, color: Colors.yellow[700]),
                                                SizedBox(width: 4),
                                                Text(widget.activity.rating.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                                SizedBox(width: 4),
                                                Text('(${widget.activity.reviews.length} avis)', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Prix', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                      Text('${widget.activity.price}€', style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on, size: 20, color: Colors.grey[400]),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Emplacement', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                        SizedBox(height: 4),
                                        Text(widget.activity.location, style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w500)),
                                        SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () => _openGoogleMaps(widget.activity.coordinates['lat'] ?? 0.0, widget.activity.coordinates['lng'] ?? 0.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.navigation, size: 14, color: Colors.blue),
                                              SizedBox(width: 4),
                                              Text('Ouvrir dans Google Maps', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                              SizedBox(height: 12),
                              Text(widget.activity.description, style: TextStyle(color: Colors.grey[600], height: 1.6)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Avis clients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                      Row(
                                    children: [
                                      Icon(Icons.star, size: 18, color: Colors.yellow[700]),
                                      SizedBox(width: 4),
                                          Text('${widget.activity.rating}/5', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              StreamBuilder<List<Review>>(
                                stream: ReviewService.streamReviews(widget.activity.id),
                                builder: (context, snap) {
                                  final reviews = snap.data ?? widget.activity.reviews;
                                  if (reviews.isEmpty) {
                                    return Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Soyez le premier a laisser un avis !', style: TextStyle(color: Colors.grey[500]))));
                                  }
                                  return Column(
                                    children: reviews.map((review) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                                      (() {
                                                        final a = review.avatar;
                                                        if (a == null || a.isEmpty) {
                                                          return CircleAvatar(
                                                            radius: 16,
                                                            child: Text('?', style: TextStyle(fontSize: 12)),
                                                          );
                                                        }

                                                        // HTTP/HTTPS URLs -> NetworkImage
                                                        if (a.startsWith('http') || a.startsWith('https')) {
                                                          return CircleAvatar(radius: 16, backgroundImage: NetworkImage(a));
                                                        }

                                                        // Data URI (base64) -> decode and use MemoryImage
                                                        if (a.startsWith('data:')) {
                                                          try {
                                                            final comma = a.indexOf(',');
                                                            if (comma != -1) {
                                                              final base64Part = a.substring(comma + 1);
                                                              final bytes = base64Decode(base64Part);
                                                              return CircleAvatar(radius: 16, backgroundImage: MemoryImage(bytes));
                                                            }
                                                          } catch (e) {
                                                            // fallthrough to text fallback
                                                          }
                                                        }

                                                        // Fallback: show first 2 characters
                                                        final label = a.length <= 2 ? a : a.substring(0, 2);
                                                        return CircleAvatar(radius: 16, child: Text(label, style: TextStyle(fontSize: 12)));
                                                      })(),
                                              SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(review.userName, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                                  Text('${review.date.day}/${review.date.month}/${review.date.year}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < review.rating ? Colors.yellow[700] : Colors.grey[300]))),
                                          SizedBox(height: 8),
                                          Text(review.comment, style: TextStyle(color: Colors.grey[600], height: 1.5)),
                                          SizedBox(height: 12),
                                          Divider(height: 1),
                                          SizedBox(height: 12),
                                        ],
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Laisser un avis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                              SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (i) {
                                  final idx = i + 1;
                                  return IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(minWidth: 24),
                                    icon: Icon(Icons.star, color: idx <= _selectedRating ? Colors.yellow[700] : Colors.grey[300]),
                                    onPressed: () => setState(() => _selectedRating = idx),
                                  );
                                }),
                              ),
                              TextField(
                                controller: _reviewController,
                                minLines: 2,
                                maxLines: 4,
                                decoration: InputDecoration(hintText: 'Votre avis (facultatif)'),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final current = fb_auth.FirebaseAuth.instance.currentUser;
                                      if (current == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connectez-vous pour laisser un avis')));
                                        return;
                                      }
                                      // Try to include an avatar: prefer FirebaseAuth.photoURL, fallback to users/{uid}.avatar
                                      String? avatar = current.photoURL;
                                      if (avatar == null) {
                                        try {
                                          final userDoc = await FirebaseFirestore.instance.collection('users').doc(current.uid).get();
                                          final userData = userDoc.data();
                                          if (userData != null) {
                                            avatar = (userData['avatar'] as String?) ?? (userData['avatarUrl'] as String?);
                                          }
                                        } catch (e) {
                                          // ignore - avatar stays null
                                        }
                                      }

                                      final review = Review(
                                        id: current.uid,
                                        userName: current.displayName ?? current.email ?? 'Utilisateur',
                                        rating: _selectedRating,
                                        comment: _reviewController.text.trim(),
                                        date: DateTime.now(),
                                        avatar: avatar,
                                      );
                                      try {
                                        await ReviewService.addReview(widget.activity.id, review);
                                        _reviewController.clear();
                                        setState(() => _selectedRating = 5);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Merci pour votre avis')));
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible d\'envoyer l\'avis: $e')));
                                      }
                                    },
                                    child: Text('Envoyer'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Horaires disponibles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                              SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.activity.availableSlots.take(4).map((slot) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                                    child: Text(slot, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                                  );
                                }).toList() +
                                (widget.activity.availableSlots.length > 4
                                    ? [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                                          child: Text('+${widget.activity.availableSlots.length - 4} autres', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)),
                                        ),
                                      ]
                                    : []),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onReserve,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Réserver maintenant', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
