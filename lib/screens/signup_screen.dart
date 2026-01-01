import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/mock_data.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onSignup;
  final VoidCallback onBackClick;
  const SignupScreen({Key? key, required this.onSignup, required this.onBackClick}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? error;
  bool isLoading = false;

  late AnimationController _headerAnimController;
  late AnimationController _cardAnimController;
  late AnimationController _fieldAnimController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _cardFadeAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _cardAnimController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fieldAnimController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _headerSlideAnimation = Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut),
    );

    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimController, curve: Curves.easeIn),
    );

    _headerAnimController.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _cardAnimController.forward());
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _cardAnimController.dispose();
    _fieldAnimController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    setState(() => error = null);

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => error = 'Veuillez remplir tous les champs');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => error = 'Email invalide');
      return;
    }
    if (password.length < 6) {
      setState(() => error = 'Le mot de passe doit contenir au moins 6 caractères');
      return;
    }
    if (password != confirm) {
      setState(() => error = 'Les mots de passe ne correspondent pas');
      return;
    }

    setState(() => isLoading = true);

    // Require Firebase Auth signup: if Auth fails, show error and do NOT fall back to mock user.
    try {
      final auth = FirebaseAuth.instance;
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // attempt to create user document in Firestore (non-fatal)
      try {
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'name': name,
          'email': email,
          'favoriteIds': [],
        });
      } catch (e) {
        print('Warning: could not create Firestore user doc: $e');
      }

      // update local mockUser for UI convenience
      mockUser.name = name;
      mockUser.email = email;

      widget.onSignup();
      return;
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'Erreur lors de la création du compte';
        isLoading = false;
      });
      return;
    } catch (e) {
      setState(() {
        error = 'Erreur inattendue: $e';
        isLoading = false;
      });
      return;
    }
  }

  bool _isValidEmail(String value) {
    const pattern = r'^.+@[^\.].*\.[a-z]{2,}$';
    return RegExp(pattern, caseSensitive: false).hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Animated header
                  SlideTransition(
                    position: _headerSlideAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: const Icon(Icons.star, color: Color(0xFF9333EA), size: 32),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Reservi',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Animated card with form
                  FadeTransition(
                    opacity: _cardFadeAnimation,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header section
                            Row(
                              children: [
                                if (!isLoading)
                                  GestureDetector(
                                    onTap: widget.onBackClick,
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.arrow_back, color: Colors.grey[700]),
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 40),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Créer un compte',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Text(
                                      'Rejoignez notre communauté',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Error message
                            if (error != null) ...[
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFECACA), width: 2),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        error!,
                                        style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                            // Name field
                            _buildLabel('Nom complet'),
                            const SizedBox(height: 8),
                            _AnimatedTextField(
                              controller: nameController,
                              hintText: 'Votre nom',
                              prefixIcon: Icons.person_outline,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 18),
                            // Email field
                            _buildLabel('Email'),
                            const SizedBox(height: 8),
                            _AnimatedTextField(
                              controller: emailController,
                              hintText: 'votre@email.com',
                              prefixIcon: Icons.email_outlined,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 18),
                            // Password field
                            _buildLabel('Mot de passe'),
                            const SizedBox(height: 8),
                            _AnimatedTextField(
                              controller: passwordController,
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 18),
                            // Confirm password field
                            _buildLabel('Confirmer mot de passe'),
                            const SizedBox(height: 8),
                            _AnimatedTextField(
                              controller: confirmPasswordController,
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 28),
                            // Submit button
                            _AnimatedButton(
                              onPressed: isLoading ? null : handleSubmit,
                              isLoading: isLoading,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
        fontSize: 14,
      ),
    );
  }
}

// Animated text field widget
class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final bool enabled;

  const _AnimatedTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.enabled = true,
  });

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.grey[300],
      end: const Color(0xFF2563EB),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange(bool focused) {
    setState(() => isFocused = focused);
    if (focused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: _onFocusChange,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return TextField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              enabled: widget.enabled,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: Icon(widget.prefixIcon, color: isFocused ? const Color(0xFF2563EB) : Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                ),
                filled: true,
                fillColor: isFocused ? const Color(0xFF2563EB).withOpacity(0.03) : Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Animated button widget
class _AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _AnimatedButton({
    required this.onPressed,
    required this.isLoading,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      _bounceController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _bounceAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: widget.isLoading
                ? LinearGradient(colors: [Colors.grey[400]!, Colors.grey[500]!])
                : const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.isLoading ? Colors.grey.withOpacity(0.3) : const Color(0xFF2563EB).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Créer un compte',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
