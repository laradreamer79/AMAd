import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

/// يدير الحساب البنكي الأساسي للمستخدم: الرصيد، رقم الحساب،
/// وسجل المعاملات الموحّد (Mock بالكامل بدون Backend).
///
/// هذا الـ Provider هو نقطة الربط المركزية بين كل الميزات المالية:
/// التحويلات، الفواتير، وإصدار البطاقات — كل عملية مالية تمر من هنا
/// عشان الرصيد والسجل يبقوا متّسقين بكل أنحاء التطبيق.
class AccountProvider extends ChangeNotifier {
  double _balance = 47320.84;
  final String accountNumber = 'SA •••• •••• •••• 9012';
  final String currency = 'SAR';

  final List<TransactionModel> _transactions = [];

  double get balance => _balance;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  /// آخر 5 معاملات فقط — تُستخدم بشاشة Home
  List<TransactionModel> get recentTransactions {
    final sorted = List<TransactionModel>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  /// خصم مبلغ من الحساب وتسجيل معاملة جديدة.
  /// يرجع false إذا كان الرصيد غير كافٍ (دون تنفيذ أي تغيير).
  bool debit({
    required double amount,
    required TransactionType type,
    required String titleKey,
    String? subtitle,
  }) {
    if (amount <= 0 || amount > _balance) return false;

    _balance -= amount;
    _transactions.add(
      TransactionModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: type,
        direction: TransactionDirection.debit,
        amount: amount,
        titleKey: titleKey,
        subtitle: subtitle,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
    return true;
  }

  /// إضافة مبلغ للحساب (إيداع) وتسجيل معاملة.
  void credit({
    required double amount,
    required String titleKey,
    String? subtitle,
  }) {
    if (amount <= 0) return;

    _balance += amount;
    _transactions.add(
      TransactionModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: TransactionType.deposit,
        direction: TransactionDirection.credit,
        amount: amount,
        titleKey: titleKey,
        subtitle: subtitle,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// التحقق من كفاية الرصيد دون تنفيذ أي عملية (للاستخدام في validation الواجهة)
  bool canAfford(double amount) => amount > 0 && amount <= _balance;
}
