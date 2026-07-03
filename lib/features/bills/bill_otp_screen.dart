import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/i18n/lang_provider.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/widgets/app_header.dart';
import '../cards/widgets/primary_pill_button.dart';
import 'bill_payment.dart';
import 'bill_success_screen.dart';

class BillOtpScreen extends StatefulWidget {
  final BillPayment payment;

  const BillOtpScreen({super.key, required this.payment});

  @override
  State<BillOtpScreen> createState() => _BillOtpScreenState();
}

class _BillOtpScreenState extends State<BillOtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) return;

    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      AppPageRoute(
        builder: (_) => BillSuccessScreen(payment: widget.payment),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 46,
      height: 54,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(14),
        color: AppColors.inputFill,
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: AppTextStyles.stepTitle.copyWith(fontSize: 22),
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final otpComplete =
        _otpControllers.every((controller) => controller.text.isNotEmpty);

    return Directionality(
      textDirection: lang.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            AppHeader(titleKey: 'otp_verification'),
            Expanded(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${lang.t('otp_subtitle')} ${widget.payment.bill.name}',
                        style: AppTextStyles.stepSubtitle,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) => _buildOtpBox(index)),
                      ),
                      const Spacer(),
                      PrimaryPillButton(
                        label: lang.t('verify'),
                        isLoading: _isVerifying,
                        onPressed: otpComplete ? _verify : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
