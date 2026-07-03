import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// مسار انتقال رئيسي يعتمد على CupertinoRouteTransitionMixin عشان يفعّل
/// إيماءة السحب للرجوع (swipe-to-go-back) بشكل أصلي على iOS، مع الحفاظ
/// على مدة انتقال متسقة مع هوية التطبيق.
class AppPageRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin<T> {
  AppPageRoute({required this.builder, this.routeTitle});

  final WidgetBuilder builder;
  final String? routeTitle;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  String? get title => routeTitle;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 380);
}

/// مسار انتقال "Modal" بحركة صعود من الأسفل بانحناء أنعم — مناسب
/// للمعالجات (Wizards) ونوافذ التدفق الكامل مثل إصدار بطاقة أو تحويل.
/// بدون إيماءة سحب رجوع (مقصودة، عشان ما يقفل المستخدم التدفق بالخطأ).
class AppModalRoute<T> extends PageRouteBuilder<T> {
  AppModalRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
              reverseCurve: Curves.easeInCubic,
            );

            final slide = Tween<Offset>(
              begin: const Offset(0, 0.18),
              end: Offset.zero,
            ).animate(curved);

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: slide,
                child: child,
              ),
            );
          },
        );
}
