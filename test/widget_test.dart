// اختبار أساسي يتأكد من أن تطبيق Ameen يُقلَع بدون أخطاء، يعرض شاشة
// القفل أولاً، ثم بعد إدخال الرمز الصحيح يظهر شريط التنقل السفلي
// بكل تبويباته بشكل صحيح.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ameen/main.dart';
import 'package:ameen/core/widgets/animated_bottom_nav.dart';

void main() {
  testWidgets(
      'Ameen app launches locked, unlocks with correct PIN, and shows tabs',
      (WidgetTester tester) async {
    // بناء التطبيق وتشغيل أول frame
    await tester.pumpWidget(const AmeenApp());
    await tester.pumpAndSettle();

    // عند الإقلاع، يجب أن يكون التطبيق مقفولاً (لا يوجد شريط تنقل بعد)
    expect(find.byType(AnimatedBottomNav), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);

    // إدخال الرمز الصحيح (1234) بالضغط على لوحة الأرقام
    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    // بعد إدخال الرمز الصحيح، يجب أن يظهر شريط التنقل السفلي
    expect(find.byType(AnimatedBottomNav), findsOneWidget);
    expect(find.byIcon(Icons.home), findsWidgets);

    // أيقونة credit_card تظهر في تبويب Cards وأيضًا في
    // كرت "Cards" بصفحة Home (Quick Actions)
    expect(find.byIcon(Icons.credit_card), findsAtLeastNWidgets(2));

    // التأكد من أن تبويب Cards يفتح شاشة البطاقات عند الضغط عليه
    final cardsTab = find.descendant(
      of: find.byType(AnimatedBottomNav),
      matching: find.byIcon(Icons.credit_card),
    );
    await tester.tap(cardsTab);
    await tester.pumpAndSettle();

    // بعد الضغط، يجب أن يظهر زر "بطاقة جديدة" بشاشة البطاقات
    expect(find.byIcon(Icons.add), findsWidgets);
  });
}
