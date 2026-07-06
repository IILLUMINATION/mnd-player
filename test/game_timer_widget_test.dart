import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnd_player/widgets/game_timer_widget.dart';

void main() {
  group('GameTimerWidget', () {
    testWidgets('renders correct time format for 60s', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const GameTimerWidget(
              remainingSeconds: 60,
              totalSeconds: 120,
            ),
          ),
        ),
      );

      expect(find.text('1:00'), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('renders correct time format for 90s', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const GameTimerWidget(
              remainingSeconds: 90,
              totalSeconds: 180,
            ),
          ),
        ),
      );

      expect(find.text('1:30'), findsOneWidget);
    });

    testWidgets('renders correct time format for 0s', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const GameTimerWidget(
              remainingSeconds: 0,
              totalSeconds: 120,
            ),
          ),
        ),
      );

      expect(find.text('0:00'), findsOneWidget);
    });

    testWidgets('renders progress bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const GameTimerWidget(
              remainingSeconds: 30,
              totalSeconds: 120,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders without crashing for zero total', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const GameTimerWidget(
              remainingSeconds: 10,
              totalSeconds: 0,
            ),
          ),
        ),
      );

      expect(find.text('0:10'), findsOneWidget);
    });
  });
}
