import 'package:flutter/material.dart';
import '../types.dart';
import '../widgets/reservi_logo.dart';

class ConfirmationScreen extends StatelessWidget {
  final Activity activity;
  final DateTime date;
  final String time;
  final int participants;
  final VoidCallback onSuccess;
  final VoidCallback onBack;
  const ConfirmationScreen({Key? key, required this.activity, required this.date, required this.time, required this.participants, required this.onSuccess, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          onPressed: onBack,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Résumé de votre réservation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[900])),
          SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow('Activité', activity.name),
                  SizedBox(height: 16),
                  _DetailRow('Date', '${date.day}/${date.month}/${date.year}'),
                  SizedBox(height: 16),
                  _DetailRow('Créneau horaire', time),
                  SizedBox(height: 16),
                  _DetailRow('Participants', participants.toString()),
                  SizedBox(height: 20),
                  Divider(height: 1),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Prix total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                      Text('${(activity.price * participants).toStringAsFixed(0)}€', style: TextStyle(fontSize: 20, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700], size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vérifiez que tous les détails sont corrects avant de procéder au paiement.',
                        style: TextStyle(color: Colors.blue[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: onSuccess,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Procéder au paiement', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 12),
          OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Modifier', style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
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
