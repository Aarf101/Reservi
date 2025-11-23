import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../types.dart';
import '../data/mock_data.dart';

class PaymentScreen extends StatefulWidget {
  final Activity activity;
  final DateTime date;
  final String time;
  final int participants;
  final VoidCallback onSuccess;
  final VoidCallback onBack;
  const PaymentScreen({Key? key, required this.activity, required this.date, required this.time, required this.participants, required this.onSuccess, required this.onBack}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement', style: TextStyle(color: Colors.grey[900])),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[900]),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Détails du paiement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                    SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom du titulaire', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700], fontSize: 14)),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'Jean Dupont',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Numéro de carte', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700], fontSize: 14)),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: cardNumberController,
                          onChanged: (value) {
                            cardNumberController.value = TextEditingValue(
                              text: _formatCardNumber(value),
                              selection: TextSelection.collapsed(offset: _formatCardNumber(value).length),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: '1234 5678 9012 3456',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
                        ),
                      ],
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
                                onChanged: (value) {
                                  expiryController.value = TextEditingValue(
                                    text: _formatExpiry(value),
                                    selection: TextSelection.collapsed(offset: _formatExpiry(value).length),
                                  );
                                },
                                decoration: InputDecoration(
                                  hintText: 'MM/YY',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
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
                                decoration: InputDecoration(
                                  hintText: '123',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
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
          ),
          SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Récapitulatif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sous-total', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      Text('30€', style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w500)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Frais', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      Text('0€', style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w500)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Divider(height: 1),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Montant total', style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('30€', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(Icons.lock, size: 20, color: Colors.blue[700]),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Paiement sécurisé avec encryption SSL',
                    style: TextStyle(color: Colors.blue[700], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: isProcessing ? null : () async {
              if (_formKey.currentState!.validate()) {
                setState(() => isProcessing = true);
                await Future.delayed(Duration(seconds: 2));
                // create reservation object
                final newRes = Reservation(
                  id: 'res${mockUser.reservations.length + 1}',
                  activityId: widget.activity.id,
                  date: widget.date,
                  time: widget.time,
                  status: 'upcoming',
                  participants: widget.participants,
                  totalPrice: widget.activity.price * widget.participants,
                );

                // Persist reservation to Firestore if user is signed in
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  mockUser.reservations.add(newRes);
                } else {
                  try {
                    final reservationsRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('reservations');
                    final docRef = await reservationsRef.add({
                      'activityId': newRes.activityId,
                      'date': Timestamp.fromDate(newRes.date),
                      'time': newRes.time,
                      'status': newRes.status,
                      'participants': newRes.participants,
                      'totalPrice': newRes.totalPrice,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    // reflect saved reservation id
                    final savedRes = Reservation(
                      id: docRef.id,
                      activityId: newRes.activityId,
                      date: newRes.date,
                      time: newRes.time,
                      status: newRes.status,
                      participants: newRes.participants,
                      totalPrice: newRes.totalPrice,
                    );
                    mockUser.reservations.add(savedRes);
                  } catch (e) {
                    print('Failed to persist reservation to Firestore: $e');
                    // fallback to local storage
                    mockUser.reservations.add(newRes);
                  }
                }
                setState(() => isProcessing = false);
                widget.onSuccess();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: isProcessing ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Payer ${(widget.activity.price * widget.participants).toStringAsFixed(0)}€', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 12),
          OutlinedButton(
            onPressed: widget.onBack,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Annuler', style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
