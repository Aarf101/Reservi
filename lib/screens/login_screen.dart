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

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;
  bool isLoading = false;

  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _cardFadeAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(begin: Offset(0, -0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOut));

    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeIn));

    _headerAnimationController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      final cred = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

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
      setState(() {
        error = e.message ?? 'Identifiants invalides';
        isLoading = false;
      });
      return;
    } catch (e) {
      print('Firebase login failed or not configured: $e — falling back to mock user.');
    }

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
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  // Animated header slide-in
                  SlideTransition(
                    position: _headerSlideAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              )
                            ],
                          ),
                          child: Icon(Icons.star, color: Color(0xFF9333EA), size: 32),
                        ),
                        SizedBox(width: 12),
                        Text('Reservi', 
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  // Animated card fade-in
                  FadeTransition(
                    opacity: _cardFadeAnimation,
                    child: Card(
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
                            _AnimatedTextField(
                              controller: emailController,
                              hintText: 'votre@email.com',
                              enabled: !isLoading,
                            ),
                            SizedBox(height: 16),
                            Text('Mot de passe', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                            SizedBox(height: 8),
                            _AnimatedTextField(
                              controller: passwordController,
                              hintText: '••••••••',
                              obscureText: true,
                              enabled: !isLoading,
                            ),
                            SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: _AnimatedButton(
                                onPressed: isLoading ? null : handleSubmit,
                                isLoading: isLoading,
                              ),
                            ),
                            SizedBox(height: 24),
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: isLoading ? null : widget.onSignupClick,
                                    child: Text('Créer un compte', 
                                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
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

// Animated text field with focus animation
class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool enabled;

  const _AnimatedTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.enabled = true,
  });

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField> with SingleTickerProviderStateMixin {
  late AnimationController _focusAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _focusAnimationController, curve: Curves.easeOut),
    );
    _colorAnimation = ColorTween(
      begin: Colors.grey[300],
      end: Colors.blue,
    ).animate(CurvedAnimation(parent: _focusAnimationController, curve: Curves.easeOut));

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _focusAnimationController.forward();
      } else {
        _focusAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusAnimationController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: TextField(
        controller: widget.controller,
        focusNode: focusNode,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }
}

// Animated login button with loading state
class _AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _AnimatedButton({
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _bounceAnimationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _bounceAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceAnimationController.dispose();
    super.dispose();
  }

  void _onPressed() {
    _bounceAnimationController.forward(from: 0.0);
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : _onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: widget.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text('Se connecter', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
