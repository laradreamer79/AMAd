import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum CardCategory { visaSignature, visaPlatinum, mada }

class CardTypeOption {
  final CardCategory category;
  final String nameKey; // مفتاح ترجمة لاسم البطاقة
  final String descriptionKey; // مفتاح ترجمة لوصف البطاقة
  final String networkLabel; // VISA / mada — لا يُترجم (اسم شبكة عالمي)
  final List<Color> gradient;
  final double annualFee;

  const CardTypeOption({
    required this.category,
    required this.nameKey,
    required this.descriptionKey,
    required this.networkLabel,
    required this.gradient,
    required this.annualFee,
  });

  static const List<CardTypeOption> all = [
    CardTypeOption(
      category: CardCategory.visaSignature,
      nameKey: 'visa_signature_name',
      descriptionKey: 'visa_signature_desc',
      networkLabel: 'VISA Signature',
      gradient: AppColors.visaSignatureGradient,
      annualFee: 500,
    ),
    CardTypeOption(
      category: CardCategory.visaPlatinum,
      nameKey: 'visa_platinum_name',
      descriptionKey: 'visa_platinum_desc',
      networkLabel: 'VISA Platinum',
      gradient: AppColors.visaPlatinumGradient,
      annualFee: 300,
    ),
    CardTypeOption(
      category: CardCategory.mada,
      nameKey: 'mada_name',
      descriptionKey: 'mada_desc',
      networkLabel: 'mada',
      gradient: AppColors.madaGradient,
      annualFee: 0,
    ),
  ];
}

/// البطاقة بعد إصدارها فعليًا وتخزينها في الـ state
class IssuedCard {
  final String id;
  final CardTypeOption type;
  final String holderName;
  final String fullNumber; // الرقم الكامل (Mock) — يُستخدم عند "إظهار الرقم"
  final String maskedNumber; // نسخة مموّهة تُعرض دائمًا بالقوائم
  final String cvv; // Mock فقط — لا يُستخدم لأي عملية فعلية
  final String expiry;
  final DateTime issuedAt;
  bool isFrozen;
  String nickname; // مفتاح ترجمة افتراضيًا، أو نص مخصص كتبه المستخدم
  bool isNicknameCustom; // false = nickname هو مفتاح ترجمة، true = نص حر
  double spendingLimit; // حد إنفاق شهري Mock
  bool isOnlinePaymentEnabled;

  IssuedCard({
    required this.id,
    required this.type,
    required this.holderName,
    required this.fullNumber,
    required this.maskedNumber,
    required this.cvv,
    required this.expiry,
    required this.issuedAt,
    this.isFrozen = false,
    String? nickname,
    this.isNicknameCustom = false,
    this.spendingLimit = 10000,
    this.isOnlinePaymentEnabled = true,
  }) : nickname = nickname ?? type.nameKey;

  /// يرجع الاسم المعروض الصحيح: إن كان مفتاح ترجمة يترجمه، وإن كان
  /// نصًا مخصصًا كتبه المستخدم يرجعه كما هو دون أي تغيير.
  String displayNickname(String Function(String key) translate) {
    return isNicknameCustom ? nickname : translate(nickname);
  }
}
