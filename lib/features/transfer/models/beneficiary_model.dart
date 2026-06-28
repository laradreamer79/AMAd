class Beneficiary {
  final String id;
  final String name;
  final String accountNumber;
  final String bankName;

  const Beneficiary({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.bankName,
  });
}

enum TransferType { local, international, sameBank, betweenAccounts }

extension TransferTypeX on TransferType {
  String get labelKey {
    switch (this) {
      case TransferType.local:
        return 'transfer_local';
      case TransferType.international:
        return 'transfer_international';
      case TransferType.sameBank:
        return 'transfer_same_bank';
      case TransferType.betweenAccounts:
        return 'transfer_between_accounts';
    }
  }

  String get iconAsset {
    switch (this) {
      case TransferType.local:
        return 'public';
      case TransferType.international:
        return 'flight';
      case TransferType.sameBank:
        return 'bank';
      case TransferType.betweenAccounts:
        return 'swap';
    }
  }
}
