import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../data/mock_data.dart';
import '../types.dart';
import '../services/activity_service.dart';
import '../components/activity_card.dart';
import '../services/recommendation_service.dart';
import '../services/messaging_service.dart';
import '../widgets/reservi_logo.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class HomeScreen extends StatefulWidget {
  final ValueChanged<Activity> onDetails;
  final VoidCallback? onHistorique;
  final VoidCallback? onProfil;
  final VoidCallback? onFavoris;
  const HomeScreen({Key? key, required this.onDetails, this.onHistorique, this.onProfil, this.onFavoris}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String searchQuery = '';
  String selectedType = 'all';
  String selectedCenter = 'all';
  String priceFilter = 'all';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  FocusNode searchFocusNode = FocusNode();
  bool isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    
    searchFocusNode.addListener(() {
      setState(() {
        isSearchFocused = searchFocusNode.hasFocus;
      });
    });
    
    ActivityService.seedActivitiesIfEmpty().catchError((e) => print('Activity seeding failed: $e'));
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  List<Activity> _filter(List<Activity> activities) {
    return activities.where((activity) {
      final matchesSearch = activity.name.toLowerCase().contains(searchQuery.toLowerCase()) || activity.location.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesType = selectedType == 'all' || activity.type == selectedType;
      final matchesCenter = selectedCenter == 'all' || activity.location == selectedCenter;
      bool matchesPrice = true;
      if (priceFilter == 'low') matchesPrice = activity.price <= 15;
      if (priceFilter == 'medium') matchesPrice = activity.price > 15 && activity.price <= 25;
      if (priceFilter == 'high') matchesPrice = activity.price > 25;
      return matchesSearch && matchesType && matchesPrice && matchesCenter;
    }).toList();
  }

  Future<void> _addSampleActivity() async {
    try {
      await FirebaseFirestore.instance.collection('activities').add({
        'name': 'Cinema Grand Rex',
        'price': 8,
        'location': 'Centre-ville',
        'image': 'https://example.com/cinema.jpg',
        'description': 'Séances en soirée, réservation conseillée.',
        'type': 'Loisir',
        'images': [],
        'availableSlots': ['17:00', '19:30', '21:00'],
        'rating': 4.6,
        'coordinates': {'lat': 47.21, 'lng': -1.55},
        'hasPromotion': true,
        'promotionText': 'Jeudi -50% sur la 2e place',
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sample activity added to Firestore')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add sample activity: $e')));
    }
  }

  Widget _buildScaffold(List<Activity> activities, List<String> favIds, {required bool signedIn, fb_auth.User? user}) {
    final filteredActivities = _filter(activities);
    final promotions = activities.where((a) => a.hasPromotion ?? false).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient AppBar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 2,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF3E8FF).withOpacity(0.3)],
                  ),
                ),
              ),
            ),
            title: ReserviLogo(
              iconSize: 32,
              fontSize: 22,
              textColor: Colors.grey[800],
            ),
            actions: [
              IconButton(icon: Icon(Icons.favorite_border), onPressed: widget.onFavoris),
              if (kDebugMode)
                IconButton(
                  icon: Icon(Icons.notifications_active_outlined),
                  tooltip: 'Debug notifications',
                  onPressed: () async {
                    final token = await MessagingService.getToken();
                    final when = DateTime.now().add(Duration(seconds: 10));
                    await MessagingService.scheduleReservationReminder(when, 'Test reminder', 'Local notification scheduled in 10s');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scheduled local notif in 10s; token printed to console')));
                    // ignore: avoid_print
                    print('DEBUG FCM token: $token');
                  },
                ),
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: widget.onProfil,
                  child: _buildProfileAvatar(user),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Promotions banner with animation
                    if (promotions.isNotEmpty)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, (1 - value) * 20),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFEE2E2), Color(0xFFFECACA)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFFECACA), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFDC2626).withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_offer, color: Color(0xFFDC2626), size: 22),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '🎉 ${promotions.length} promotion${promotions.length > 1 ? 's' : ''} en cours ! Ne manquez pas nos offres spéciales.',
                                  style: TextStyle(
                                    color: Color(0xFFB91C1C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (promotions.isNotEmpty) SizedBox(height: 18),
                    // Enhanced Search Bar with Suggestions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        focusNode: searchFocusNode,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search activities...',
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: isSearchFocused
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = '';
                                      searchFocusNode.unfocus();
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                    ),
                    SizedBox(height: 18),
                    // Filter pills with smooth transitions
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterPill(
                            label: 'Tous types',
                            isSelected: selectedType == 'all',
                            onTap: () => setState(() => selectedType = 'all'),
                          ),
                          SizedBox(width: 8),
                          _FilterPill(
                            label: 'Sport',
                            isSelected: selectedType == 'Sport',
                            onTap: () => setState(() => selectedType = 'Sport'),
                          ),
                          SizedBox(width: 8),
                          _FilterPill(
                            label: 'Loisir',
                            isSelected: selectedType == 'Loisir',
                            onTap: () => setState(() => selectedType = 'Loisir'),
                          ),
                          SizedBox(width: 16),
                          // Center filter dropdown
                          Builder(builder: (ctx) {
                            final centers = activities.map((a) => a.location).toSet().toList();
                            centers.sort();
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                              child: DropdownButton<String>(
                                value: selectedCenter,
                                items: [DropdownMenuItem(value: 'all', child: Text('Tous centres'))] + centers.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (v) => setState(() => selectedCenter = v ?? 'all'),
                                underline: SizedBox.shrink(),
                                elevation: 0,
                              ),
                            );
                          }),
                          _FilterPill(
                            label: 'Tous prix',
                            isSelected: priceFilter == 'all',
                            onTap: () => setState(() => priceFilter = 'all'),
                          ),
                          SizedBox(width: 8),
                          _FilterPill(
                            label: '- 15€',
                            isSelected: priceFilter == 'low',
                            onTap: () => setState(() => priceFilter = 'low'),
                          ),
                          SizedBox(width: 8),
                          _FilterPill(
                            label: '15€ - 25€',
                            isSelected: priceFilter == 'medium',
                            onTap: () => setState(() => priceFilter = 'medium'),
                          ),
                          SizedBox(width: 8),
                          _FilterPill(
                            label: '+ 25€',
                            isSelected: priceFilter == 'high',
                            onTap: () => setState(() => priceFilter = 'high'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // Personalized recommendations
                    FutureBuilder<List<Activity>>(
                      future: RecommendationService.recommendForUser(signedIn ? user?.uid : null),
                      builder: (context, snap) {
                        final recs = snap.data ?? [];
                        if (recs.isEmpty) return SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12),
                            Text('Recommandations pour vous', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                            SizedBox(height: 12),
                            SizedBox(
                              height: 160,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: recs.length,
                                separatorBuilder: (_, __) => SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final a = recs[index];
                                  return SizedBox(
                                    width: 160,
                                    child: GestureDetector(
                                      onTap: () => widget.onDetails(a),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              a.image,
                                              width: 160,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Container(
                                                width: 160,
                                                height: 120,
                                                color: Colors.grey[200],
                                                child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            a.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[900]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 12),
                          ],
                        );
                      },
                    ),

                    // Results count
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${filteredActivities.length}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          TextSpan(
                            text: ' activité${filteredActivities.length > 1 ? 's' : ''} disponible${filteredActivities.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: filteredActivities.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.search, size: 48, color: Colors.grey[300]),
                            SizedBox(height: 16),
                            Text(
                              'Aucune activité trouvée',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Essayez d\'ajuster vos filtres',
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : MediaQuery.of(context).size.width > 600 ? 2 : 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: 320,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final activity = filteredActivities[index];
                        final isFav = favIds.contains(activity.id);
                        return _AnimatedActivityCard(
                          activity: activity,
                          isFav: isFav,
                          index: index,
                          onClick: () => widget.onDetails(activity),
                          onToggleFavorite: () async {
                            final id = activity.id;
                            if (!signedIn || user == null) {
                              setState(() {
                                if (mockUser.favoriteIds.contains(id)) mockUser.favoriteIds.remove(id);
                                else mockUser.favoriteIds.add(id);
                              });
                              return;
                            }

                            final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
                            try {
                              if (isFav) {
                                await docRef.update({'favoriteIds': FieldValue.arrayRemove([id])});
                                setState(() {
                                  if (mockUser.favoriteIds.contains(id)) mockUser.favoriteIds.remove(id);
                                });
                              } else {
                                await docRef.update({'favoriteIds': FieldValue.arrayUnion([id])});
                                setState(() {
                                  if (!mockUser.favoriteIds.contains(id)) mockUser.favoriteIds.add(id);
                                });
                              }
                            } catch (e) {
                              try {
                                await docRef.set({'favoriteIds': [id]}, SetOptions(merge: true));
                                setState(() {
                                  if (!mockUser.favoriteIds.contains(id)) mockUser.favoriteIds.add(id);
                                });
                              } catch (e) {
                                print('Failed to toggle favorite in Firestore: $e');
                              }
                            }
                          },
                        );
                      },
                      childCount: filteredActivities.length,
                    ),
                  ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Réservations'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profil'),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) widget.onHistorique?.call();
          if (index == 2) widget.onProfil?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Activity>>(
      stream: ActivityService.activitiesStream(),
      builder: (context, snapshot) {
        final activities = snapshot.data ?? mockActivities;
        final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          return _buildScaffold(activities, mockUser.favoriteIds, signedIn: false);
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
          builder: (context, userSnap) {
            final udata = userSnap.data?.data();
            final favIds = udata != null && udata['favoriteIds'] is List ? List<String>.from(udata['favoriteIds']) : <String>[];
            return _buildScaffold(activities, favIds, signedIn: true, user: currentUser);
          },
        );
      },
    );
  }

  Widget _buildProfileAvatar(fb_auth.User? user) {
    if (user == null) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.account_circle, color: Colors.grey[600], size: 24),
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        String? avatarUrl;
        
        if (snapshot.hasData && snapshot.data?.data() != null) {
          final data = snapshot.data!.data()!;
          avatarUrl = data['avatarUrl'] as String? ?? data['avatar'] as String?;
        }
        
        // Fallback to Firebase Auth photo URL
        avatarUrl ??= user.photoURL;

        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
            return CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(avatarUrl),
              onBackgroundImageError: (_, __) {},
              child: Container(),
            );
          } else if (avatarUrl.startsWith('data:image')) {
            // Handle base64 data URI
            try {
              final base64String = avatarUrl.split(',').last;
              final bytes = const Base64Decoder().convert(base64String);
              return CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                backgroundImage: MemoryImage(bytes),
              );
            } catch (e) {
              // Fallback on error
            }
          }
        }

        // Default avatar with user initial
        final initial = user.email?.isNotEmpty == true ? user.email![0].toUpperCase() : 'U';
        return CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFF2563EB),
          child: Text(
            initial,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }
}

