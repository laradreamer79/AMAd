import 'package:flutter/material.dart';

import 'account_application.dart';
import 'review_account_screen.dart';

class OpenAccountScreen extends StatefulWidget {
  const OpenAccountScreen({super.key});

  @override
  State<OpenAccountScreen> createState() => _OpenAccountScreenState();
}

class _OpenAccountScreenState extends State<OpenAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shortNameController = TextEditingController();
  String? _accountType;
  String? _currency;

  static const _accountTypes = ['Saving', 'Active', 'Family Account'];
  static const _currencies = ['SAR', 'USD', 'EUR', 'GBP'];

  @override
  void dispose() {
    _shortNameController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewAccountScreen(
          application: AccountApplication(
            accountType: _accountType!,
            currency: _currency!,
            shortName: _shortNameController.text.trim(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open New Account')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _accountType,
                  decoration: const InputDecoration(
                    labelText: 'Account type',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Choose account type'),
                  items: _accountTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  validator: (value) {
                    if (value == null) return 'Choose account type';
                    return null;
                  },
                  onChanged: (value) => setState(() => _accountType = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _currency,
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Choose currency'),
                  items: _currencies
                      .map(
                        (currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        ),
                      )
                      .toList(),
                  validator: (value) {
                    if (value == null) return 'Choose currency';
                    return null;
                  },
                  onChanged: (value) => setState(() => _currency = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _shortNameController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Account short name',
                    hintText: 'Enter short name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter account short name';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _continue(),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6A94A),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Confirmation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
