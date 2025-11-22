import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onSignup;
  final VoidCallback onBackClick;
  const SignupScreen({Key? key, required this.onSignup, required this.onBackClick}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? error;

  void handleSubmit() {
    setState(() => error = null);
    if (passwordController.text != confirmPasswordController.text) {
      setState(() => error = 'Les mots de passe ne correspondent pas');
      return;
    }
    if (nameController.text.isNotEmpty && emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      widget.onSignup();
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
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: widget.onBackClick,
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Créer un compte', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                                  Text('Inscrivez-vous pour commencer', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          if (error != null) ...[
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                              child: Text(error!, style: TextStyle(color: Colors.red[700])),
                            ),
                            SizedBox(height: 16),
                          ],
                          Text('Nom', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                          SizedBox(height: 8),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Votre nom',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          SizedBox(height: 16),
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
                          SizedBox(height: 16),
                          Text('Confirmer mot de passe', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                          SizedBox(height: 8),
                          TextField(
                            controller: confirmPasswordController,
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
                              child: Text('Créer un compte', style: TextStyle(color: Colors.white, fontSize: 16)),
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
