enum TransactionType { transfer, bill, cardIssuance, deposit, other }

enum TransactionDirection { debit, credit }

class TransactionModel {
  final String id;
  final TransactionType type;
  final TransactionDirection direction;
  final double amount;
  final String titleKey; // مفتاح ترجمة للعنوان (مثل "transfer_to")
  final String? subtitle; // نص خام إضافي (اسم المستفيد، رقم الفاتورة..)
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.direction,
    required this.amount,
    required this.titleKey,
    this.subtitle,
    required this.date,
  });
}
