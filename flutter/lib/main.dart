import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/activity_details_screen.dart';
import 'screens/choix_creneau_screen.dart';
import 'screens/confirmation_screen.dart';
import 'screens/success_screen.dart';
import 'screens/favoris_screen.dart';
import 'screens/historique_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/profil_screen.dart';

void main() {
  runApp(Reservi1App());
}

class Reservi1App extends StatefulWidget {
  @override
  _Reservi1AppState createState() => _Reservi1AppState();
}

class _Reservi1AppState extends State<Reservi1App> {
  String currentScreen = 'splash';

  void setScreen(String screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screenWidget;
    switch (currentScreen) {
      case 'splash':
        screenWidget = SplashScreen(onContinue: () => setScreen('login'));
        break;
      case 'login':
        screenWidget = LoginScreen(
          onLogin: () => setScreen('home'),
          onSignupClick: () => setScreen('signup'),
        );
        break;
      case 'signup':
        screenWidget = SignupScreen(
          onSignup: () => setScreen('home'),
          onBackClick: () => setScreen('login'),
        );
        break;
      case 'home':
        screenWidget = HomeScreen(
          onDetails: () => setScreen('details'),
          onHistorique: () => setScreen('historique'),
          onProfil: () => setScreen('profil'),
          onFavoris: () => setScreen('favoris'),
        );
        break;
      case 'details':
        screenWidget = ActivityDetailsScreen(
          onBack: () => setScreen('home'),
          onReserve: () => setScreen('choix-creneau'),
        );
        break;
      case 'choix-creneau':
        screenWidget = ChoixCreneauScreen(
          onConfirm: () => setScreen('confirmation'),
          onBack: () => setScreen('details'),
        );
        break;
      case 'confirmation':
        screenWidget = ConfirmationScreen(
          onSuccess: () => setScreen('payment'),
          onBack: () => setScreen('choix-creneau'),
        );
        break;
      case 'payment':
        screenWidget = PaymentScreen(
          onSuccess: () => setScreen('success'),
          onBack: () => setScreen('confirmation'),
        );
        break;
      case 'success':
        screenWidget = SuccessScreen(onHome: () => setScreen('home'));
        break;
      case 'favoris':
        screenWidget = FavorisScreen(
          onBack: () => setScreen('home'),
          onDetails: () => setScreen('details'),
        );
        break;
      case 'historique':
        screenWidget = HistoriqueScreen(onBack: () => setScreen('home'));
        break;
      case 'profil':
        screenWidget = ProfilScreen(
          onLogout: () => setScreen('login'),
        );
        break;
      default:
        screenWidget = SplashScreen(onContinue: () => setScreen('login'));
    }
    return MaterialApp(
      title: 'Reservi1',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: screenWidget,
    );
  }
}
