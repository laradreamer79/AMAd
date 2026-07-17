import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../accounts/account_application.dart';
import '../accounts/review_account_screen.dart';
import '../bills/bill.dart';
import '../bills/bill_payment.dart';
import '../bills/bill_review_screen.dart';
import '../cards/models/card_type_option.dart';
import '../cards/providers/cards_provider.dart';
import '../cards/screens/issue_card_screen.dart';
import '../products/product_application.dart';
import '../products/product_review_screen.dart';
import '../products/products_screen.dart';
import '../transfer/models/beneficiary_model.dart';
import '../transfer/providers/transfer_provider.dart';
import '../transfer/screens/transfer_screen.dart';

/// Routes agent envelopes from the AI backend (agent/) into Ameen's real
/// screens and providers.
///
/// Envelope contract (consumed verbatim from the agent service — see
/// agent/envelope.py in the backend):
/// {type, operation, payload, risk: {action, tier, fraud_probability, reasons},
///  llm_may_proceed}
///
/// - bill / account: pushed directly (these screens take their data as
///   constructor arguments, same as the agent prototype).
/// - transfer / card: Ameen drives these through a wizard-style
///   ChangeNotifier (TransferProvider / CardsProvider) that already lives at
///   the app root (see main.dart MultiProvider). So instead of pushing a
///   bare review screen, we populate that provider's state and jump it
///   straight to its `review` step, then open the existing wizard screen —
///   this way OTP, success, and the real AccountProvider debit/issuance
///   logic all keep working exactly as they do for a manual flow.
class EnvelopeRouter {
  const EnvelopeRouter._();

  static const Map<String, String> _reasonsArabic = {
    'new_beneficiary_high_amount': 'مبلغ مرتفع لمستفيد جديد',
    'night_time_high_amount': 'عملية بمبلغ مرتفع في وقت متأخر',
    'elevated_fraud_probability': 'مؤشرات مخاطر مرتفعة على العملية',
    'high_fraud_probability': 'احتمال احتيال مرتفع جداً',
    'behavioral_anomaly': 'نمط غير معتاد على حسابك',
    'amount_over_hard_limit': 'المبلغ يتجاوز الحد الأقصى المسموح',
    'insufficient_funds': 'الرصيد غير كافٍ لإتمام العملية',
    'velocity_limit_exceeded': 'تجاوزت عدد العمليات المسموح خلال 24 ساعة',
    'invalid_amount': 'المبلغ غير صالح',
    'non_monetary_operation': 'عملية غير مالية',
  };

  static List<String> _translateReasons(Map<String, dynamic> envelope) {
    final risk = (envelope['risk'] as Map?)?.cast<String, dynamic>() ?? {};
    final reasons = (risk['reasons'] as List?)?.cast<String>() ?? const [];
    return reasons.map((r) => _reasonsArabic[r] ?? r).toList();
  }

  static Future<void> route(
    BuildContext context,
    Map<String, dynamic> envelope,
  ) async {
    final type = (envelope['type'] ?? '') as String;
    final operation = (envelope['operation'] ?? '') as String;
    final payload =
        (envelope['payload'] as Map?)?.cast<String, dynamic>() ?? {};

    switch (type) {
      case 'REVIEW_TRANSFER':
      case 'REVIEW_BILL':
      case 'REVIEW_ACCOUNT':
      case 'REVIEW_CARD':
      case 'REVIEW_PRODUCT':
        _pushReview(context, operation, payload);
      case 'STEP_UP_VERIFY':
        await _stepUpDialog(context, operation, payload, envelope);
      case 'DECLINED':
        await _declinedDialog(context, envelope);
    }
  }

  static void _pushReview(
    BuildContext context,
    String operation,
    Map<String, dynamic> payload,
  ) {
    switch (operation) {
      case 'transfer':
        _openTransferReview(context, payload);
      case 'bill':
        _openBillReview(context, payload);
      case 'account':
        _openAccountReview(context, payload);
      case 'card':
        _openCardReview(context, payload);
      case 'product':
        _openProductReview(context, payload);
    }
  }

  /// "Name - IBAN" (agent payload format) -> Beneficiary(name, accountNumber).
  static Beneficiary _parseBeneficiary(String raw) {
    final parts = raw.split(' - ');
    final name = parts.isNotEmpty ? parts.first.trim() : raw.trim();
    final account = parts.length > 1 ? parts.sublist(1).join(' - ').trim() : '';
    return Beneficiary(
      id: 'ai-${account.isNotEmpty ? account : name}',
      name: name,
      accountNumber: account,
      bankName: 'بنك أمين',
    );
  }

