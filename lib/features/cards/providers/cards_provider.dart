import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/card_type_option.dart';

enum IssueCardStep { selectType, details, review, otp, success }

class CardsProvider extends ChangeNotifier {
  // ----- البطاقات المصدرة فعليًا (state محلي) -----
  final List<IssuedCard> _issuedCards = [];
  List<IssuedCard> get issuedCards => List.unmodifiable(_issuedCards);

  // ----- حالة معالج الإصدار (Wizard) -----
  IssueCardStep _step = IssueCardStep.selectType;
  IssueCardStep get step => _step;

  CardTypeOption _selectedType = CardTypeOption.all.first;
  CardTypeOption get selectedType => _selectedType;

  final TextEditingController holderNameController = TextEditingController();

  CardsProvider() {
    holderNameController.addListener(notifyListeners);
  }

  bool _agreedToTerms = false;
  bool get agreedToTerms => _agreedToTerms;

  // ----- OTP -----
  static const int otpLength = 4;
  static const int otpDurationSeconds = 119;
  List<String> otpDigits = List.filled(otpLength, '');
  int otpSecondsLeft = otpDurationSeconds;
  Timer? _otpTimer;
  String? otpError;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  IssuedCard? _lastIssuedCard;
  IssuedCard? get lastIssuedCard => _lastIssuedCard;

  void selectType(CardTypeOption type) {
    _selectedType = type;
    notifyListeners();
  }

  void toggleAgreement() {
    _agreedToTerms = !_agreedToTerms;
    notifyListeners();
  }

  void goTo(IssueCardStep newStep) {
    _step = newStep;
    if (newStep == IssueCardStep.otp) {
      _startOtpTimer();
    }
    notifyListeners();
  }

  void goBack() {
    switch (_step) {
      case IssueCardStep.details:
        _step = IssueCardStep.selectType;
        break;
      case IssueCardStep.review:
        _step = IssueCardStep.details;
        break;
      case IssueCardStep.otp:
        _otpTimer?.cancel();
        _step = IssueCardStep.review;
        break;
      case IssueCardStep.selectType:
      case IssueCardStep.success:
        break;
    }
    notifyListeners();
  }

  bool get canProceedFromDetails => holderNameController.text.trim().isNotEmpty;

  void setOtpDigit(int index, String value) {
    if (index < 0 || index >= otpLength) return;
    otpDigits[index] = value;
    otpError = null;
    notifyListeners();
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    otpSecondsLeft = otpDurationSeconds;
    otpDigits = List.filled(otpLength, '');
    otpError = null;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpSecondsLeft <= 0) {
        timer.cancel();
      } else {
        otpSecondsLeft--;
      }
      notifyListeners();
    });
  }

  void resendOtp() {
    _startOtpTimer();
  }

  Future<bool> confirmOtp() async {
    final code = otpDigits.join();
    if (code.length != otpLength) {
      otpError = 'يرجى إدخال الرمز كاملاً';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    // محاكاة استدعاء API لإصدار البطاقة
    await Future.delayed(const Duration(milliseconds: 900));

    _isSubmitting = false;
    _otpTimer?.cancel();

    final card = _buildIssuedCard();
    _issuedCards.add(card);
    _lastIssuedCard = card;
    _step = IssueCardStep.success;
    notifyListeners();
    return true;
  }

  IssuedCard _buildIssuedCard() {
    final rnd = Random();
    final last4 = (1000 + rnd.nextInt(9000)).toString();
    final now = DateTime.now();
    final expiry =
        '${now.month.toString().padLeft(2, '0')}/${(now.year + 4) % 100}';

    // توليد رقم بطاقة كامل Mock (16 رقم) بحيث ينتهي بنفس last4
    final group1 = (1000 + rnd.nextInt(9000)).toString();
    final group2 = (1000 + rnd.nextInt(9000)).toString();
    final group3 = (1000 + rnd.nextInt(9000)).toString();
    final fullNumber = '$group1 $group2 $group3 $last4';

    final cvv = (100 + rnd.nextInt(900)).toString();

    return IssuedCard(
      id: now.microsecondsSinceEpoch.toString(),
      type: _selectedType,
      holderName: holderNameController.text.trim(),
      fullNumber: fullNumber,
      maskedNumber: '•••• •••• •••• $last4',
      cvv: cvv,
      expiry: expiry,
      issuedAt: now,
      nickname: _selectedType.nameKey,
      isNicknameCustom: false,
    );
  }

  void toggleFreeze(String cardId) {
    final card = _issuedCards.firstWhere((c) => c.id == cardId);
    card.isFrozen = !card.isFrozen;
    notifyListeners();
  }

  /// إيجاد بطاقة مُصدرة عبر الـ id — تُستخدم بشاشة تفاصيل البطاقة
  IssuedCard? findById(String cardId) {
    try {
      return _issuedCards.firstWhere((c) => c.id == cardId);
    } catch (_) {
      return null;
    }
  }

  /// تحديث الاسم المخصص (nickname) لبطاقة معيّنة
  void updateNickname(String cardId, String newNickname) {
    final card = _issuedCards.firstWhere((c) => c.id == cardId);
    final trimmed = newNickname.trim();
    if (trimmed.isEmpty) return; // لا نسمح بإفراغ الاسم بالكامل
    card.nickname = trimmed;
    card.isNicknameCustom = true;
    notifyListeners();
  }

  /// تحديث حد الإنفاق الشهري لبطاقة معيّنة (Mock)
  void updateSpendingLimit(String cardId, double newLimit) {
    if (newLimit <= 0) return;
    final card = _issuedCards.firstWhere((c) => c.id == cardId);
    card.spendingLimit = newLimit;
    notifyListeners();
  }

  /// تفعيل/تعطيل الدفع الإلكتروني لبطاقة معيّنة (Mock)
  void toggleOnlinePayment(String cardId) {
    final card = _issuedCards.firstWhere((c) => c.id == cardId);
    card.isOnlinePaymentEnabled = !card.isOnlinePaymentEnabled;
    notifyListeners();
  }

  /// إعادة ضبط المعالج بالكامل للبدء من جديد
  void reset() {
    _otpTimer?.cancel();
    _step = IssueCardStep.selectType;
    _selectedType = CardTypeOption.all.first;
    holderNameController.clear();
    _agreedToTerms = false;
    otpDigits = List.filled(otpLength, '');
    otpSecondsLeft = otpDurationSeconds;
    otpError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    holderNameController.dispose();
    super.dispose();
  }
}
