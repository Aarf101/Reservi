import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../types.dart';
import '../data/mock_data.dart';
import '../services/reservation_service.dart';

class PaymentScreen extends StatefulWidget {
  final Activity activity;
  final DateTime date;
  final String time;
  final int participants;
  final VoidCallback onSuccess;
  final VoidCallback onBack;
  final String? reservationId;
  const PaymentScreen({Key? key, required this.activity, required this.date, required this.time, required this.participants, required this.onSuccess, required this.onBack, this.reservationId}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  bool isProcessing = false;
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? reservationId;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

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
      return '${v.substring(0, 2)}/${v.substring(2)}';
    }
    return v;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    if (widget.reservationId != null) {
      setState(() {
        reservationId = widget.reservationId;
      });
    } else {
      _findReservationId();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _findReservationId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      final startOfDay = DateTime(widget.date.year, widget.date.month, widget.date.day);
      final endOfDay = DateTime(widget.date.year, widget.date.month, widget.date.day, 23, 59, 59);
      final startTimestamp = Timestamp.fromDate(startOfDay);
      final endTimestamp = Timestamp.fromDate(endOfDay);
      
      final reservationsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reservations')
          .where('activityId', isEqualTo: widget.activity.id)
          .where('date', isGreaterThanOrEqualTo: startTimestamp)
          .where('date', isLessThanOrEqualTo: endTimestamp)
          .where('time', isEqualTo: widget.time)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      
      if (reservationsSnapshot.docs.isNotEmpty) {
        setState(() {
          reservationId = reservationsSnapshot.docs.first.id;
        });
      }
    } catch (e) {
      print('Error finding reservation: $e');
      // Try without orderBy if it fails
      try {
        final startOfDay = DateTime(widget.date.year, widget.date.month, widget.date.day);
        final endOfDay = DateTime(widget.date.year, widget.date.month, widget.date.day, 23, 59, 59);
        final startTimestamp = Timestamp.fromDate(startOfDay);
        final endTimestamp = Timestamp.fromDate(endOfDay);
        
        final reservationsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('reservations')
            .where('activityId', isEqualTo: widget.activity.id)
            .where('time', isEqualTo: widget.time)
            .get();
        
        for (final doc in reservationsSnapshot.docs) {
          final data = doc.data();
          final resDate = (data['date'] as Timestamp?)?.toDate();
          if (resDate != null && 
              resDate.year == widget.date.year &&
              resDate.month == widget.date.month &&
              resDate.day == widget.date.day) {
            setState(() {
              reservationId = doc.id;
            });
            break;
          }
        }
      } catch (e2) {
        print('Error finding reservation (fallback): $e2');
      }
    }
  }

  Future<void> _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isProcessing = true);
      await Future.delayed(const Duration(seconds: 2));
      
      try {
        if (reservationId != null) {
          await ReservationService.markReservationAsPaid(reservationId!);
        } else {
          // Fallback: create reservation as paid (shouldn't happen, but handle it)
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final totalPrice = widget.activity.price * widget.participants;
            await ReservationService.validateReservation(
              activityId: widget.activity.id,
              date: widget.date,
              time: widget.time,
              participants: widget.participants,
              totalPrice: totalPrice,
            );
            await ReservationService.markReservationAsPaid(reservationId!);
          }
        }
        setState(() => isProcessing = false);
        widget.onSuccess();
      } catch (e) {
        setState(() => isProcessing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du paiement: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _skipPayment() async {
    setState(() => isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => isProcessing = false);
    widget.onSuccess();
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
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Détails du paiement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom du titulaire', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700], fontSize: 14)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'Jean Dupont',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Champ requis';
                            if (value!.length < 3) return 'Nom trop court';
                            if (!RegExp(r'^[a-zA-ZÀ-ÿ\s-]+$').hasMatch(value)) return 'Nom invalide';
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Numéro de carte', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700], fontSize: 14)),
                        const SizedBox(height: 8),
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Champ requis';
                            String digitsOnly = value!.replaceAll(' ', '');
                            if (digitsOnly.length < 13 || digitsOnly.length > 19) return 'Numéro de carte invalide';
                            if (!RegExp(r'^[0-9]+$').hasMatch(digitsOnly)) return 'Chiffres uniquement';
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Expiration', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700], fontSize: 14)),
                              const SizedBox(height: 8),
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
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  counterText: '',
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Requis';
                                  if (!value!.contains('/') || value.length != 5) return 'Format MM/YY';
                                  final parts = value.split('/');
                                  if (parts.length != 2) return 'Format MM/YY';
                                  final month = int.tryParse(parts[0]);
                                  final year = int.tryParse(parts[1]);
                                  if (month == null || year == null) return 'Date invalide';
                                  if (month < 1 || month > 12) return 'Mois invalide (01-12)';
                                  final now = DateTime.now();
                                  final currentYear = now.year % 100;
                                  final currentMonth = now.month;
                                  if (year < currentYear || (year == currentYear && month < currentMonth)) {
                                    return 'Carte expirée';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CVV', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700], fontSize: 14)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: cvvController,
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: '123',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  counterText: '',
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Requis';
                                  if (!RegExp(r'^[0-9]{3,4}$').hasMatch(value!)) return 'CVV invalide (3-4 chiffres)';
                                  return null;
                                },
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
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Récapitulatif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sous-total', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      Text('30€', style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Frais', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      Text('0€', style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Montant total', style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('30€', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(Icons.lock, size: 20, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Paiement sécurisé avec encryption SSL',
                    style: TextStyle(color: Colors.blue[700], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Payer ${(widget.activity.price * widget.participants).toStringAsFixed(0)}€', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: isProcessing ? null : _skipPayment,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Payer plus tard', style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: isProcessing ? null : widget.onBack,
                child: Text('Retour', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
