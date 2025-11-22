import 'package:flutter/material.dart';

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

  void handleSubmit() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      widget.onLogin();
    }
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
