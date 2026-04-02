# Testing API IKEBank - Quick Reference

## Prerequisites

- Server running: `python manage.py runserver 0.0.0.0:8000`
- Base URL: `http://localhost:8000`
- Auth: Add header `Authorization: Bearer {auth_token}`

---

## 1. REGISTER BANK ACCOUNT

```
POST /api/banking/register/
Authorization: Bearer {auth_token}
Content-Type: application/json

{}

Response (201):
{
  "id": 1,
  "account_number": "123456789012",
  "card_number": "4000123456789012",
  "balance": "0.00"
}

💡 Save account_id = 1 untuk request berikutnya
```

---

## 2. TAMBAH DANA (External Deposit)

```
POST /api/banking/tambah-dana/
Authorization: Bearer {auth_token}
Content-Type: application/json

{
  "account_id": 1,
  "amount": 500000,
  "description": "ATM deposit",
  "source": "ATM"
}

Response (200):
{
  "detail": "Funds added successfully to Saku Utama.",
  "transaction_id": 1,
  "new_balance": 500000,
  "saku_utama_balance": 500000
}

💡 Repeat dengan amount: 250000 → total balance: 750000
```

---

## 3. TRANSAKSI EKSTERNAL

```
POST /api/banking/transactions/
Authorization: Bearer {auth_token}
Content-Type: application/json

A. TRANSFER OUT
{
  "account_id": 1,
  "category": "transfer_out",
  "amount": 100000,
  "description": "Transfer ke teman",
  "destination_account": "1234567890"
}

B. PAYMENT (QRIS)
{
  "account_id": 1,
  "category": "payment",
  "amount": 50000,
  "description": "Bayar listrik",
  "merchant_qris": "00020126370014com.example"
}

C. WITHDRAWAL (ATM)
{
  "account_id": 1,
  "category": "withdrawal",
  "amount": 200000,
  "description": "Tarik tunai"
}

Response (200):
{
  "detail": "Transaction completed successfully.",
  "transaction_id": 2,
  "new_balance": 650000,
  "saku_balance": 650000
}

⚠️  Balance harus cukup, hanya dari Saku Utama
```

---

## 4. INTERNAL TRANSFER (Antar Saku)

```
POST /api/banking/internal-transfer/
Authorization: Bearer {auth_token}
Content-Type: application/json

A. TRANSFER: Saku Utama → Saku Nabung ✅ (BERHASIL)
{
  "account_id": 1,
  "source_saku_id": 1,
  "destination_saku_id": 2,
  "amount": 150000,
  "description": "Simpan ke Saku Nabung"
}

Response (200):
{
  "detail": "Internal transfer completed successfully.",
  "transaction_id": 3,
  "source_saku": {
    "id": 1,
    "name": "Saku Utama",
    "balance": 500000
  },
  "destination_saku": {
    "id": 2,
    "name": "Saku Nabung",
    "balance": 150000
  },
  "amount_transferred": 150000
}

---

B. TRANSFER: Saku Nabung → Saku Utama ❌ (GAGAL)
{
  "account_id": 1,
  "source_saku_id": 2,
  "destination_saku_id": 1,
  "amount": 50000
}

Response (400):
{
  "detail": "Cannot transfer FROM Saku Nabung. Saku Nabung is for savings only."
}

---

C. TRANSFER: Balance Tidak Cukup ❌ (GAGAL)
{
  "account_id": 1,
  "source_saku_id": 1,
  "destination_saku_id": 2,
  "amount": 999999999
}

Response (400):
{
  "detail": "Insufficient balance in source Saku."
}

💡 Hanya Saku Utama bisa mengirim ke Saku lain
   Saku Nabung hanya bisa terima dari Saku Utama
```

---

## 5. GET ACCOUNT DETAILS (Verification)

```
GET /api/banking/account-details/
Authorization: Bearer {auth_token}

(no body)

Response (200):
[
  {
    "id": 1,
    "user_id": 1,
    "user_name": "Victor Marlin",
    "account_number": "123456789012",
    "card_number": "4000123456789012",
    "balance": "400000"
  }
]

💡 Check balance setelah setiap transaksi
```

---

## 🔄 TESTING FLOW

```
1. Register Bank Account → account_id: 1
   ↓
2. Tambah Dana (500000) → balance: 500000
   ↓
3. Tambah Dana (250000) → balance: 750000
   ↓
4. Transaction Transfer (100000) → balance: 650000
   ↓
5. Internal Transfer UTM→NAB (150000)
   → Utama: 500000, Nabung: 150000
   ↓
6. Account Details → verify balance: 500000
```

---

## ⚠️ ERROR CODES

| Status | Meaning                                                       |
| ------ | ------------------------------------------------------------- |
| 200    | ✅ Success                                                    |
| 201    | ✅ Created                                                    |
| 400    | ❌ Bad Request (e.g., insufficient balance, invalid category) |
| 401    | ❌ Unauthorized (invalid/missing token)                       |
| 404    | ❌ Not Found (account/saku tidak ada)                         |

---

## 🎯 KEY POINTS

✅ **Tambah Dana:** External input → Saku Utama
✅ **Transaksi Eksternal:** Transfer/QRIS/Withdraw hanya dari Saku Utama
✅ **Internal Transfer:** Saku Utama → Saku lain (Nabung bisa terima, tidak bisa kirim)
✅ **Auto:** Transaction history + Cashflow update otomatis

---

## 📝 Postman Collection Files

```
/ikebank/postman/collections/IKEBank Banking/

0) Register Bank Account.request.yaml
1) Tambah Dana (External Deposit).request.yaml
2) Transaksi Eksternal (Transfer-QRIS-Withdrawal).request.yaml
3) Internal Transfer (Antar Saku).request.yaml
4) Account Details (Verifikasi).request.yaml
```

Atau import dari file YAML yang sudah siap di `/ikebank/postman/`
