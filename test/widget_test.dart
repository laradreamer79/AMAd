import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ameen/main.dart';

void main() {
  testWidgets('Ameen app logs in from the demo credentials', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AmeenApp());

    expect(find.text('Welcome to Ameen'), findsOneWidget);

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('OTP Verification'), findsOneWidget);
    expect(find.text('Demo OTP: 123456.'), findsOneWidget);

    final otpFields = find.byType(TextField);
    for (var index = 0; index < 6; index += 1) {
      await tester.enterText(otpFields.at(index), '${index + 1}');
      await tester.pump();
    }

    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Transfer'), findsWidgets);
  });
}
