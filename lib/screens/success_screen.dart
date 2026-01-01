import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final VoidCallback onHome;
  const SuccessScreen({Key? key, required this.onHome}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F4FF), Color(0xFFF8F5FF)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.green[200]!, blurRadius: 20)],
                    ),
                    child: Icon(Icons.check_circle, size: 80, color: Colors.green[700]),
                  ),
                  const SizedBox(height: 32),
                  Text('Réservation confirmée !', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  const SizedBox(height: 12),
                  Text('Votre réservation a été effectuée avec succès', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Un email de confirmation a été envoyé', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                  const SizedBox(height: 40),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _ConfirmationDetail('Activité', 'Bowling Premium'),
                          SizedBox(height: 12),
                          Divider(height: 1),
                          SizedBox(height: 12),
                          _ConfirmationDetail('Date', '22/11/2025 à 18:00'),
                          SizedBox(height: 12),
                          Divider(height: 1),
                          SizedBox(height: 12),
                          _ConfirmationDetail('Numéro de réservation', 'RES-2025-001234'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onHome,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Retourner à l\'accueil', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmationDetail extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmationDetail(this.label, this.value);

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
