import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'services/messaging_service.dart';
import 'firebase_options.dart';
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
import 'data/mock_data.dart';
import 'types.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize messaging (FCM) when Firebase is available
    await MessagingService.init();
  } catch (e) {
    // If Firebase isn't configured for this platform or initialization fails,
    // continue in mock mode. To fully enable Firebase, run `flutterfire configure`
    // or add platform config files (`google-services.json` / `GoogleService-Info.plist`).
    print('Warning: Firebase.initializeApp() failed — running in mock mode. Error: $e');
  }

  runApp(Reservi1App());
}

class Reservi1App extends StatefulWidget {
  @override
  _Reservi1AppState createState() => _Reservi1AppState();
}

class _Reservi1AppState extends State<Reservi1App> {
  String currentScreen = 'splash';
    // Navigation state to carry selected booking data
    Activity? selectedActivity;
    DateTime? selectedDate;
    String? selectedTime;
    int selectedParticipants = 1;

  void setScreen(String screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth changes to register FCM token for signed-in users
    fb_auth.FirebaseAuth.instance.authStateChanges().listen((u) {
      if (u != null) {
        MessagingService.registerTokenForUser(u.uid).catchError((e) => print('Failed register token: $e'));
      }
    });
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
            onDetails: (activity) {
              selectedActivity = activity;
              setScreen('details');
            },
            onHistorique: () => setScreen('historique'),
            onProfil: () => setScreen('profil'),
            onFavoris: () => setScreen('favoris'),
          );
        break;
      case 'details':
          screenWidget = ActivityDetailsScreen(
            onBack: () => setScreen('home'),
            onReserve: () => setScreen('choix-creneau'),
            activity: selectedActivity ?? mockActivities[0],
          );
        break;
      case 'choix-creneau':
        screenWidget = ChoixCreneauScreen(
          activity: selectedActivity ?? mockActivities[0],
          onConfirm: (date, time, participants) {
            selectedDate = date;
            selectedTime = time;
            selectedParticipants = participants;
            setScreen('confirmation');
          },
          onBack: () => setScreen('details'),
        );
        break;
      case 'confirmation':
        screenWidget = ConfirmationScreen(
          activity: selectedActivity ?? mockActivities[0],
          date: selectedDate ?? DateTime.now(),
          time: selectedTime ?? '',
          participants: selectedParticipants,
          onSuccess: () => setScreen('payment'),
          onBack: () => setScreen('choix-creneau'),
        );
        break;
      case 'payment':
        screenWidget = PaymentScreen(
          activity: selectedActivity ?? mockActivities[0],
          date: selectedDate ?? DateTime.now(),
          time: selectedTime ?? '',
          participants: selectedParticipants,
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
          onBack: () => setScreen('home'),
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
