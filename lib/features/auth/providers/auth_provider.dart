import 'package:flutter/material.dart';

/// يدير حالة قفل التطبيق عبر رمز PIN مكوّن من 4 أرقام (Mock بالكامل).
///
/// التطبيق يبدأ مقفولاً دائمًا عند الإقلاع (isLocked = true)، ولا يُفتح
/// إلا بإدخال الرمز الصحيح. هذا يحاكي سلوك تطبيقات البنوك الحقيقية التي
/// تطلب رمزًا أو بصمة في كل مرة يُفتح فيها التطبيق.
class AuthProvider extends ChangeNotifier {
  static const String _correctPin = '1234';
  static const int pinLength = 4;

  bool _isLocked = true;
  bool get isLocked => _isLocked;

  List<String> enteredDigits = List.filled(pinLength, '');
  String? pinError;
  bool isVerifying = false;

  int _failedAttempts = 0;
  int get failedAttempts => _failedAttempts;

  void enterDigit(int index, String value) {
    enteredDigits[index] = value;
    pinError = null;
    notifyListeners();
  }

  void appendDigit(String digit) {
    final emptyIndex = enteredDigits.indexWhere((d) => d.isEmpty);
    if (emptyIndex == -1) return;
    enteredDigits[emptyIndex] = digit;
    pinError = null;
    notifyListeners();

    if (enteredDigits.every((d) => d.isNotEmpty)) {
      _verifyPin();
    }
  }

  void removeLastDigit() {
    final lastFilledIndex = enteredDigits.lastIndexWhere((d) => d.isNotEmpty);
    if (lastFilledIndex == -1) return;
    enteredDigits[lastFilledIndex] = '';
    pinError = null;
    notifyListeners();
  }

  Future<void> _verifyPin() async {
    isVerifying = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400)); // محاكاة تحقق

    final entered = enteredDigits.join();
    if (entered == _correctPin) {
      _isLocked = false;
      _failedAttempts = 0;
      pinError = null;
    } else {
      _failedAttempts++;
      pinError = 'incorrect_pin';
      enteredDigits = List.filled(pinLength, '');
    }

    isVerifying = false;
    notifyListeners();
  }

  /// يُستخدم عند إغلاق التطبيق للخلفية أو تسجيل الخروج اليدوي
  void lock() {
    _isLocked = true;
    enteredDigits = List.filled(pinLength, '');
    pinError = null;
    notifyListeners();
  }
}
