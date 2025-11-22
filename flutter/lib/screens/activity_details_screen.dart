import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../types.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onReserve;
  const ActivityDetailsScreen({Key? key, required this.onBack, required this.onReserve}) : super(key: key);

  @override
  _ActivityDetailsScreenState createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  late Activity activity;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    activity = mockActivities[0];
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
                        activity.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      if (activity.hasPromotion ?? false)
                        Positioned(
                          top: 80,
                          left: 16,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                            child: Text('🎉 ${activity.promotionText}', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
                    onPressed: () => setState(() => isFavorite = !isFavorite),
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
                                        Text(activity.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                                              child: Text(activity.type, style: TextStyle(color: Colors.blue[700], fontSize: 12, fontWeight: FontWeight.w500)),
                                            ),
                                            SizedBox(width: 12),
                                            Row(
                                              children: [
                                                Icon(Icons.star, size: 18, color: Colors.yellow[700]),
                                                SizedBox(width: 4),
                                                Text(activity.rating.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                                SizedBox(width: 4),
                                                Text('(${activity.reviews.length} avis)', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
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
                                      Text('${activity.price}€', style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
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
                                        Text(activity.location, style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w500)),
                                        SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () => _openGoogleMaps(activity.coordinates['lat'] ?? 0.0, activity.coordinates['lng'] ?? 0.0),
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
                              Text(activity.description, style: TextStyle(color: Colors.grey[600], height: 1.6)),
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
                                      Text('${activity.rating}/5', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              if (activity.reviews.isNotEmpty)
                                Column(
                                  children: activity.reviews.map((review) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(review.avatar ?? 'avatar', style: TextStyle(fontSize: 20)),
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
                                )
                              else
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Text('Soyez le premier a laisser un avis !', style: TextStyle(color: Colors.grey[500])),
                                  ),
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
                              Text('Avis clients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 18, color: Colors.yellow[700]),
                                  SizedBox(width: 4),
                                  Text('${activity.rating}/5', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                ],
                              ),
                              SizedBox(height: 12),
                              if (activity.reviews.isEmpty)
                                Center(
                                  child: Text('Soyez le premier à laisser un avis !', style: TextStyle(color: Colors.grey[500])),
                                )
                              else
                                Column(
                                  children: activity.reviews.map((review) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(review.userName, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                            Text('${review.date.day}/${review.date.month}/${review.date.year}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < review.rating ? Colors.yellow[700] : Colors.grey[300]))),
                                        SizedBox(height: 8),
                                        Text(review.comment, style: TextStyle(color: Colors.grey[600])),
                                        SizedBox(height: 12),
                                        Divider(height: 1),
                                        SizedBox(height: 12),
                                      ],
                                    );
                                  }).toList(),
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
                                children: activity.availableSlots.take(4).map((slot) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                                    child: Text(slot, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                                  );
                                }).toList() +
                                (activity.availableSlots.length > 4
                                    ? [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                                          child: Text('+${activity.availableSlots.length - 4} autres', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)),
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
