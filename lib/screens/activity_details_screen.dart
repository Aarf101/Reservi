import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
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

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 5;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _heartScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartAnimationController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  void activate() {
    super.activate();
    // Ensure state is refreshed when returning to this route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh UI when app comes back into focus
      setState(() {});
    }
  }

  bool get isFavorite => mockUser.favoriteIds.contains(widget.activity.id);

  Future<void> _toggleFavorite() async {
    final id = widget.activity.id;
    final currentUser = fb_auth.FirebaseAuth.instance.currentUser;

    setState(() {
      if (mockUser.favoriteIds.contains(id)) {
        mockUser.favoriteIds.remove(id);
      } else {
        mockUser.favoriteIds.add(id);
        _heartAnimationController.forward(from: 0.0);
      }
    });

    // Sync to Firestore if user is signed in
    if (currentUser != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      try {
        if (!isFavorite) {
          await docRef.update({'favoriteIds': FieldValue.arrayRemove([id])});
        } else {
          await docRef.update({'favoriteIds': FieldValue.arrayUnion([id])});
        }
      } catch (e) {
        try {
          await docRef.set({'favoriteIds': [id]}, SetOptions(merge: true));
        } catch (e) {
          print('Failed to toggle favorite in Firestore: $e');
        }
      }
    }
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'ouvrir Google Maps')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ouverture de Google Maps: $e')),
        );
      }
    }
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                            child: Text('🎉 ${widget.activity.promotionText}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: widget.onBack,
                ),
                actions: [
                  ScaleTransition(
                    scale: _heartScaleAnimation,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
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
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                                              child: Text(widget.activity.type, style: TextStyle(color: Colors.blue[700], fontSize: 12, fontWeight: FontWeight.w500)),
                                            ),
                                            const SizedBox(width: 12),
                                            Row(
                                              children: [
                                                Icon(Icons.star, size: 18, color: Colors.yellow[700]),
                                                const SizedBox(width: 4),
                                                Text(widget.activity.rating.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                                const SizedBox(width: 4),
                                                Text('(${widget.activity.reviews.length} avis)', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Prix', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                      Text('${widget.activity.price}€', style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on, size: 20, color: Colors.grey[400]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Emplacement', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Text(widget.activity.location, style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () => _openGoogleMaps(widget.activity.coordinates['lat'] ?? 0.0, widget.activity.coordinates['lng'] ?? 0.0),
                                          child: const Row(
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
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                              const SizedBox(height: 12),
                              Text(widget.activity.description, style: TextStyle(color: Colors.grey[600], height: 1.6)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
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
                                      const SizedBox(width: 4),
                                          Text('${widget.activity.rating.toStringAsFixed(1)}/5', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              StreamBuilder<List<Review>>(
                                stream: ReviewService.streamReviews(widget.activity.id),
                                builder: (context, snap) {
                                  final reviews = snap.data ?? widget.activity.reviews;
                                  if (reviews.isEmpty) {
                                    return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('Soyez le premier a laisser un avis !', style: TextStyle(color: Colors.grey[500]))));
                                  }
                                  return Column(
                                    children: reviews.map((review) {
                                      return _ReviewTile(review: review);
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Laisser un avis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (i) {
                                  final idx = i + 1;
                                  return IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 24),
                                    icon: Icon(Icons.star, color: idx <= _selectedRating ? Colors.yellow[700] : Colors.grey[300]),
                                    onPressed: () => setState(() => _selectedRating = idx),
                                  );
                                }),
                              ),
                              TextField(
                                controller: _reviewController,
                                minLines: 2,
                                maxLines: 4,
                                decoration: const InputDecoration(hintText: 'Votre avis (facultatif)'),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final current = fb_auth.FirebaseAuth.instance.currentUser;
                                      if (current == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connectez-vous pour laisser un avis')));
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
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Merci pour votre avis')));
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible d\'envoyer l\'avis: $e')));
                                      }
                                    },
                                    child: const Text('Envoyer'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Horaires disponibles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.activity.availableSlots.take(4).map((slot) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                                    child: Text(slot, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                                  );
                                }).toList() +
                                (widget.activity.availableSlots.length > 4
                                    ? [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      const SizedBox(height: 100),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onReserve,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Réserver maintenant', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Fetch current user avatar from Firestore instead of using stored snapshot
            FutureBuilder<String?>(
              future: _fetchUserAvatar(review.id),
              builder: (context, snap) {
                final currentAvatar = snap.data ?? review.avatar;
                return _buildAvatarWidget(currentAvatar);
              },
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.userName, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[900])),
                Text('${review.date.day}/${review.date.month}/${review.date.year}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < review.rating ? Colors.yellow[700] : Colors.grey[300]))),
        const SizedBox(height: 8),
        Text(review.comment, style: TextStyle(color: Colors.grey[600], height: 1.5)),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<String?> _fetchUserAvatar(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final data = doc.data();
      if (data != null) {
        final avatar = (data['avatar'] as String?) ?? (data['avatarUrl'] as String?);
        print('DEBUG: Fetched avatar for $userId: $avatar');
        return avatar;
      }
    } catch (e) {
      print('DEBUG: Error fetching avatar for $userId: $e');
    }
    return null;
  }

  Widget _buildAvatarWidget(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const CircleAvatar(
        radius: 16,
        child: Text('?', style: TextStyle(fontSize: 12)),
      );
    }

    // HTTP/HTTPS URLs -> NetworkImage
    if (avatarUrl.startsWith('http') || avatarUrl.startsWith('https')) {
      return CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatarUrl));
    }

    // Data URI (base64) -> decode and use MemoryImage
    if (avatarUrl.startsWith('data:')) {
      try {
        final comma = avatarUrl.indexOf(',');
        if (comma != -1) {
          final base64Part = avatarUrl.substring(comma + 1);
          final bytes = base64Decode(base64Part);
          return CircleAvatar(radius: 16, backgroundImage: MemoryImage(bytes));
        }
      } catch (e) {
        // fallthrough to text fallback
      }
    }

    // Fallback: show first 2 characters
    final label = avatarUrl.length <= 2 ? avatarUrl : avatarUrl.substring(0, 2);
    return CircleAvatar(radius: 16, child: Text(label, style: const TextStyle(fontSize: 12)));
  }
}
