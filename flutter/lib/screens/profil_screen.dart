import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class ProfilScreen extends StatelessWidget {
  final VoidCallback onLogout;
  const ProfilScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = mockUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil', style: TextStyle(color: Colors.grey[900])),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[900]),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF9333EA)]),
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  SizedBox(height: 16),
                  Text(user.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  SizedBox(height: 4),
                  Text(user.email, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  SizedBox(height: 16),
                  _InfoRow('Nom', user.name),
                  SizedBox(height: 12),
                  _InfoRow('Email', user.email),
                  SizedBox(height: 12),
                  _InfoRow('Téléphone', '+33 6 12 34 56 78'),
                  SizedBox(height: 12),
                  _InfoRow('Adresse', '123 Rue de la Paix, 75000 Paris'),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Préférences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notifications', style: TextStyle(color: Colors.grey[700])),
                      Switch(value: true, onChanged: (val) {}),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Offres spéciales', style: TextStyle(color: Colors.grey[700])),
                      Switch(value: true, onChanged: (val) {}),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mode sombre', style: TextStyle(color: Colors.grey[700])),
                      Switch(value: false, onChanged: (val) {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: onLogout,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Déconnexion', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w500)),
      ],
    );
  }
}
