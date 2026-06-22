import 'package:flutter/material.dart';

enum BillCategory {
  newBill('Add New Bill', Icons.add_circle_outline),
  oneTimePayment('One Time Payment', Icons.payments_outlined),
  trafficViolation('Traffic Violation', Icons.traffic_outlined),
  sadadGovernment('SADAD Government', Icons.account_balance_outlined);

  final String title;
  final IconData icon;

  const BillCategory(this.title, this.icon);
}

class Bill {
  final String name;
  final String biller;
  final String accountNumber;
  final String amount;
  final String dueDate;
  final BillCategory category;

  const Bill({
    required this.name,
    required this.biller,
    required this.accountNumber,
    required this.amount,
    required this.dueDate,
    required this.category,
  });
}

const savedBills = [
  Bill(
    name: 'Electricity Bill',
    biller: 'Saudi Electricity Company',
    accountNumber: '1009457822',
    amount: '320.50 SAR',
    dueDate: '28 Jun 2026',
    category: BillCategory.newBill,
  ),
  Bill(
    name: 'Mobile Postpaid',
    biller: 'STC',
    accountNumber: '055 *** 2345',
    amount: '184.00 SAR',
    dueDate: '30 Jun 2026',
    category: BillCategory.oneTimePayment,
  ),
  Bill(
    name: 'Traffic Violation',
    biller: 'Absher',
    accountNumber: 'Violation 889201',
    amount: '150.00 SAR',
    dueDate: '25 Jun 2026',
    category: BillCategory.trafficViolation,
  ),
  Bill(
    name: 'Passport Service',
    biller: 'Ministry of Interior',
    accountNumber: 'SADAD 042',
    amount: '300.00 SAR',
    dueDate: '02 Jul 2026',
    category: BillCategory.sadadGovernment,
  ),
];
