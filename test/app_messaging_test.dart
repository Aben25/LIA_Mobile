import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:love_in_action/utils/app_messaging.dart';

void main() {
  group('AppMessaging Tests', () {
    testWidgets('should configure for light theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              AppMessaging.configureForTheme(context);
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should configure for dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              AppMessaging.configureForTheme(context);
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should show error message widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorMessage(
              message: 'Test error message',
              isVisible: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('should show success message widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSuccessMessage(
              message: 'Test success message',
              isVisible: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test success message'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('should show info message widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInfoMessage(
              message: 'Test info message',
              isVisible: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test info message'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('should hide message when not visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorMessage(
              message: 'Test error message',
              isVisible: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test error message'), findsNothing);
    });

    testWidgets('should hide message when empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorMessage(
              message: null,
              isVisible: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test error message'), findsNothing);
    });
  });
}
