import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../components/activity_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onDetails;
  final VoidCallback? onHistorique;
  final VoidCallback? onProfil;
  final VoidCallback? onFavoris;
  const HomeScreen({
    Key? key,
    required this.onDetails,
    this.onHistorique,
    this.onProfil,
    this.onFavoris,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  String selectedType = 'all';
  String priceFilter = 'all';

  List<dynamic> getFilteredActivities() {
    return mockActivities.where((activity) {
      final matchesSearch = activity.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          activity.location.toLowerCase().contains(searchQuery.toLowerCase());
      
      final matchesType = selectedType == 'all' || activity.type == selectedType;
      
      bool matchesPrice = true;
      if (priceFilter == 'low') {
        matchesPrice = activity.price <= 15;
      } else if (priceFilter == 'medium') {
        matchesPrice = activity.price > 15 && activity.price <= 25;
      } else if (priceFilter == 'high') {
        matchesPrice = activity.price > 25;
      }

      return matchesSearch && matchesType && matchesPrice;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredActivities = getFilteredActivities();
    final promotions = mockActivities.where((a) => a.hasPromotion ?? false).toList();

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
              IconButton(
                icon: Icon(Icons.favorite_border),
                onPressed: widget.onFavoris,
              ),
              IconButton(
                icon: Icon(Icons.account_circle),
                onPressed: widget.onProfil,
              ),
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
                      (context, index) => ActivityCard(activity: filteredActivities[index], onClick: widget.onDetails),
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
}
