enum WalletCategory { utama, nabung, transaksi, lainnya }

WalletCategory walletCategoryFromValue(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized == 'utama') {
    return WalletCategory.utama;
  }
  if (normalized == 'nabung') {
    return WalletCategory.nabung;
  }
  if (normalized == 'transaksi') {
    return WalletCategory.transaksi;
  }
  return WalletCategory.lainnya;
}

class WalletSource {
  final String id;
  final String name;
  final String balance;
  final String imagePath;
  final WalletCategory category;
  final String? tag;

  const WalletSource({
    required this.id,
    required this.name,
    required this.balance,
    required this.imagePath,
    required this.category,
    this.tag,
  });

  factory WalletSource.fromJson(Map<String, dynamic> json) {
    final isPrimary = _readBool(json, const ['is_primary', 'isPrimary']);
    final categoryValue = _readString(json, const [
      'category_name',
      'category',
      'wallet_type',
      'saku_type',
    ]);
    final name = _readString(json, const ['saku_name', 'name', 'label']);

    final category = _resolveCategory(
      isPrimary: isPrimary,
      categoryValue: categoryValue,
      name: name,
    );

    return WalletSource(
      id: _readString(json, const ['id', 'wallet_id', 'saku_id']),
      name: name,
      balance: _readString(json, const ['balance']),
      imagePath: _imageForCategory(category),
      category: category,
      tag: category == WalletCategory.transaksi ? 'Transaksi' : null,
    );
  }

  static WalletCategory _resolveCategory({
    required bool isPrimary,
    required String categoryValue,
    required String name,
  }) {
    if (isPrimary) {
      return WalletCategory.utama;
    }

    final category = walletCategoryFromValue(categoryValue);
    if (category != WalletCategory.lainnya) {
      return category;
    }

    return walletCategoryFromValue(name);
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

  static bool _readBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1') {
          return true;
        }
        if (normalized == 'false' || normalized == '0') {
          return false;
        }
      }
    }
    return false;
  }

  static String _imageForCategory(WalletCategory category) {
    if (category == WalletCategory.utama) {
      return 'assets/images/IKEHome.png';
    }
    if (category == WalletCategory.nabung) {
      return 'assets/images/celengan.png';
    }
    if (category == WalletCategory.transaksi) {
      return 'assets/images/celengan.png';
    }
    return 'assets/images/celengan.png';
  }
}
