import 'package:flutter/material.dart';

/// مسار انتقال مخصص يجمع بين الانزلاق الخفيف (Slide) والتلاشي (Fade)
/// بمنحنى حركة سلس، بدل الانتقال الافتراضي الجاف لـ MaterialPageRoute.
/// يُستخدم بكل أماكن التنقل الرئيسية بالتطبيق لإحساس أكثر احترافية.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final slide = Tween<Offset>(
              begin: const Offset(0, 0.06),
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

/// مسار انتقال "Modal" بحركة صعود من الأسفل بانحناء أنعم — مناسب
/// للمعالجات (Wizards) ونوافذ التدفق الكامل مثل إصدار بطاقة أو تحويل.
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
