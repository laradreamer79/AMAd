import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';
import '../../account/providers/account_provider.dart';
import '../../cards/widgets/primary_pill_button.dart';
import '../providers/transfer_provider.dart';
import '../widgets/transfer_header.dart';

class OtpTransferStep extends StatefulWidget {
  final VoidCallback onClose;

  const OtpTransferStep({super.key, required this.onClose});

  @override
  State<OtpTransferStep> createState() => _OtpTransferStepState();
}

class _OtpTransferStepState extends State<OtpTransferStep> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TransferProvider>();
    _controllers = List.generate(
      TransferProvider.otpLength,
      (i) => TextEditingController(text: provider.otpDigits[i]),
    );
    _focusNodes = List.generate(TransferProvider.otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value, TransferProvider provider) {
    provider.setOtpDigit(index, value);
    if (value.isNotEmpty && index < TransferProvider.otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferProvider>();
    final account = context.read<AccountProvider>();
    final lang = context.watch<LangProvider>();

    return Directionality(
      textDirection: lang.direction,
      child: Column(
        children: [
          TransferHeader(step: provider.step, onClose: widget.onClose),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.t('verify_identity'), style: AppTextStyles.stepTitle),
                  const SizedBox(height: 10),
                  Text(lang.t('otp_desc'), style: AppTextStyles.stepSubtitle),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(TransferProvider.otpLength, (i) {
                      final isFilled = provider.otpDigits[i].isNotEmpty;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isFilled
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                              width: isFilled ? 2 : 1,
                            ),
                          ),
                          child: TextField(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                            ),
                            onChanged: (v) => _onDigitChanged(i, v, provider),
                          ),
                        ),
                      );
                    }),
                  ),
                  if (provider.otpError != null) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        lang.t(provider.otpError!),
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: provider.otpSecondsLeft > 0
                        ? Text(
                            _formatTime(provider.otpSecondsLeft),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          )
                        : TextButton.icon(
                            onPressed: provider.resendOtp,
                            icon: const Icon(Icons.refresh, size: 18, color: AppColors.primary),
                            label: Text(
                              lang.t('resend_code'),
                              style: const TextStyle(color: AppColors.primary),
                            ),
                          ),
                  ),
                  const SizedBox(height: 56),
                  PrimaryPillButton(
                    label: lang.t('confirm'),
                    isLoading: provider.isSubmitting,
                    onPressed: () async {
                      await provider.confirmOtp(account);
                    },
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
