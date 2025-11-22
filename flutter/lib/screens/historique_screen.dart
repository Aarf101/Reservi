import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class HistoriqueScreen extends StatefulWidget {
  final VoidCallback onBack;
  const HistoriqueScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  _HistoriqueScreenState createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reservations = mockUser.reservations;
    final upcomingReservations = reservations.where((r) => r.date.isAfter(DateTime.now())).toList();
    final pastReservations = reservations.where((r) => r.date.isBefore(DateTime.now())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Réservations', style: TextStyle(color: Colors.grey[900])),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[900]),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'À venir (${upcomingReservations.length})'),
            Tab(text: 'Passées (${pastReservations.length})'),
          ],
        ),
      ),
      body: reservations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text('Aucune réservation', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Réserve une activité pour voir tes réservations', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReservationList(upcomingReservations, isUpcoming: true),
                _buildReservationList(pastReservations, isUpcoming: false),
              ],
            ),
    );
  }

  Widget _buildReservationList(List reservations, {required bool isUpcoming}) {
    if (reservations.isEmpty) {
      return Center(
        child: Text(
          isUpcoming ? 'Aucune réservation à venir' : 'Aucune réservation passée',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }
    return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                final activity = mockActivities.firstWhere((a) => a.id == reservation.activityId, orElse: () => mockActivities[0]);

                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                    Text(activity.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[900])),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                                        SizedBox(width: 8),
                                        Text(
                                          '${reservation.date.day}/${reservation.date.month}/${reservation.date.year}',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                        ),
                                        SizedBox(width: 16),
                                        Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                                        SizedBox(width: 8),
                                        Text(reservation.time, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.people, size: 16, color: Colors.grey[500]),
                                        SizedBox(width: 8),
                                        Text('${reservation.participants} participant${reservation.participants > 1 ? 's' : ''}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isUpcoming ? Colors.green[50] : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isUpcoming ? 'À venir' : 'Passée',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isUpcoming ? Colors.green[700] : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Divider(height: 1),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Montant', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                              Text('${reservation.totalPrice}€', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[900], fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
  }
}
