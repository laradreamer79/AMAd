import 'package:flutter/material.dart';

import '../transfer/transfer_screen.dart';
import 'ai_service.dart';

class TransferAssistantSheet extends StatefulWidget {
  const TransferAssistantSheet({super.key});

  @override
  State<TransferAssistantSheet> createState() => _TransferAssistantSheetState();
}

class _TransferAssistantSheetState extends State<TransferAssistantSheet> {
  final _service = AiService();
  final _inputCtrl = TextEditingController();
  final _messages = <_AssistantMessage>[
    const _AssistantMessage(
      'Tell me the transfer you want. For example: transfer 500 to Omar.',
      isUser: false,
    ),
  ];

  TransferAssistantDraft _draft = const TransferAssistantDraft();

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  void _handleInput(String value) {
    final input = value.trim();
    if (input.isEmpty) return;

    setState(() {
      _messages.add(_AssistantMessage(input, isUser: true));
      _draft = _service.updateTransferDraft(_draft, input);
      _messages.add(_AssistantMessage(_nextAssistantMessage(), isUser: false));
      _inputCtrl.clear();
    });
  }

  String _nextAssistantMessage() {
    final missingField = _service.nextMissingField(_draft);
    if (missingField != null) return _service.questionFor(missingField);
    return _service.readyMessage(_draft);
  }

  void _selectOption(String option) {
    _handleInput(option);
  }

  void _startGuidedFlow() {
    if (!_draft.isReady) return;
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(builder: (_) => TransferScreen(assistantDraft: _draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missingField = _service.nextMissingField(_draft);
    final options = missingField == null
        ? const <String>[]
        : _service.optionsFor(missingField);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFFD6A94A)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Transfer assistant',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _messages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? const Color(0xFFD6A94A)
                            : const Color(0xFF141B24),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (options.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((option) {
                  return ActionChip(
                    label: Text(option),
                    onPressed: () => _selectOption(option),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            if (_draft.isReady)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startGuidedFlow,
                  icon: const Icon(Icons.fact_check),
                  label: const Text('Start transfer flow'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6A94A),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleInput,
                      decoration: const InputDecoration(
                        hintText: 'Type your answer',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send',
                    onPressed: () => _handleInput(_inputCtrl.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AssistantMessage {
  final String text;
  final bool isUser;

  const _AssistantMessage(this.text, {required this.isUser});
}
