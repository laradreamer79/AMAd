import 'package:flutter_test/flutter_test.dart';

import 'package:ameen/main.dart';

void main() {
  testWidgets('Ameen app loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AmeenApp());

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Transfer'), findsWidgets);
  });
}
