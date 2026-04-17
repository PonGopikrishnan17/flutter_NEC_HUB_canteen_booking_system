import 'package:canteen_booking_app/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('landing screen renders NEC HUB', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LandingScreen(),
      ),
    );

    expect(find.text('NEC HUB'), findsOneWidget);
    expect(find.text('Start Ordering'), findsOneWidget);
  });
}
