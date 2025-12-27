import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/mock_data.dart';
import '../components/activity_card.dart';
import '../services/activity_service.dart';
import '../types.dart';

class FavorisScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onDetails;
  const FavorisScreen({Key? key, required this.onBack, required this.onDetails}) : super(key: key);

  @override
  _FavorisScreenState createState() => _FavorisScreenState();
}

class _FavorisScreenState extends State<FavorisScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Favoris', style: TextStyle(color: Colors.grey[900])),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[900]),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: user == null
          ? _buildFromMock(context)
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data == null) return _buildFromMock(context);
                final data = snapshot.data!.data();
                final favIds = data != null && data['favoriteIds'] is List ? List<String>.from(data['favoriteIds']) : <String>[];

                return StreamBuilder<List<Activity>>(
                  stream: ActivityService.activitiesStream(),
                  builder: (context, actSnap) {
                    final activities = actSnap.data ?? mockActivities;
                    final favorites = activities.where((a) => favIds.contains(a.id)).toList();
                    if (favorites.isEmpty) return _buildEmpty();
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${favorites.length} activite${favorites.length > 1 ? 's' : ''} enregistree${favorites.length > 1 ? 's' : ''}', 
                            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                          SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : MediaQuery.of(context).size.width > 600 ? 2 : 1,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.65,
                              ),
                              itemCount: favorites.length,
                              itemBuilder: (context, index) {
                                final activity = favorites[index];
                                return Stack(
                                  children: [
                                    ActivityCard(
                                      activity: activity,
                                      onClick: widget.onDetails,
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
                                          try {
                                            // Update local mockUser first for immediate UI response
                                            setState(() {
                                              if (mockUser.favoriteIds.contains(activity.id)) {
                                                mockUser.favoriteIds.remove(activity.id);
                                              } else {
                                                mockUser.favoriteIds.add(activity.id);
                                              }
                                            });
                                            
                                            // Then sync to Firestore
                                            await docRef.update({
                                              'favoriteIds': FieldValue.arrayRemove([activity.id])
                                            });
                                          } catch (e) {
                                            print('Error toggling favorite: $e');
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
                                          ),
                                          child: Icon(Icons.favorite, color: Colors.red[500], size: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text('Aucun favori pour le moment', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          SizedBox(height: 8),
          Text('Ajoute des activites a tes favoris', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Explorer les activites', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFromMock(BuildContext context) {
    final favorites = mockActivities.where((a) => mockUser.favoriteIds.contains(a.id)).toList();
    if (favorites.isEmpty) return _buildEmpty();
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${favorites.length} activite${favorites.length > 1 ? 's' : ''} enregistree${favorites.length > 1 ? 's' : ''}', 
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : MediaQuery.of(context).size.width > 600 ? 2 : 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final activity = favorites[index];
                final isFav = mockUser.favoriteIds.contains(activity.id);
                return Stack(
                  children: [
                    ActivityCard(
                      activity: activity,
                      onClick: widget.onDetails,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isFav) {
                              mockUser.favoriteIds.remove(activity.id);
                            } else {
                              mockUser.favoriteIds.add(activity.id);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
                          ),
                          child: Icon(Icons.favorite, color: Colors.red[500], size: 20),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
