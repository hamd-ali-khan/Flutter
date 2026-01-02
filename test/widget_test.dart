import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';
import 'package:my_app/login.dart';

void main() {
  testWidgets('App launches with login screen', (WidgetTester tester) async {
    // Build the app with Login screen
    await tester.pumpWidget(const MyApp(initialScreen: Login()));

    // Verify that Login text exists
    expect(find.text('Login'), findsOneWidget);
  });
}
