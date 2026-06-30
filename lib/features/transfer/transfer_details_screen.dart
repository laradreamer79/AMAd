import 'package:flutter/material.dart';
import '../ai/ai_service.dart';
import 'review_screen.dart';

class TransferDetailsScreen extends StatefulWidget {
  final String beneficiary;
  final String transferType;
  final TransferAssistantDraft? assistantDraft;

  const TransferDetailsScreen({
    super.key,
    required this.beneficiary,
    required this.transferType,
    this.assistantDraft,
  });

  @override
  State<TransferDetailsScreen> createState() => _TransferDetailsScreenState();
}

class _TransferDetailsScreenState extends State<TransferDetailsScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _transferFrom;
  String? _reason;

  final _transferFromOptions = [
    'SA **** **** **** 9012',
    'SA **** **** **** 3344',
  ];

  final _reasonOptions = ['Bills', 'Salary', 'Gift', 'Family Support', 'Other'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runAssistantFlow());
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _runAssistantFlow() async {
    final draft = widget.assistantDraft;
    if (draft == null || !draft.isReady || !mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() {
      _transferFrom = _transferFromOptions.first;
      _amountCtrl.text = draft.amount!;
      _reason = draft.reason;
      _noteCtrl.text = draft.note;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    _next();
  }

  void _next() {
    final amount = _amountCtrl.text.trim();
    final note = _noteCtrl.text.trim();
    if (amount.isEmpty || _transferFrom == null || _reason == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          beneficiary: widget.beneficiary,
          amount: amount,
          note: note,
          transferType: widget.transferType,
          reference: _reason!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final beneficiaryParts = widget.beneficiary.split(' - ');
    final beneficiaryName = beneficiaryParts.first;
    final beneficiaryAccount = beneficiaryParts.length > 1
        ? beneficiaryParts.last
        : widget.beneficiary;

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Beneficiary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF141B24),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    beneficiaryName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Account: $beneficiaryAccount',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transfer type: ${widget.transferType}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _transferFrom,
              decoration: const InputDecoration(
                labelText: 'Transfer from',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select source account'),
              items: _transferFromOptions
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _transferFrom = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _reason,
              decoration: const InputDecoration(
                labelText: 'Reason for transfer',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select reason'),
              items: _reasonOptions
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _reason = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Add a note',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6A94A),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
