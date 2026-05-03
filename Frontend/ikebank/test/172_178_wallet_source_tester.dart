// Test 172: Wallet category from value
// Detail: Known category mapping returns enum
// Class/Method: walletCategoryFromValue()
// Test 173: Wallet category unknown fallback
// Detail: Unknown category maps to lainnya
// Class/Method: walletCategoryFromValue()
// Test 174: Wallet source resolve primary
// Detail: is_primary true maps utama
// Class/Method: WalletSource._resolveCategory()
// Test 175: Wallet source resolve category text
// Detail: category_name recognized correctly
// Class/Method: WalletSource._resolveCategory()
// Test 176: Wallet source resolve name fallback
// Detail: Name-based fallback category works
// Class/Method: WalletSource._resolveCategory()
// Test 177: Wallet source bool parsing
// Detail: bool/num/string bool parsed correctly
// Class/Method: WalletSource._readBool()
// Test 178: Wallet source image mapping
// Detail: Category maps to proper asset path
// Class/Method: WalletSource._imageForCategory()
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/models/wallet_source.dart';

void main() {
  test('172 - known categories map correctly', () {
    expect(walletCategoryFromValue('utama'), WalletCategory.utama);
    expect(walletCategoryFromValue('nabung'), WalletCategory.nabung);
    expect(walletCategoryFromValue('transaksi'), WalletCategory.transaksi);
    expect(walletCategoryFromValue('deposito'), WalletCategory.deposito);
  });

  test('173 - unknown category maps to lainnya', () {
    expect(walletCategoryFromValue('something'), WalletCategory.lainnya);
    expect(walletCategoryFromValue(''), WalletCategory.lainnya);
  });

  test('174 - is_primary true maps to utama', () {
    final json = <String, dynamic>{
      'saku_name': 'My Wallet',
      'is_primary': true,
      'balance': '100000',
      'category_name': 'nabung',
    };
    final source = WalletSource.fromJson(json);
    expect(source.category, WalletCategory.utama);
  });

  test('175 - category_name recognized correctly', () {
    final json = <String, dynamic>{
      'saku_name': 'Transaksi Wallet',
      'is_primary': false,
      'balance': '50000',
      'category_name': 'transaksi',
    };
    final source = WalletSource.fromJson(json);
    expect(source.category, WalletCategory.transaksi);
  });

  test('176 - name-based fallback category', () {
    final json = <String, dynamic>{
      'saku_name': 'nabung',
      'is_primary': false,
      'balance': '50000',
      'category_name': 'unknown',
    };
    final source = WalletSource.fromJson(json);
    expect(source.category, WalletCategory.nabung);
  });

  test('177 - bool parsing from various types', () {
    // Test with bool
    final json1 = <String, dynamic>{
      'saku_name': 'Test',
      'is_primary': true,
      'balance': '0',
    };
    final source1 = WalletSource.fromJson(json1);
    expect(source1.category, WalletCategory.utama);

    // Test with string 'true'
    final json2 = <String, dynamic>{
      'saku_name': 'Test',
      'is_primary': 'true',
      'balance': '0',
    };
    final source2 = WalletSource.fromJson(json2);
    expect(source2.category, WalletCategory.utama);

    // Test with num 1
    final json3 = <String, dynamic>{
      'saku_name': 'Test',
      'is_primary': 1,
      'balance': '0',
    };
    final source3 = WalletSource.fromJson(json3);
    expect(source3.category, WalletCategory.utama);
  });

  test('178 - category maps to proper asset path', () {
    final utamaSource = WalletSource.fromJson(<String, dynamic>{
      'saku_name': 'Utama',
      'is_primary': true,
      'balance': '0',
    });
    expect(utamaSource.imagePath, 'assets/images/IKEHome.png');

    final nabungSource = WalletSource.fromJson(<String, dynamic>{
      'saku_name': 'Test',
      'is_primary': false,
      'balance': '0',
      'category_name': 'nabung',
    });
    expect(nabungSource.imagePath, 'assets/images/nabung.png');

    final transaksiSource = WalletSource.fromJson(<String, dynamic>{
      'saku_name': 'Test',
      'is_primary': false,
      'balance': '0',
      'category_name': 'transaksi',
    });
    expect(transaksiSource.imagePath, 'assets/images/transaksi.png');

    final lainnyaSource = WalletSource.fromJson(<String, dynamic>{
      'saku_name': 'Test',
      'is_primary': false,
      'balance': '0',
      'category_name': 'other',
    });
    expect(lainnyaSource.imagePath, 'assets/images/celengan.png');
  });
}
