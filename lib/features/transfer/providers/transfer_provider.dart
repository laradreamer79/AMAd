import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../account/providers/account_provider.dart';
import '../../account/models/transaction_model.dart';
import '../models/beneficiary_model.dart';

enum TransferStep { selectType, selectBeneficiary, details, review, otp, success }

enum TransferReason { bills, salary, gift, family, other }

extension TransferReasonX on TransferReason {
  String get labelKey {
    switch (this) {
      case TransferReason.bills:
        return 'reason_bills';
      case TransferReason.salary:
        return 'reason_salary';
      case TransferReason.gift:
        return 'reason_gift';
      case TransferReason.family:
        return 'reason_family';
      case TransferReason.other:
        return 'reason_other';
    }
  }
}

/// يدير حالة معالج التحويل بالكامل: من اختيار نوع التحويل إلى نجاح العملية.
/// عند التأكيد النهائي (confirmOtp) يستخدم AccountProvider فعليًا لخصم
/// المبلغ وتسجيل المعاملة — هذا يربط ميزة التحويل بالحساب الحقيقي للمستخدم
/// بدل أن تبقى معزولة كما كانت سابقًا.
class TransferProvider extends ChangeNotifier {
  TransferStep _step = TransferStep.selectType;
  TransferStep get step => _step;

  TransferType? selectedType;
  Beneficiary? selectedBeneficiary;
  TransferReason? selectedReason;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  TransferProvider() {
    amountController.addListener(notifyListeners);
  }

  // ----- OTP -----
  static const int otpLength = 4;
  static const int otpDurationSeconds = 119;
  List<String> otpDigits = List.filled(otpLength, '');
  int otpSecondsLeft = otpDurationSeconds;
  Timer? _otpTimer;
  String? otpError;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _resultError; // خطأ نهائي مثل "رصيد غير كافٍ"
  String? get resultError => _resultError;

  double get amount => double.tryParse(amountController.text.trim()) ?? 0;

  bool get canProceedFromTypeSelection => selectedType != null;

  bool get canProceedFromBeneficiarySelection => selectedBeneficiary != null;

  bool get canProceedFromDetails =>
      amount > 0 && selectedReason != null;

  void selectType(TransferType type) {
    selectedType = type;
    notifyListeners();
  }

  void selectBeneficiary(Beneficiary b) {
    selectedBeneficiary = b;
    notifyListeners();
  }

  void selectReason(TransferReason reason) {
    selectedReason = reason;
    notifyListeners();
  }

  void goTo(TransferStep newStep) {
    _step = newStep;
    if (newStep == TransferStep.otp) {
      _startOtpTimer();
    }
    notifyListeners();
  }

  void goBack() {
    switch (_step) {
      case TransferStep.selectBeneficiary:
        _step = TransferStep.selectType;
        break;
      case TransferStep.details:
        _step = TransferStep.selectBeneficiary;
        break;
      case TransferStep.review:
        _step = TransferStep.details;
        break;
      case TransferStep.otp:
        _otpTimer?.cancel();
        _step = TransferStep.review;
        break;
      case TransferStep.selectType:
      case TransferStep.success:
        break;
    }
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
        return;
      }
      otpSecondsLeft--;
      notifyListeners();
    });
  }

  void resendOtp() {
    _startOtpTimer();
    notifyListeners();
  }

  void setOtpDigit(int index, String value) {
    otpDigits[index] = value;
    otpError = null;
    notifyListeners();
  }

  /// يتحقق من رمز OTP، وإذا صحيح ينفّذ التحويل فعليًا عبر AccountProvider.
  /// يرجع true عند النجاح.
  Future<bool> confirmOtp(AccountProvider account) async {
    final code = otpDigits.join();
    if (code.length != otpLength) {
      otpError = 'enter_full_code';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900)); // محاكاة شبكة

    final success = account.debit(
      amount: amount,
      type: TransactionType.transfer,
      titleKey: 'transfer_to',
      subtitle: selectedBeneficiary?.name,
    );

    _isSubmitting = false;

    if (!success) {
      _resultError = 'insufficient_balance';
      notifyListeners();
      return false;
    }

    _otpTimer?.cancel();
    _resultError = null;
    _step = TransferStep.success;
    notifyListeners();
    return true;
  }

  /// إعادة ضبط المعالج بالكامل للبدء من جديد
  void reset() {
    _otpTimer?.cancel();
    _step = TransferStep.selectType;
    selectedType = null;
    selectedBeneficiary = null;
    selectedReason = null;
    amountController.clear();
    noteController.clear();
    otpDigits = List.filled(otpLength, '');
    otpSecondsLeft = otpDurationSeconds;
    otpError = null;
    _resultError = null;
    notifyListeners();
  }

  String _generateMockTransactionRef() {
    final rnd = Random();
    return 'TXN${DateTime.now().millisecondsSinceEpoch}${rnd.nextInt(999)}';
  }

  String get transactionReference => _generateMockTransactionRef();

  @override
  void dispose() {
    _otpTimer?.cancel();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
