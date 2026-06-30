import 'package:flutter/material.dart';
import '../ai/ai_service.dart';
import 'beneficiary_screen.dart';
import 'transfer_details_screen.dart';

class TransferScreen extends StatefulWidget {
  final TransferAssistantDraft? assistantDraft;

  const TransferScreen({super.key, this.assistantDraft});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String? _transferType;
  bool _assistantStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runAssistantFlow());
  }

  Future<void> _runAssistantFlow() async {
    final draft = widget.assistantDraft;
    if (_assistantStarted || draft == null || !draft.isReady || !mounted) {
      return;
    }

    _assistantStarted = true;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _transferType = draft.transferType;
    });

    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await _chooseBeneficiary();
  }

  Future<void> _chooseBeneficiary() async {
    final draft = widget.assistantDraft;
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => BeneficiaryScreen(
          assistantBeneficiary: draft?.isReady == true
              ? draft!.beneficiary
              : null,
        ),
      ),
    );
    if (!mounted || result == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferDetailsScreen(
          beneficiary: result,
          transferType: _transferType!,
          assistantDraft: draft?.isReady == true ? draft : null,
        ),
      ),
    );
  }

  void _selectTransferType(String type) {
    setState(() {
      _transferType = type;
    });
    _chooseBeneficiary();
  }

  Widget _buildTransferTypeOption(String type, IconData icon) {
    final selected = _transferType == type;
    return GestureDetector(
      onTap: () => _selectTransferType(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD6A94A) : const Color(0xFF141B24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFB48A3C) : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: selected ? Colors.black : Colors.white70),
                const SizedBox(width: 16),
                Text(
                  type,
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: selected ? Colors.black : Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transfer type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTransferTypeOption('Local', Icons.public),
            const SizedBox(height: 12),
            _buildTransferTypeOption('International', Icons.flight_takeoff),
            const SizedBox(height: 12),
            _buildTransferTypeOption('Inside same bank', Icons.account_balance),
          ],
        ),
      ),
    );
  }
}
