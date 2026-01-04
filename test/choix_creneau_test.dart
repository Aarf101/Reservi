import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservi1_flutter/screens/choix_creneau_screen.dart';
import 'package:reservi1_flutter/types.dart';

void main() {
  testWidgets('ChoixCreneauScreen shows slots from activity.availableSlots', (WidgetTester tester) async {
    final activity = Activity(
      id: 'a1',
      name: 'Test Activity',
      price: 10.0,
      location: 'Centre Test',
      image: '',
      description: '',
      type: 'Loisir',
      images: [],
      availableSlots: ['08:00', '09:30', '11:00'],
      reviews: [],
      rating: 4.5,
      coordinates: {'lat': 0.0, 'lng': 0.0},
    );

    await tester.pumpWidget(MaterialApp(
      home: ChoixCreneauScreen(
        activity: activity,
        onConfirm: (date, slot, participants) {},
        onBack: () {},
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('09:30'), findsOneWidget);
    expect(find.text('11:00'), findsOneWidget);

    // The continue button should be disabled as date and slot not selected
    final continueButton = find.widgetWithText(ElevatedButton, 'Continuer');
    expect(continueButton, findsOneWidget);
    final elevated = tester.widget<ElevatedButton>(continueButton);
    expect(elevated.onPressed, isNull);
  });
}
