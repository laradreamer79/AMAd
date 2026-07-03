import 'package:flutter/material.dart';
import '../bill.dart';

/// يدير قائمة الفواتير المحفوظة — يحل محل القائمة الثابتة savedBills
/// عشان زر "إضافة فاتورة" يقدر فعليًا يضيف فاتورة جديدة للحالة.
class BillsProvider extends ChangeNotifier {
  final List<Bill> _bills = List<Bill>.from(savedBills);

  List<Bill> get bills => List.unmodifiable(_bills);

  void addBill(Bill bill) {
    _bills.insert(0, bill);
    notifyListeners();
  }

  void removeBill(Bill bill) {
    _bills.remove(bill);
    notifyListeners();
  }
}