// Animated filter pill widget
class _FilterPill extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FilterPill> createState() => _FilterPillState();
}

class _FilterPillState extends State<_FilterPill> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _colorAnimation = ColorTween(
      begin: Colors.grey[200],
      end: Color(0xFF2563EB),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(_FilterPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)])
                    : null,
                color: widget.isSelected ? null : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected ? Colors.transparent : Colors.grey[300]!,
                  width: 1.5,
                ),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                ],
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Staggered animation for activity cards
class _AnimatedActivityCard extends StatefulWidget {
  final Activity activity;
  final bool isFav;
  final int index;
  final VoidCallback onClick;
  final VoidCallback onToggleFavorite;

  const _AnimatedActivityCard({
    required this.activity,
    required this.isFav,
    required this.index,
    required this.onClick,
    required this.onToggleFavorite,
  });

  @override
  State<_AnimatedActivityCard> createState() => _AnimatedActivityCardState();
}

class _AnimatedActivityCardState extends State<_AnimatedActivityCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Stagger animations based on index with shorter delays
    final delay = (widget.index * 50).clamp(0, 300);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ActivityCard(
          activity: widget.activity,
          onClick: widget.onClick,
          isFavorite: widget.isFav,
          onToggleFavorite: widget.onToggleFavorite,
        ),
      ),
    );
  }
}
