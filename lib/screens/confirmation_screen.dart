import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../types.dart';
import '../data/mock_data.dart';
import '../services/reservation_service.dart';

class ConfirmationScreen extends StatefulWidget {
  final Activity activity;
  final DateTime date;
  final String time;
  final int participants;
  final VoidCallback onSuccess;
  final VoidCallback onBack;
  const ConfirmationScreen({Key? key, required this.activity, required this.date, required this.time, required this.participants, required this.onSuccess, required this.onBack}) : super(key: key);

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> with SingleTickerProviderStateMixin {
  bool isProcessing = false;
  String? reservationId;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _validateReservation() async {
    if (isProcessing) return;
    
    setState(() => isProcessing = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      final totalPrice = widget.activity.price * widget.participants;
      
      if (user == null) {
        // Mock mode - just create local reservation
        final newRes = Reservation(
          id: 'res${mockUser.reservations.length + 1}',
          activityId: widget.activity.id,
          date: widget.date,
          time: widget.time,
          status: 'validated',
          participants: widget.participants,
          totalPrice: totalPrice,
          isPaid: false,
        );
        mockUser.reservations.add(newRes);
        setState(() {
          reservationId = newRes.id;
          isProcessing = false;
        });
        widget.onSuccess();
        return;
      }
      
      final resId = await ReservationService.validateReservation(
        activityId: widget.activity.id,
        date: widget.date,
        time: widget.time,
        participants: widget.participants,
        totalPrice: totalPrice,
      );
      
      setState(() {
        reservationId = resId;
        isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation validée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      widget.onSuccess();
    } catch (e) {
      setState(() => isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la validation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation', style: TextStyle(color: Colors.grey[900])),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[900]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isProcessing ? null : widget.onBack,
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Résumé de votre réservation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[900])),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow('Activité', widget.activity.name),
                      const SizedBox(height: 16),
                      _DetailRow('Date', '${widget.date.day}/${widget.date.month}/${widget.date.year}'),
                      const SizedBox(height: 16),
                      _DetailRow('Créneau horaire', widget.time),
                      const SizedBox(height: 16),
                      _DetailRow('Participants', widget.participants.toString()),
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Prix total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                          Text('${(widget.activity.price * widget.participants).toStringAsFixed(0)}€', style: const TextStyle(fontSize: 20, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.green[700], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Validez votre réservation. Le paiement est optionnel et peut être effectué plus tard.',
                            style: TextStyle(color: Colors.green[700], fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isProcessing ? null : _validateReservation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Valider la réservation', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: isProcessing ? null : widget.onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Modifier', style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}