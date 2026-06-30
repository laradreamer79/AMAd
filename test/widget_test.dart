// اختبار أساسي يتأكد من أن تطبيق Ameen يُقلَع بدون أخطاء، يعرض شاشة
// القفل أولاً، ثم بعد إدخال الرمز الصحيح يظهر شريط التنقل السفلي
// بكل تبويباته بشكل صحيح.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ameen/main.dart';
import 'package:ameen/core/widgets/animated_bottom_nav.dart';
import 'package:ameen/features/home/home_screen.dart';

void main() {
  Future<void> unlock(WidgetTester tester) async {
    await tester.pumpWidget(const AmeenApp());
    await tester.pumpAndSettle();

    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
  }

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
    },
  );

  testWidgets('Home shortcuts open bills, products, and AI', (
    WidgetTester tester,
  ) async {
    await unlock(tester);

    final billsShortcut = find.descendant(
      of: find.byType(HomeScreen),
      matching: find.text('Bills'),
    );
    await tester.tap(billsShortcut);
    await tester.pumpAndSettle();
    expect(find.text('Pay Bills'), findsOneWidget);

    final homeTab = find.descendant(
      of: find.byType(AnimatedBottomNav),
      matching: find.byIcon(Icons.home),
    );
    await tester.tap(homeTab);
    await tester.pumpAndSettle();

    final productsShortcut = find.descendant(
      of: find.byType(HomeScreen),
      matching: find.text('Products'),
    );
    await tester.tap(productsShortcut);
    await tester.pumpAndSettle();
    expect(find.text('Products Screen'), findsOneWidget);

    final aiNavItem = find.descendant(
      of: find.byType(AnimatedBottomNav),
      matching: find.byIcon(Icons.mic),
    );
    expect(aiNavItem, findsNothing);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Finance'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
  });

  testWidgets('Saved bill opens the complete payment flow', (
    WidgetTester tester,
  ) async {
    await unlock(tester);

    final billsTab = find.descendant(
      of: find.byType(AnimatedBottomNav),
      matching: find.byIcon(Icons.receipt_long),
    );
    await tester.tap(billsTab);
    await tester.pumpAndSettle();

    final electricityBill = find.text('Electricity Bill');
    await tester.ensureVisible(electricityBill);
    await tester.tap(electricityBill);
    await tester.pumpAndSettle();
    expect(find.text('Pay the bill'), findsOneWidget);

    await tester.tap(find.text('Pay the bill'));
    await tester.pumpAndSettle();
    expect(find.text('Payment Details'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
  });

  testWidgets('Account card opens the complete account-opening flow', (
    WidgetTester tester,
  ) async {
    await unlock(tester);

    await tester.tap(find.text('SA •••• •••• •••• 9012'));
    await tester.pumpAndSettle();
    expect(find.text('Open new account'), findsOneWidget);

    await tester.tap(find.text('Open new account'));
    await tester.pumpAndSettle();

    final dropdowns = find.byType(DropdownButtonFormField<String>);

    await tester.tap(dropdowns.at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saving').last);
    await tester.pumpAndSettle();

    await tester.tap(dropdowns.at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SAR').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Travel');
    await tester.tap(find.text('Confirmation'));
    await tester.pumpAndSettle();
    expect(find.text('Review account details'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    final otpFields = find.byType(TextField);
    for (var index = 0; index < 6; index += 1) {
      await tester.enterText(otpFields.at(index), '${index + 1}');
    }
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(find.text('Account Opened Successfully'), findsOneWidget);
  });
}
