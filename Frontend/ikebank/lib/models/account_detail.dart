class AccountDetail {
  final int id;
  final int user_id;
  final String user_name;
  final String account_number;
  final String card_number;
  final String balance;

  AccountDetail({
    required this.id,
    required this.user_id,
    required this.user_name,
    required this.account_number,
    required this.card_number,
    required this.balance,
  });

  factory AccountDetail.fromJson(Map<String, dynamic> json) {
    return AccountDetail(
      id: _parseInt(json['id']),
      user_id: _parseInt(json['user_id']),
      user_name: (json['user_name'] ?? '').toString(),
      account_number: (json['account_number'] ?? '').toString(),
      card_number: (json['card_number'] ?? '').toString(),
      balance: (json['balance'] ?? '0').toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
