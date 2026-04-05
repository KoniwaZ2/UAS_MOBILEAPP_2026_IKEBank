class BeneficialAccount {
  final String id;
  final String accountNumber;
  final String bankName;
  final String accountHolderName;
  final String addedAt;

  const BeneficialAccount({
    required this.id,
    required this.accountNumber,
    required this.bankName,
    required this.accountHolderName,
    required this.addedAt,
  });

  factory BeneficialAccount.fromJson(Map<String, dynamic> json) {
    return BeneficialAccount(
      id: _readString(json, const ['id']),
      accountNumber: _readString(json, const ['account_number']),
      bankName: _readString(json, const ['bank_name']),
      accountHolderName: _readString(json, const ['account_holder_name']),
      addedAt: _readString(json, const ['added_at']),
    );
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return '';
  }

  @override
  String toString() {
    return 'BeneficialAccount(id: $id, accountNumber: $accountNumber, bankName: $bankName, accountHolderName: $accountHolderName, addedAt: $addedAt)';
  }
}
