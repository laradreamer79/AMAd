import 'package:flutter/material.dart';
import 'beneficiary_screen.dart';
import 'transfer_details_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String? _transferType;

  Future<void> _chooseBeneficiary() async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const BeneficiaryScreen()),
    );
    if (!mounted || result == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferDetailsScreen(
          beneficiary: result,
          transferType: _transferType!,
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