  static void _openTransferReview(
    BuildContext context,
    Map<String, dynamic> payload,
  ) {
    final provider = context.read<TransferProvider>();
    final beneficiaryRaw = (payload['beneficiary'] ?? '') as String;

    provider.selectedType = TransferType.local;
    provider.selectedBeneficiary = _parseBeneficiary(beneficiaryRaw);
    provider.selectedReason = TransferReason.other;
    provider.amountController.text = (payload['amount'] ?? '') as String;
    provider.noteController.text = (payload['note'] ?? '') as String;
    provider.goTo(TransferStep.review);

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const TransferScreen()),
    );
  }

  static void _openBillReview(
    BuildContext context,
    Map<String, dynamic> payload,
  ) {
    final bill = (payload['bill'] as Map?)?.cast<String, dynamic>() ?? {};
    final screen = BillReviewScreen(
      payment: BillPayment(
        bill: Bill(
          name: (bill['name'] ?? '') as String,
          biller: (bill['biller'] ?? '') as String,
          accountNumber: (bill['account_number'] ?? '') as String,
          amount: (bill['amount'] ?? '') as String,
          dueDate: (bill['due_date'] ?? '') as String,
          category: BillCategory.values.asNameMap()[bill['category']] ??
              BillCategory.oneTimePayment,
        ),
        account: (payload['account'] ?? '') as String,
        amount: (payload['amount'] ?? '') as String,
      ),
    );
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) => screen));
  }

  static void _openAccountReview(
    BuildContext context,
    Map<String, dynamic> payload,
  ) {
    final screen = ReviewAccountScreen(
      application: AccountApplication(
        accountType: (payload['account_type'] ?? '') as String,
        currency: (payload['currency'] ?? 'SAR') as String,
        shortName: (payload['short_name'] ?? '') as String,
      ),
    );
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) => screen));
  }

  /// Matches the agent's free-text card_type ("Signature" / "Platinum" /
  /// "mada" / "Visa Platinum" ...) against Ameen's fixed CardTypeOption list.
  static CardTypeOption _matchCardType(String raw) {
    final needle = raw.toLowerCase();
    for (final option in CardTypeOption.all) {
      if (option.networkLabel.toLowerCase().contains(needle) ||
          needle.contains(option.networkLabel.toLowerCase())) {
        return option;
      }
    }
    if (needle.contains('mada')) {
      return CardTypeOption.all
          .firstWhere((o) => o.category == CardCategory.mada);
    }
    if (needle.contains('platinum')) {
      return CardTypeOption.all
          .firstWhere((o) => o.category == CardCategory.visaPlatinum);
    }
    return CardTypeOption.all.first; // defaults to Visa Signature
  }

  static void _openCardReview(
    BuildContext context,
    Map<String, dynamic> payload,
  ) {
    final provider = context.read<CardsProvider>();
    provider.selectType(_matchCardType((payload['card_type'] ?? '') as String));
    // The agent doesn't collect a cardholder name (it only knows card_type /
    // network / linked_account) — keep whatever the user already typed, or
    // fall back to their linked account label as a placeholder.
    if (provider.holderNameController.text.trim().isEmpty) {
      provider.holderNameController.text =
          (payload['linked_account'] ?? '') as String;
    }
    provider.goTo(IssueCardStep.review);

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const IssueCardScreen()),
    );
  }

  static void _openProductReview(
    BuildContext context,
    Map<String, dynamic> payload,
  ) {
    final product = findProductByTitle((payload['product_name'] ?? '') as String);
    if (product == null) return; // unknown product name — nothing safe to open
    final screen = ProductReviewScreen(
      product: product,
      application: ProductApplication(
        amount: (payload['amount'] ?? '') as String,
        duration: '${payload['duration_months'] ?? ''} شهر',
      ),
    );
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) => screen));
  }

  /// STEP_UP: the user explicitly confirms the flagged operation first,
  /// then continues into the normal review flow.
  static Future<void> _stepUpDialog(
    BuildContext context,
    String operation,
    Map<String, dynamic> payload,
    Map<String, dynamic> envelope,
  ) async {
    final reasons = _translateReasons(envelope);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF141B24),
          title: const Text('تحقق إضافي مطلوب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('رصد نظام الحماية ما يلي:'),
              const SizedBox(height: 10),
              for (final reason in reasons)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• $reason',
                      style: const TextStyle(color: Colors.white70)),
                ),
              const SizedBox(height: 8),
              const Text('هل أنت متأكد من رغبتك في المتابعة؟'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء',
                  style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6A94A),
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('متابعة'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      _pushReview(context, operation, payload);
    }
  }

  /// DECLINED is final: a blocking dialog with NO path to any review screen.
  static Future<void> _declinedDialog(
    BuildContext context,
    Map<String, dynamic> envelope,
  ) {
    final reasons = _translateReasons(envelope);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF141B24),
          icon: const Icon(Icons.block, color: Colors.redAccent, size: 40),
          title: const Text('تم رفض العملية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'رفض نظام الحماية هذه العملية ولا يمكن المتابعة.',
              ),
              const SizedBox(height: 10),
              for (final reason in reasons)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• $reason',
                      style: const TextStyle(color: Colors.white70)),
                ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6A94A),
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('حسناً'),
            ),
          ],
        ),
      ),
    );
  }
}
