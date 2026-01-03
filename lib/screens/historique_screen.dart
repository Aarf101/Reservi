import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/mock_data.dart';
import '../types.dart';
import '../services/activity_service.dart';

class HistoriqueScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(Activity activity, DateTime date, String time, int participants, String reservationId)? onPay;
  const HistoriqueScreen({Key? key, required this.onBack, this.onPay}) : super(key: key);

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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Réservations', style: TextStyle(color: Colors.grey[900])),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[900]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Passées'),
          ],
        ),
      ),
      body: user == null
          ? _buildFromMock()
          : StreamBuilder<List<Activity>>(
              stream: ActivityService.activitiesStream(),
              builder: (context, activitiesSnapshot) {
                final activities = activitiesSnapshot.data ?? mockActivities;
                
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('reservations')
                      .orderBy('date', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('Aucune réservation', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Réserve une activité pour voir tes réservations', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                          ],
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;
                    final reservations = docs.map((d) {
                      final data = d.data();
                      final Timestamp? ts = data['date'] is Timestamp ? data['date'] as Timestamp : null;
                      final date = ts != null ? ts.toDate() : DateTime.now();
                      final participantsRaw = data['participants'];
                      final int participants = participantsRaw is int ? participantsRaw : (participantsRaw is double ? participantsRaw.toInt() : 1);
                      final totalRaw = data['totalPrice'];
                      final double totalPrice = totalRaw is double ? totalRaw : (totalRaw is int ? totalRaw.toDouble() : 0.0);

                      final isPaid = data['isPaid'] as bool? ?? false;
                      return Reservation(
                        id: d.id,
                        activityId: data['activityId'] ?? '',
                        date: date,
                        time: data['time'] ?? '',
                        status: data['status'] ?? 'upcoming',
                        participants: participants,
                        totalPrice: totalPrice,
                        isPaid: isPaid,
                      );
                    }).toList();

                    final upcomingReservations = reservations.where((r) => r.date.isAfter(DateTime.now())).toList();
                    final pastReservations = reservations.where((r) => r.date.isBefore(DateTime.now())).toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildReservationList(upcomingReservations, isUpcoming: true, activities: activities),
                        _buildReservationList(pastReservations, isUpcoming: false, activities: activities),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildFromMock() {
    final reservations = mockUser.reservations;
    final upcomingReservations = reservations.where((r) => r.date.isAfter(DateTime.now())).toList();
    final pastReservations = reservations.where((r) => r.date.isBefore(DateTime.now())).toList();

    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Aucune réservation', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const SizedBox(height: 8),
            Text('Réserve une activité pour voir tes réservations', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildReservationList(upcomingReservations, isUpcoming: true, activities: mockActivities),
        _buildReservationList(pastReservations, isUpcoming: false, activities: mockActivities),
      ],
    );
  }

  Widget _buildReservationList(List reservations, {required bool isUpcoming, required List<Activity> activities}) {
    if (reservations.isEmpty) {
      return Center(
        child: Text(
          isUpcoming ? 'Aucune réservation à venir' : 'Aucune réservation passée',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }
    return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                final activity = activities.firstWhere((a) => a.id == reservation.activityId, orElse: () => mockActivities[0]);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                    Text(activity.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[900])),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${reservation.date.day}/${reservation.date.month}/${reservation.date.year}',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                                        const SizedBox(width: 8),
                                        Text(reservation.time, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.people, size: 16, color: Colors.grey[500]),
                                        const SizedBox(width: 8),
                                        Text('${reservation.participants} participant${reservation.participants > 1 ? 's' : ''}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Montant', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                              Text('${reservation.totalPrice}€', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[900], fontSize: 16)),
                            ],
                          ),
                          if (!reservation.isPaid && isUpcoming && widget.onPay != null) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => widget.onPay!(activity, reservation.date, reservation.time, reservation.participants, reservation.id),
                                icon: const Icon(Icons.payment, size: 18),
                                label: const Text('Payer maintenant'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                          if (reservation.isPaid && isUpcoming) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green[300]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                                  const SizedBox(width: 6),
                                  Text('Payé', style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
  }
}
