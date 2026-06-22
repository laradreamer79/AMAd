import 'bill.dart';

class BillPayment {
  final Bill bill;
  final String account;
  final String amount;

  const BillPayment({
    required this.bill,
    required this.account,
    required this.amount,
  });
}
