import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/lang_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_header.dart';
import 'ai_service.dart';
import 'envelope_router.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _service = AiService();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(textKey: 'ai_welcome', isUser: false),
  ];

  String? _statusText;
  bool _streaming = false;

  @override
  void initState() {
    super.initState();
    _service.connect();
    _service.events.listen(_handleEvent);
  }

  @override
  void dispose() {
    _service.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleEvent(AiEvent event) {
    switch (event.type) {
      case 'status':
        setState(() => _statusText = event.message);
      case 'token':
        setState(() {
          _statusText = null;
          if (_streaming && _messages.isNotEmpty && !_messages.last.isUser) {
            final last = _messages.removeLast();
            _messages.add(_ChatMessage(
              text: (last.text ?? '') + event.text,
              isUser: false,
            ));
          } else {
            _streaming = true;
            _messages.add(_ChatMessage(text: event.text, isUser: false));
          }
        });
        _scrollToBottom();
      case 'envelope':
        EnvelopeRouter.route(context, event.envelope);
      case 'done':
        setState(() {
          _statusText = null;
          _streaming = false;
        });
      case 'error':
        setState(() {
          _statusText = null;
          _streaming = false;
          _messages.add(_ChatMessage(text: event.message, isUser: false));
        });
        _scrollToBottom();
      case 'disconnected':
        setState(() => _statusText = 'انقطع الاتصال بالمساعد...');
    }
  }

  void _send([String? suggestedText]) {
    final text = (suggestedText ?? _controller.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _streaming = false;
      _controller.clear();
    });
    _scrollToBottom();
    _service.send(text);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final suggestions = [
      lang.t('ai_transfer_help'),
      lang.t('ai_bill_help'),
      lang.t('ai_card_help'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(titleKey: 'ai', showBack: true),
          if (_statusText != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _statusText!,
                  style: AppTextStyles.value.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              itemCount: _messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(
                  text: message.textKey == null
                      ? message.text!
                      : lang.t(message.textKey!),
                  isUser: message.isUser,
                );
              },
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ActionChip(
                  label: Text(suggestion),
                  onPressed: () => _send(suggestion),
                  backgroundColor: AppColors.card,
                  side: const BorderSide(color: AppColors.cardBorder),
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: lang.t('ai_hint'),
                        filled: true,
                        fillColor: AppColors.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    tooltip: lang.t('ai_send'),
                    onPressed: _send,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String? text;
  final String? textKey;
  final bool isUser;

  const _ChatMessage({this.text, this.textKey, required this.isUser});
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _MessageBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          text,
          style: AppTextStyles.value.copyWith(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
