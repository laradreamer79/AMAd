import 'package:flutter/material.dart';
import 'otp_screen.dart';

class ReviewScreen extends StatelessWidget {
  final String beneficiary;
  final String amount;
  final String note;
  final String transferType;
  final String reference;

  const ReviewScreen({
    super.key,
    required this.beneficiary,
    required this.amount,
    this.note = '',
    required this.transferType,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transfer type: $transferType'),
            const SizedBox(height: 8),
            Text('Transfer from: SA **** **** **** 9012'),
            const SizedBox(height: 8),
            Text('Transfer to: $beneficiary'),
            const SizedBox(height: 8),
            Text('Amount: $amount'),
            const SizedBox(height: 8),
            Text('Reference: $reference'),
            const SizedBox(height: 8),
            Text('Note: ${note.isEmpty ? '-' : note}'),
            const SizedBox(height: 24),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OtpScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6A94A),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
