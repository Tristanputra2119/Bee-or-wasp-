// Basic Flutter widget test for Bee or Wasp Classifier

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('App loads and displays title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BeeOrWaspApp());

    // Verify that the app title is displayed
    expect(find.text('Bee or Wasp?'), findsOneWidget);
    
    // Verify the hero section text is displayed
    expect(find.text('Identify Insects'), findsOneWidget);
  });
}
