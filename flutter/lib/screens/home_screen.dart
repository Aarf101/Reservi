import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/mock_data.dart';
import '../types.dart';
import '../services/activity_service.dart';
import '../components/activity_card.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<Activity> onDetails;
  final VoidCallback? onHistorique;
  final VoidCallback? onProfil;
  final VoidCallback? onFavoris;
  const HomeScreen({Key? key, required this.onDetails, this.onHistorique, this.onProfil, this.onFavoris}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  String selectedType = 'all';
  String priceFilter = 'all';

  @override
  void initState() {
    super.initState();
    ActivityService.seedActivitiesIfEmpty().catchError((e) => print('Activity seeding failed: $e'));
  }

  List<Activity> _filter(List<Activity> activities) {
    return activities.where((activity) {
      final matchesSearch = activity.name.toLowerCase().contains(searchQuery.toLowerCase()) || activity.location.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesType = selectedType == 'all' || activity.type == selectedType;
      bool matchesPrice = true;
      if (priceFilter == 'low') matchesPrice = activity.price <= 15;
      if (priceFilter == 'medium') matchesPrice = activity.price > 15 && activity.price <= 25;
      if (priceFilter == 'high') matchesPrice = activity.price > 25;
      return matchesSearch && matchesType && matchesPrice;
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
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF9333EA)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.star, color: Colors.white, size: 20),
                ),
                SizedBox(width: 8),
                Text('Reservi', style: TextStyle(color: Colors.grey[800], fontSize: 20)),
              ],
            ),
            actions: [
              if (kDebugMode) IconButton(icon: Icon(Icons.add), tooltip: 'Add sample activity', onPressed: _addSampleActivity),
              IconButton(icon: Icon(Icons.favorite_border), onPressed: widget.onFavoris),
              IconButton(icon: Icon(Icons.account_circle), onPressed: widget.onProfil),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (promotions.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8), border: Border.all(color: Color(0xFFFECACA))),
                      child: Row(
                        children: [
                          Icon(Icons.card_giftcard, color: Color(0xFFDC2626), size: 20),
                          SizedBox(width: 8),
                          Expanded(child: Text('🎉 ${promotions.length} promotion${promotions.length > 1 ? 's' : ''} en cours ! Ne manquez pas nos offres spéciales.', style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  if (promotions.isNotEmpty) SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une activité ou un mall...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: selectedType,
                          onChanged: (value) => setState(() => selectedType = value!),
                          items: [
                            DropdownMenuItem(value: 'all', child: Text('Tous types')),
                            DropdownMenuItem(value: 'Sport', child: Text('Sport')),
                            DropdownMenuItem(value: 'Loisir', child: Text('Loisir')),
                          ],
                        ),
                        SizedBox(width: 12),
                        DropdownButton<String>(
                          value: priceFilter,
                          onChanged: (value) => setState(() => priceFilter = value!),
                          items: [
                            DropdownMenuItem(value: 'all', child: Text('Tous prix')),
                            DropdownMenuItem(value: 'low', child: Text('- de 15€')),
                            DropdownMenuItem(value: 'medium', child: Text('15€ - 25€')),
                            DropdownMenuItem(value: 'high', child: Text('+ de 25€')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('${filteredActivities.length} activité${filteredActivities.length > 1 ? 's' : ''} disponible${filteredActivities.length > 1 ? 's' : ''}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: filteredActivities.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(child: Text('Aucune activité trouvée pour ces critères', style: TextStyle(color: Colors.grey[500]))),
                  )
                : SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : MediaQuery.of(context).size.width > 600 ? 2 : 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final activity = filteredActivities[index];
                        final isFav = favIds.contains(activity.id);
                        return ActivityCard(
                          activity: activity,
                          onClick: () => widget.onDetails(activity),
                          isFavorite: isFav,
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
}
