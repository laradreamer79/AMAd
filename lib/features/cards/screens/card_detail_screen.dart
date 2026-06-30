import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';
import '../models/card_type_option.dart';
import '../providers/cards_provider.dart';
import '../widgets/card_preview.dart';

class CardDetailScreen extends StatefulWidget {
  final String cardId;

  const CardDetailScreen({super.key, required this.cardId});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  bool _numberVisible = false;
  bool _isEditingNickname = false;
  late TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _startEditingNickname(String currentNickname) {
    _nicknameController.text = currentNickname;
    setState(() => _isEditingNickname = true);
  }

  void _saveNickname(CardsProvider provider, LangProvider lang) {
    provider.updateNickname(widget.cardId, _nicknameController.text);
    setState(() => _isEditingNickname = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lang.t('nickname_updated')),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSpendingLimitSheet(
      BuildContext context, IssuedCard card, CardsProvider provider, LangProvider lang) {
    final controller = TextEditingController(
      text: card.spendingLimit.toStringAsFixed(0),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Directionality(
        textDirection: lang.direction,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang.t('spending_limit'), style: AppTextStyles.stepTitle),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.stepTitle,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final value = double.tryParse(controller.text.trim());
                    if (value != null && value > 0) {
                      provider.updateSpendingLimit(widget.cardId, value);
                    }
                    Navigator.of(sheetContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(lang.t('save'), style: AppTextStyles.buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CardsProvider>();
    final lang = context.watch<LangProvider>();
    final card = provider.findById(widget.cardId);

    if (card == null) {
      // البطاقة قد تكون حُذفت أو غير موجودة — نرجع تلقائيًا
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    return Directionality(
      textDirection: lang.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        lang.isRTL ? Icons.arrow_forward : Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        lang.t('card_details'),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.cardTypeName,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CardPreview(
                        type: card.type,
                        holderName: card.holderName,
                        maskedNumber: _numberVisible ? card.fullNumber : card.maskedNumber,
                        expiry: card.expiry,
                      ),
                      const SizedBox(height: 16),

                      // زر إظهار/إخفاء الرقم
                      Center(
                        child: TextButton.icon(
                          onPressed: () => setState(() => _numberVisible = !_numberVisible),
                          icon: Icon(
                            _numberVisible ? Icons.visibility_off : Icons.visibility,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            _numberVisible ? lang.t('hide_number') : lang.t('show_number'),
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // حالة البطاقة
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  card.isFrozen ? Icons.ac_unit : Icons.check_circle,
                                  color: card.isFrozen ? AppColors.textSecondary : AppColors.success,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  card.isFrozen ? lang.t('status_frozen') : lang.t('status_active'),
                                  style: AppTextStyles.value,
                                ),
                              ],
                            ),
                            Switch(
                              value: !card.isFrozen,
                              activeThumbColor: AppColors.success,
                              onChanged: (_) => provider.toggleFreeze(card.id),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        lang.t('card_settings'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // اسم البطاقة (nickname) قابل للتعديل
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: _isEditingNickname
                            ? Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _nicknameController,
                                      autofocus: true,
                                      style: AppTextStyles.value,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _saveNickname(provider, lang),
                                    child: Text(lang.t('save')),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(lang.t('card_nickname'), style: AppTextStyles.label),
                                      const SizedBox(height: 4),
                                      Text(card.displayNickname(lang.t), style: AppTextStyles.value),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () => _startEditingNickname(card.displayNickname(lang.t)),
                                    icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 12),

                      // حد الإنفاق
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showSpendingLimitSheet(context, card, provider, lang),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(lang.t('spending_limit'), style: AppTextStyles.label),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${card.spendingLimit.toStringAsFixed(0)} ${lang.isRTL ? "ر.س" : "SAR"}',
                                    style: AppTextStyles.value,
                                  ),
                                ],
                              ),
                              Icon(
                                lang.isRTL ? Icons.chevron_left : Icons.chevron_right,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // الدفع الإلكتروني
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(lang.t('online_payments'), style: AppTextStyles.value),
                            Switch(
                              value: card.isOnlinePaymentEnabled,
                              activeThumbColor: AppColors.primary,
                              onChanged: (_) => provider.toggleOnlinePayment(card.id),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // تفاصيل إضافية (CVV، تاريخ الانتهاء، الحامل)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          children: [
                            _InfoRow(label: lang.t('holder_label'), value: card.holderName),
                            const SizedBox(height: 12),
                            _InfoRow(
                              label: lang.t('expiry_label'),
                              value: card.expiry,
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              label: lang.t('cvv_label'),
                              value: _numberVisible ? card.cvv : '•••',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value, style: AppTextStyles.value),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}
