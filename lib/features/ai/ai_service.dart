class AiService {
  static const transferTypes = ['Local', 'International', 'Inside same bank'];

  static const beneficiaries = [
    'Lara - 9012',
    'Omar - 1123',
    'Fatima - 3344',
    'Noura - 5566',
    'Hassan - 7788',
    'Zain - 9900',
    'Amina - 2211',
  ];

  static const reasons = ['Bills', 'Salary', 'Gift', 'Family Support', 'Other'];

  TransferAssistantDraft updateTransferDraft(
    TransferAssistantDraft draft,
    String input,
  ) {
    final normalized = input.trim().toLowerCase();
    if (normalized.isEmpty) return draft;

    final amount = _extractAmount(normalized);
    final beneficiary = _matchOption(normalized, beneficiaries);
    final transferType = _matchTransferType(normalized);
    final reason = _matchOption(normalized, reasons);

    return draft.copyWith(
      amount: amount ?? draft.amount,
      beneficiary: beneficiary ?? draft.beneficiary,
      transferType: transferType ?? draft.transferType,
      reason: reason ?? draft.reason,
      note: _extractNote(input) ?? draft.note,
    );
  }

  TransferAssistantField? nextMissingField(TransferAssistantDraft draft) {
    if (draft.beneficiary == null) return TransferAssistantField.beneficiary;
    if (draft.amount == null) return TransferAssistantField.amount;
    if (draft.transferType == null) return TransferAssistantField.transferType;
    if (draft.reason == null) return TransferAssistantField.reason;
    return null;
  }

  String questionFor(TransferAssistantField field) {
    return switch (field) {
      TransferAssistantField.beneficiary => 'Who do you want to transfer to?',
      TransferAssistantField.amount => 'How much should I transfer?',
      TransferAssistantField.transferType =>
        'Which transfer type should I use?',
      TransferAssistantField.reason => 'What is the reason for this transfer?',
    };
  }

  List<String> optionsFor(TransferAssistantField field) {
    return switch (field) {
      TransferAssistantField.beneficiary => beneficiaries,
      TransferAssistantField.transferType => transferTypes,
      TransferAssistantField.reason => reasons,
      TransferAssistantField.amount => const [],
    };
  }

  String readyMessage(TransferAssistantDraft draft) {
    return 'I prepared ${draft.amount} SAR to ${draft.beneficiary} '
        'as a ${draft.transferType} transfer for ${draft.reason}. '
        'Please review before OTP.';
  }

  String? _extractAmount(String input) {
    final match = RegExp(r'(\d+(?:[.,]\d{1,2})?)').firstMatch(input);
    return match?.group(1)?.replaceAll(',', '.');
  }

  String? _matchTransferType(String input) {
    if (input.contains('same bank') ||
        input.contains('same-bank') ||
        input.contains('inside')) {
      return 'Inside same bank';
    }
    if (input.contains('international')) return 'International';
    if (input.contains('local')) return 'Local';
    return null;
  }

  String? _matchOption(String input, List<String> options) {
    for (final option in options) {
      final label = option.toLowerCase();
      final nameOnly = label.split(' - ').first;
      if (input.contains(label) || input.contains(nameOnly)) {
        return option;
      }
    }
    return null;
  }

  String? _extractNote(String input) {
    final match = RegExp(
      r'(?:note|memo|message)\s+(.*)$',
      caseSensitive: false,
    ).firstMatch(input);
    final note = match?.group(1)?.trim();
    return note == null || note.isEmpty ? null : note;
  }
}

enum TransferAssistantField { beneficiary, amount, transferType, reason }

class TransferAssistantDraft {
  final String? beneficiary;
  final String? amount;
  final String? transferType;
  final String? reason;
  final String note;

  const TransferAssistantDraft({
    this.beneficiary,
    this.amount,
    this.transferType,
    this.reason,
    this.note = '',
  });

  bool get isReady {
    return beneficiary != null &&
        amount != null &&
        transferType != null &&
        reason != null;
  }

  TransferAssistantDraft copyWith({
    String? beneficiary,
    String? amount,
    String? transferType,
    String? reason,
    String? note,
  }) {
    return TransferAssistantDraft(
      beneficiary: beneficiary ?? this.beneficiary,
      amount: amount ?? this.amount,
      transferType: transferType ?? this.transferType,
      reason: reason ?? this.reason,
      note: note ?? this.note,
    );
  }
}
