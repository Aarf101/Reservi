import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/mock_data.dart';


class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignupClick;
  const LoginScreen({Key? key, required this.onLogin, required this.onSignupClick}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;

  Future<void> handleSubmit() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;

    // Try Firebase Auth first. If the credentials are invalid (user-not-found, wrong-password)
    // show an error and do NOT fall back to mock user. For other errors (e.g., Firebase not initialized)
    // fall back to mock user to preserve offline/dev flow.
    try {
      final auth = FirebaseAuth.instance;
      final cred = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // load user profile from Firestore if exists; create if missing
      try {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(cred.user!.uid);
        final userDoc = await userDocRef.get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          mockUser.name = data['name'] ?? mockUser.name;
          mockUser.email = data['email'] ?? mockUser.email;
          mockUser.favoriteIds.clear();
          if (data['favoriteIds'] is List) {
            mockUser.favoriteIds.addAll(List<String>.from(data['favoriteIds']));
          }
          if (!data.containsKey('favoriteIds')) {
            try {
              await userDocRef.update({'favoriteIds': []});
            } catch (_) {}
          }
        } else {
          final displayName = cred.user!.displayName ?? emailController.text.split('@').first;
          final email = cred.user!.email ?? emailController.text;
          try {
            await userDocRef.set({
              'name': displayName,
              'email': email,
              'favoriteIds': [],
            });
            mockUser.name = displayName;
            mockUser.email = email;
            mockUser.favoriteIds.clear();
          } catch (e) {
            print('Warning: could not create Firestore user doc on login: $e');
            mockUser.email = email;
            mockUser.name = displayName;
          }
        }
      } catch (e) {
        print('Warning: could not load Firestore user doc: $e');
        mockUser.email = emailController.text;
        if (mockUser.name.isEmpty) mockUser.name = emailController.text.split('@').first;
      }

      widget.onLogin();
      return;
    } on FirebaseAuthException catch (e) {
      // Deny login for explicit auth errors (invalid credentials / non-existent user)
      setState(() => error = e.message ?? 'Identifiants invalides');
      return;
    } catch (e) {
      // Non-auth errors (e.g., Firebase not configured) fall back to mock user
      print('Firebase login failed or not configured: $e — falling back to mock user.');
    }

    // Fallback: update mock user in-memory
    mockUser.email = emailController.text;
    if (mockUser.name.isEmpty) {
      mockUser.name = emailController.text.split('@').first;
    }
    widget.onLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F4FF), Color(0xFFF3E8FF), Color(0xFFFCE7F3)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF9333EA)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: Icon(Icons.star, color: Colors.white, size: 32),
                      ),
                      SizedBox(width: 12),
                      Text('Reservi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    ],
                  ),
                  SizedBox(height: 40),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Connexion', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                          SizedBox(height: 4),
                          Text('Connectez-vous à votre compte', style: TextStyle(color: Colors.grey[600])),
                          SizedBox(height: 16),
                          if (error != null) ...[
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                              child: Text(error!, style: TextStyle(color: Colors.red[700])),
                            ),
                            SizedBox(height: 12),
                          ],
                          SizedBox(height: 24),
                          Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                          SizedBox(height: 8),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: 'votre@email.com',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Mot de passe', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                          SizedBox(height: 8),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Se connecter', style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                          SizedBox(height: 24),
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: widget.onSignupClick,
                                  child: Text('Créer un compte', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(height: 12),
                                Text('Mot de passe oublié ?', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        ],
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
