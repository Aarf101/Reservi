import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/mock_data.dart';

class ProfilScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback? onBack;
  const ProfilScreen({Key? key, required this.onLogout, this.onBack}) : super(key: key);

  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final nameController = TextEditingController();
  final avatarController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  bool isLoading = true;
  bool isSaving = false;
  String? error;

  fb_auth.User? authUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { isLoading = true; error = null; });
    authUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      // fallback to mock
      nameController.text = mockUser.name;
      avatarController.text = mockUser.avatar ?? '';
      phoneController.text = mockUser.phone ?? '';
      addressController.text = mockUser.address ?? '';
      setState(() { isLoading = false; });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(authUser!.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        nameController.text = data['name'] ?? authUser!.displayName ?? mockUser.name;
        avatarController.text = data['avatarUrl'] ?? '';
          phoneController.text = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';
        // update mockUser locally for consistency
        mockUser.name = nameController.text;
        mockUser.avatar = avatarController.text.isNotEmpty ? avatarController.text : null;
          mockUser.phone = phoneController.text.isNotEmpty ? phoneController.text : null;
          mockUser.address = addressController.text.isNotEmpty ? addressController.text : null;
      } else {
        // no doc — use auth info and create a doc
        nameController.text = authUser!.displayName ?? mockUser.name;
        avatarController.text = authUser!.photoURL ?? mockUser.avatar ?? '';
        phoneController.text = mockUser.phone ?? '';
        addressController.text = mockUser.address ?? '';
        try {
          await FirebaseFirestore.instance.collection('users').doc(authUser!.uid).set({
            'name': nameController.text,
            'email': authUser!.email ?? mockUser.email,
            // keep both fields for compatibility
            'avatarUrl': avatarController.text,
            'avatar': avatarController.text,
            'phone': phoneController.text,
            'address': addressController.text,
          });
        } catch (e) {
          print('Warning: could not create user doc: $e');
        }
      }
    } catch (e) {
      error = 'Impossible de charger le profil';
      // fallback to mock
      nameController.text = mockUser.name;
      avatarController.text = mockUser.avatar ?? '';
    }

    setState(() { isLoading = false; });
  }

  Future<void> _saveProfile() async {
    setState(() { isSaving = true; error = null; });
    final newName = nameController.text.trim();
    final newAvatar = avatarController.text.trim();
    final newPhone = phoneController.text.trim();
    final newAddress = addressController.text.trim();
    final user = fb_auth.FirebaseAuth.instance.currentUser;

    if (user == null) {
      // local fallback
      mockUser.name = newName;
      mockUser.avatar = newAvatar.isNotEmpty ? newAvatar : null;
      setState(() { isSaving = false; });
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docRef.set({
        'name': newName,
          // store both keys so older code that expects `avatar` still works
          // while newer code uses `avatarUrl` for clarity.
          'avatarUrl': newAvatar,
          'avatar': newAvatar,
        'phone': newPhone,
        'address': newAddress,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // update FirebaseAuth displayName if different
      try {
        if ((user.displayName ?? '') != newName) {
          await user.updateDisplayName(newName);
        }
          // Update the FirebaseAuth photoURL so other parts of the app
          // that rely on `photoURL` receive the new avatar immediately.
          if (newAvatar.isNotEmpty && (user.photoURL ?? '') != newAvatar) {
            try {
              await user.updatePhotoURL(newAvatar);
            } catch (_) {}
          }
      } catch (_) {}

      mockUser.name = newName;
      mockUser.avatar = newAvatar.isNotEmpty ? newAvatar : null;
      mockUser.phone = newPhone.isNotEmpty ? newPhone : null;
      mockUser.address = newAddress.isNotEmpty ? newAddress : null;
    } catch (e) {
      error = 'Impossible d\'enregistrer le profil';
      print('Profile save error: $e');
    }

    setState(() { isSaving = false; });
  }

  @override
  void dispose() {
    nameController.dispose();
    avatarController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayEmail = authUser?.email ?? mockUser.email;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[900]),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: Text('Mon Profil', style: TextStyle(color: Colors.grey[900])),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[900]),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        if ((avatarController.text).isNotEmpty)
                          CircleAvatar(radius: 40, backgroundImage: NetworkImage(avatarController.text))
                        else
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
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(border: InputBorder.none, hintText: 'Nom'),
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[900]),
                        ),
                        SizedBox(height: 4),
                        Text(displayEmail, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
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
                        _InfoRow('Nom', ''),
                        SizedBox(height: 12),
                        _InfoRow('Email', displayEmail),
                        SizedBox(height: 12),
                        Text('Avatar URL', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        SizedBox(height: 8),
                        TextField(
                          controller: avatarController,
                          decoration: InputDecoration(hintText: 'https://...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        ),
                        SizedBox(height: 12),
                        Text('Téléphone', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        SizedBox(height: 8),
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(hintText: '+33 6 12 34 56 78', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        ),
                        SizedBox(height: 12),
                        Text('Adresse', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        SizedBox(height: 8),
                        TextField(
                          controller: addressController,
                          decoration: InputDecoration(hintText: '123 Rue de la Paix, 75000 Paris', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        ),
                        SizedBox(height: 12),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                if (error != null) ...[
                  Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)), child: Text(error!, style: TextStyle(color: Colors.red[700]))),
                  SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSaving ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Enregistrer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: widget.onLogout,
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
