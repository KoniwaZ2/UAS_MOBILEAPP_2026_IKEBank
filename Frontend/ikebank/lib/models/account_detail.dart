class AccountDetail {
  final int id;
  final int userid;
  final String username;
  final String accountnumber;
  final String cardnumber;
  final String balance;

  AccountDetail({
    required this.id,
    required this.userid,
    required this.username,
    required this.accountnumber,
    required this.cardnumber,
    required this.balance,
  });

  factory AccountDetail.fromJson(Map<String, dynamic> json) {
    return AccountDetail(
      id: _parseInt(json['id']),
      userid: _parseInt(json['user_id']),
      username: _readString(json, ['user_name']),
      accountnumber: _readString(json, ['account_number']),
      cardnumber: _readString(json, ['card_number']),
      balance: (json['balance'] ?? '0').toString(),
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

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
