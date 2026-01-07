
# Reservi

Application mobile Flutter pour la consultation et la réservation d'activités.

## Sommaire

- Description
- Fonctionnalités
- Prérequis
- Installation et configuration (Firebase)
- Exécution & build
- Tests
- Structure du projet
- Variables d'environnement
- Dépannage rapide
- Contribution
- Licence & contact

## Description

Reservi est une application mobile développée en Flutter qui permet aux utilisateurs de rechercher, consulter et réserver des activités. Le projet utilise Firebase pour l'authentification et la persistance des données, et intègre des écrans pour l'authentification, le profil, l'historique, et le paiement.

## Fonctionnalités clés

- Authentification (inscription / connexion)
- Liste d'activités et détails
- Réservation de créneaux
- Favoris et historique
- Intégration Firebase (auth, Firestore)

## Prérequis

- Flutter SDK (stable). Vérifiez avec `flutter --version`.
- Un IDE (Android Studio, VS Code) et SDK Android / iOS installés.
- Clé/config Firebase pour Android (`google-services.json`) et iOS (`GoogleService-Info.plist`) si vous utilisez les services Firebase.

## Installation

1. Cloner le dépôt :

```bash
git clone <url-du-depot>
cd Reservi
```

2. Copier les fichiers de configuration Firebase si nécessaire :

- `android/app/google-services.json` pour Android
- `ios/Runner/GoogleService-Info.plist` pour iOS

3. Installer les dépendances :

```bash
flutter pub get
```

4. Générer les fichiers de configuration Firebase (si vous utilisez `flutterfire`):

```bash
flutterfire configure
```

## Configuration spécifique (Firebase)

- Le projet contient `lib/firebase_options.dart`. Si vous regénérez la configuration, remplacez ce fichier par la nouvelle configuration fournie par `flutterfire`.
- Assurez-vous que les SHA-1/sha-256 de votre application sont ajoutés dans la console Firebase pour l'authentification Google.

## Exécution

- Lancer en mode debug sur un appareil connecté ou émulateur :

```bash
flutter run
```

- Lancer un build APK release :

```bash
flutter build apk --release
```

- Lancer un build pour iOS (depuis macOS) :

```bash
flutter build ios --release
```

## Tests

- Lancer les tests unitaires :

```bash
flutter test
```

## Structure du projet (essentielle)

- `lib/`
  - `main.dart` — point d'entrée
  - `firebase_options.dart` — configuration Firebase générée
  - `screens/` — écrans (login, home, détails, etc.)
  - `services/` — logique métier, accès Firebase/API
  - `widgets/` — composants réutilisables
  - `data/` — données mock ou modèles
- `android/`, `ios/`, `web/`, `windows/` — plateformes

## Variables d'environnement / configuration

- Si vous utilisez des clés externes, documentez-les dans un fichier `.env` ou via les variables d'environnement. Exemple :

```
FIREBASE_API_KEY=...
FIREBASE_APP_ID=...
```

Ne commitez jamais de clés secrètes dans le dépôt.

## Dépannage rapide

- Erreur de compilation Android : exécuter `flutter clean` puis `flutter pub get`.
- Problèmes Firebase : vérifier `google-services.json` et `firebase_options.dart`.
- Erreurs liées aux versions : exécuter `flutter pub outdated` puis mettre à jour les dépendances.

## Contribution

- Ouvrez une issue pour discuter des fonctionnalités importantes.
- Pour une contribution : forkez, créez une branche feature, puis envoyez une pull request avec une description claire et des tests si pertinents.

## Licence

Indiquez la licence ici (par ex. MIT). Si vous souhaitez que je crée un fichier `LICENSE` (MIT), dites-le et je l'ajouterai.

## Contact

Pour toute question, ouvrez une issue sur le dépôt ou contactez l'auteur principal.

# reservi1_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
