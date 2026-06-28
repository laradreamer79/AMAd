import 'package:flutter/material.dart';
import 'app_strings.dart';

enum AppLang { en, ar }

class LangProvider extends ChangeNotifier {
  AppLang _lang = AppLang.en;

  AppLang get lang => _lang;
  String get code => _lang == AppLang.ar ? 'ar' : 'en';
  bool get isRTL => _lang == AppLang.ar;
  TextDirection get direction => isRTL ? TextDirection.rtl : TextDirection.ltr;
  Locale get locale => Locale(code);

  String t(String key, [Map<String, String>? args]) {
    return AppStrings.get(code, key, args);
  }

  void toggle() {
    _lang = _lang == AppLang.en ? AppLang.ar : AppLang.en;
    notifyListeners();
  }

  void setLang(AppLang newLang) {
    if (_lang == newLang) return;
    _lang = newLang;
    notifyListeners();
  }
}
