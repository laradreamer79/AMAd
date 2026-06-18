import 'package:flutter/material.dart';

class BeneficiaryScreen extends StatefulWidget {
  const BeneficiaryScreen({super.key});

  @override
  State<BeneficiaryScreen> createState() => _BeneficiaryScreenState();
}

class _BeneficiaryScreenState extends State<BeneficiaryScreen> {
  bool _showAll = false;

  static const _allBeneficiaries = [
    'Lara - 9012',
    'Omar - 1123',
    'Fatima - 3344',
    'Noura - 5566',
    'Hassan - 7788',
    'Zain - 9900',
    'Amina - 2211',
  ];

  List<String> get _visibleBeneficiaries {
    return _showAll ? _allBeneficiaries : _allBeneficiaries.take(3).toList();
  }

  void _selectBeneficiary(String beneficiary) {
    Navigator.pop(context, beneficiary);
  }

  @override
  Widget build(BuildContext context) {
    final beneficiaries = _visibleBeneficiaries;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Beneficiary')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Fast beneficiaries',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: beneficiaries.length + (_showAll ? 0 : 1),
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                if (!_showAll && index == beneficiaries.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showAll = true;
                        });
                      },
                      child: const Text('Show all beneficiaries'),
                    ),
                  );
                }

                final name = beneficiaries[index];
                return ListTile(
                  title: Text(name),
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selectBeneficiary(name),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6A94A),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add beneficiary pressed')),
                );
              },
              child: const Text(
                'Add beneficiary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
