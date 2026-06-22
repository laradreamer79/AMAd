import 'package:flutter/material.dart';

import 'bill.dart';
import 'bill_payment.dart';
import 'bill_review_screen.dart';

class BillPaymentDetailsScreen extends StatefulWidget {
  final Bill bill;

  const BillPaymentDetailsScreen({super.key, required this.bill});

  @override
  State<BillPaymentDetailsScreen> createState() =>
      _BillPaymentDetailsScreenState();
}

class _BillPaymentDetailsScreenState extends State<BillPaymentDetailsScreen> {
  final _amountController = TextEditingController();
  String? _selectedAccount;

  static const _accounts = ['SA **** **** **** 9012', 'SA **** **** **** 3344'];

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.bill.amount.replaceAll(' SAR', '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _review() {
    final amount = _amountController.text.trim();
    if (_selectedAccount == null || amount.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BillReviewScreen(
          payment: BillPayment(
            bill: widget.bill,
            account: _selectedAccount!,
            amount: '$amount SAR',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Details')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141B24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bill.biller,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bill number: ${bill.accountNumber}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Due date: ${bill.dueDate}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _selectedAccount,
                decoration: const InputDecoration(
                  labelText: 'Pay from',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Choose an account'),
                items: _accounts
                    .map(
                      (account) => DropdownMenuItem(
                        value: account,
                        child: Text(account),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedAccount = value),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  suffixText: 'SAR',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _review,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6A94A),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Review',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
