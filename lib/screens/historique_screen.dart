import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/mock_data.dart';
import '../types.dart';
import '../widgets/reservi_logo.dart';

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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: ReserviLogo(
          iconSize: 28,
          fontSize: 20,
          textColor: Colors.grey[900],
        ),
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
            Tab(text: 'À venir'),
            Tab(text: 'Passées'),
          ],
        ),
      ),
      body: user == null
          ? _buildFromMock()
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('reservations')
                  .orderBy('date', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
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

                  return Reservation(
                    id: d.id,
                    activityId: data['activityId'] ?? '',
                    date: date,
                    time: data['time'] ?? '',
                    status: data['status'] ?? 'upcoming',
                    participants: participants,
                    totalPrice: totalPrice,
                    isPaid: data['isPaid'] ?? false,
                  );
                }).toList();

                final upcomingReservations = reservations.where((r) => r.date.isAfter(DateTime.now())).toList();
                final pastReservations = reservations.where((r) => r.date.isBefore(DateTime.now())).toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReservationList(upcomingReservations, isUpcoming: true),
                    _buildReservationList(pastReservations, isUpcoming: false),
                  ],
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
            SizedBox(height: 16),
            Text('Aucune réservation', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            SizedBox(height: 8),
            Text('Réserve une activité pour voir tes réservations', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildReservationList(upcomingReservations, isUpcoming: true),
        _buildReservationList(pastReservations, isUpcoming: false),
      ],
    );
  }

  Future<void> _handlePayment(Reservation reservation) async {
    final activity = mockActivities.firstWhere((a) => a.id == reservation.activityId, orElse: () => mockActivities[0]);
    
    // Show payment dialog
    await showDialog(
      context: context,
      builder: (context) => _PaymentDialog(
        reservation: reservation,
        activity: activity,
        onPaymentSuccess: () {
          Navigator.of(context).pop();
          setState(() {}); // Refresh the list
        },
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
                          if (isUpcoming && !reservation.isPaid) ...[
                            SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _handlePayment(reservation),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                minimumSize: Size(double.infinity, 0),
                              ),
                              child: Text('Payer maintenant', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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

class _PaymentDialog extends StatefulWidget {
  final Reservation reservation;
  final Activity activity;
  final VoidCallback onPaymentSuccess;

  const _PaymentDialog({
    required this.reservation,
    required this.activity,
    required this.onPaymentSuccess,
  });

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  bool isProcessing = false;
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _formatCardNumber(String value) {
    String v = value.replaceAll(' ', '').replaceAll(RegExp(r'[^0-9]'), '');
    List<String> parts = [];
    for (int i = 0; i < v.length; i += 4) {
      int end = i + 4;
      if (end > v.length) end = v.length;
      parts.add(v.substring(i, end));
    }
    return parts.join(' ');
  }

  String _formatExpiry(String value) {
    String v = value.replaceAll(' ', '').replaceAll(RegExp(r'[^0-9]'), '');
    if (v.length >= 2) {
      return v.substring(0, 2) + '/' + v.substring(2);
    }
    return v;
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isProcessing = true);

    try {
      await Future.delayed(Duration(seconds: 1)); // Simulate payment processing

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Update mock reservation
        final index = mockUser.reservations.indexWhere((r) => r.id == widget.reservation.id);
        if (index != -1) {
          final updatedRes = Reservation(
            id: widget.reservation.id,
            activityId: widget.reservation.activityId,
            date: widget.reservation.date,
            time: widget.reservation.time,
            status: widget.reservation.status,
            participants: widget.reservation.participants,
            totalPrice: widget.reservation.totalPrice,
            isPaid: true,
          );
          mockUser.reservations[index] = updatedRes;
        }
      } else {
        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('reservations')
            .doc(widget.reservation.id)
            .update({'isPaid': true});
      }

      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paiement effectué avec succès!')),
      );
      widget.onPaymentSuccess();
    } catch (e) {
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du paiement: $e')),
      );
    }
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Paiement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Montant à payer: ${widget.reservation.totalPrice}€', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                SizedBox(height: 24),
                Text('Nom du titulaire', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700], fontSize: 14)),
                SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Jean Dupont',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Champ requis';
                    if (value!.length < 3) return 'Nom trop court';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text('Numéro de carte', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700], fontSize: 14)),
                SizedBox(height: 8),
                TextFormField(
                  controller: cardNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  onChanged: (value) {
                    cardNumberController.value = TextEditingValue(
                      text: _formatCardNumber(value),
                      selection: TextSelection.collapsed(offset: _formatCardNumber(value).length),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: '1234 5678 9012 3456',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Champ requis';
                    String digitsOnly = value!.replaceAll(' ', '');
                    if (digitsOnly.length < 13 || digitsOnly.length > 19) return 'Numéro de carte invalide';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Expiration', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700], fontSize: 14)),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: expiryController,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            onChanged: (value) {
                              expiryController.value = TextEditingValue(
                                text: _formatExpiry(value),
                                selection: TextSelection.collapsed(offset: _formatExpiry(value).length),
                              );
                            },
                            decoration: InputDecoration(
                              hintText: 'MM/YY',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              counterText: '',
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Requis';
                              if (!value!.contains('/') || value.length != 5) return 'Format MM/YY';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CVV', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700], fontSize: 14)),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: cvvController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '123',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              counterText: '',
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Requis';
                              if (!RegExp(r'^[0-9]{3,4}$').hasMatch(value!)) return 'CVV invalide';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size(double.infinity, 0),
                  ),
                  child: isProcessing
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Payer ${widget.reservation.totalPrice}€', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
