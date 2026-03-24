// test/shared/widgets/no_connection_banner_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wap_app/shared/widgets/no_connection_banner.dart';

void main() {
  Widget buildSubject({required String message}) {
    return MaterialApp(
      home: Scaffold(body: NoConnectionBanner(message: message)),
    );
  }

  group('NoConnectionBanner', () {
    testWidgets('renders wifi_off icon', (tester) async {
      await tester.pumpWidget(buildSubject(message: 'Sin conexión'));

      expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
    });

    testWidgets('renders the provided message', (tester) async {
      await tester.pumpWidget(buildSubject(message: 'Sin conexión'));

      expect(find.text('Sin conexión'), findsOneWidget);
    });

    testWidgets('renders english message', (tester) async {
      await tester.pumpWidget(buildSubject(message: 'No internet connection'));

      expect(find.text('No internet connection'), findsOneWidget);
    });

    testWidgets('icon has amber color', (tester) async {
      await tester.pumpWidget(buildSubject(message: 'Sin conexión'));

      final icon = tester.widget<Icon>(find.byIcon(Icons.wifi_off_outlined));
      expect(icon.color, equals(Colors.amber.shade800));
    });

    testWidgets('message text has amber color', (tester) async {
      await tester.pumpWidget(buildSubject(message: 'Sin conexión'));

      final text = tester.widget<Text>(find.text('Sin conexión'));
      expect(text.style?.color, equals(Colors.amber.shade900));
    });

    testWidgets('lays out icon and message in a Row', (tester) async {
      await tester.pumpWidget(buildSubject(message: 'Sin conexión'));

      expect(find.byType(Row), findsOneWidget);
      // Both icon and text should be present
      expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
      expect(find.text('Sin conexión'), findsOneWidget);
    });
  });
}
