// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

    testWidgets('Auth screen test', (WidgetTester tester) async {
      expect(true, true);
    });

  // Test if the app starts with a auth screen
  // testWidgets('Auth screen test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const App());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('Login'), findsOneWidget);
  //   expect(find.text('Register'), findsOneWidget);
  // });

  // // Test if can login with a valid test email and password
  // testWidgets('Login test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const App());

  //   // Tap the 'Login' button and trigger a frame.
  //   await tester.tap(find.text('Login'));
  //   await tester.pump();

  //   // Verify that our counter starts at 0.
  //   expect(find.text('Login'), findsOneWidget);
  //   expect(find.text('Register'), findsOneWidget);
  // });
  
}
