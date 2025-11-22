import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../components/activity_card.dart';

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
    final favorites = mockActivities.where((a) => mockUser.favoriteIds.contains(a.id)).toList();
    
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
      body: favorites.isEmpty
          ? Center(
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
            )
          : Padding(
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
            ),
    );
  }
}
