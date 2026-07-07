# Plan: Resolve All Remaining Play Store Release Items

## Prerequisites

Before executing any phase, load these skills:
- `performance` — optimization patterns (sendTimeout, asset cleanup, build verification)
- `ui-ux-pro-max` — UI/UX design intelligence (i18n patterns, accessibility, touch targets, form UX)

## Context

The `otomasiku_release_candidates.md` was updated on 2026-06-16 to reflect actual code state. RC1 (Blockers), RC2 (Android Polish), and RC3 (Payment Gaps) are all resolved. **RC4 (Code Quality) has 4 items remaining, and RC5 (Nice to Have) has 6+ items remaining.** This plan resolves all of them.

---

## Phase 1: ARB Key Additions (Q1 + S10 + extras for register/payment)

Add 19 new key pairs to `app_id.arb` and `app_en.arb`. All subsequent string replacements depend on these keys existing.

**Files:** `lib/l10n/app_id.arb`, `lib/l10n/app_en.arb`

| Key | ID Value | EN Value | Placeholder |
|-----|---------|----------|-------------|
| `loginSubtitle2` | `Masuk dengan akun Anda...` | `Sign in to your account...` | No |
| `registerNow` | `Daftar Sekarang` | `Register Now` | No |
| `loginWithGoogle` | `Masuk dengan Google` | `Sign in with Google` | No |
| `errorInvalidEmail` | `Format email tidak valid` | `Invalid email format` | No |
| `registerSuccessTitle` | `Registrasi Berhasil!` | `Registration Successful!` | No |
| `registerSuccessBody` | `Link konfirmasi telah dikirim ke {email}...` | `A confirmation link has been sent to {email}...` | `{email}` |
| `addressSaved` | `Alamat berhasil disimpan` | `Address saved successfully` | No |
| `addressAdded` | `Alamat berhasil ditambahkan` | `Address added successfully` | No |
| `paymentVaTransferFrom` | `Transfer dari rekening BCA mana saja` | `Transfer from any BCA account` | No |
| `paymentAccountHolder` | `Atas Nama` | `Account Holder` | No |
| `paymentType` | `Jenis` | `Type` | No |
| `paymentAutoVerify` | `Pembayaran akan diverifikasi otomatis...` | `Payment will be verified automatically...` | No |
| `supportNeedHelp` | `Butuh bantuan?` | `Need help?` | No |
| `supportContactPhone` | `Hubungi tim kami di 021-1234-5678` | `Contact us at 021-1234-5678` | No |
| `notificationOrderUpdates` | `Update Pesanan` | `Order Updates` | No |
| `notificationOrderUpdatesDesc` | `Notifikasi perubahan status pesanan` | `Notifications for order status changes` | No |
| `notificationPaymentDesc` | `Konfirmasi pembayaran` | `Payment confirmation` | No |
| `languageLabelId` | `ID` | `ID` | No |
| `languageLabelEn` | `EN` | `EN` | No |

Run `flutter gen-l10n` after.

---

## Phase 2: Replace Hardcoded Strings (Q1 + S10)

### 2a. `lib/features/auth/login_screen.dart`
- Already imports `AppLocalizations`, has `l10n` variable
- Replace: `'Selamat Datang!'` → `l10n.loginTitle`, subtitle → `l10n.loginSubtitle2`, `'Daftar Sekarang'` → `l10n.registerNow`, `'Masuk dengan Google'` → `l10n.loginWithGoogle`, `'Masuk'` → `l10n.loginButton`, `'Ingat saya'` → `l10n.rememberMe`, `'Lupa password?'` → `l10n.forgotPassword`, `'atau'` → `l10n.or`, `'Belum punya akun?'` → `l10n.noAccount`, form field hints & validation messages → existing ARB keys

### 2b. `lib/features/auth/register_screen.dart`
- **Add import** for `AppLocalizations`, add `l10n` variable in `build()`
- Replace ~15 hardcoded strings: title, subtitle, field labels, validation messages, button text, success dialog
- Uses new keys: `errorInvalidEmail`, `registerSuccessTitle`, `registerSuccessBody`

### 2c. `lib/features/address/edit_address_screen.dart`
- Already uses `l10n`. Replace line 111: `'Alamat berhasil disimpan'` / `'Alamat berhasil ditambahkan'` → `l10n.addressSaved` / `l10n.addressAdded`

### 2d. `lib/features/payment_methods/payment_methods_screen.dart`
- Already imports `l10n`. Replace ~14 hardcoded strings with new + existing ARB keys
- Key change: ATM/m-Banking/KlikBCA step lists must change from `const` to runtime lists using `l10n.atmStep1`..`atmStep4`, `l10n.mbankingStep1`..`mbankingStep4`, `l10n.ibankingStep1`..`ibankingStep4`
- Replace hardcoded `'PT Otomasiku Indonesia'` with `EnvConfig.bcaAccountName` (partially fixes S6)

### 2e. `lib/features/profile/settings_screen.dart`
- Replace `'ID'` → `l10n.languageLabelId`, `'EN'` → `l10n.languageLabelEn`

### 2f. `lib/core/notifications/notification_channels.dart`
- **Leave as-is** — `const` objects used for Android system channel registration, no BuildContext available
- Add code comment explaining intentional hardcoding

### 2g. `lib/core/notifications/notification_service.dart`
- Replace duplicate `'Update Pesanan'` string with `orderUpdatesChannel.name` reference (single source of truth)

### 2h. `lib/core/utils/whatsapp_helper.dart`
- **Leave as-is** — no BuildContext, messages addressed to Indonesian admin team
- Add code comment explaining decision

---

## Phase 3: Fix `_ToStringConverter` (Q2)

### 3a. Create shared converter
**New file:** `lib/core/converters/to_string_converter.dart`
```dart
class ToStringConverter implements JsonConverter<String, dynamic> {
  const ToStringConverter();
  @override
  String fromJson(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    throw ArgumentError('Expected non-null value for String field');
  }
  @override
  dynamic toJson(String value) => value;
}
```

### 3b. Update 3 model files
- `lib/models/address.dart` — import shared converter, change `@_ToStringConverter()` → `@ToStringConverter()`, delete local `_ToStringConverter` class
- `lib/models/cart_item.dart` — same pattern
- `lib/models/order.dart` — same pattern

Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `.g.dart` files.

---

## Phase 4: Fix Risky `as List` Casts (Q3)

Apply safe-cast pattern to all repositories:
```dart
// BEFORE: final items = (data['data'] as List<dynamic>).map(...)
// AFTER:
final rawData = data['data'];
if (rawData is! List) throw ApiException(code: 'INVALID_RESPONSE', statusCode: 0);
final items = rawData.cast<Map<String, dynamic>>().map((e) => Order.fromJson(e)).toList();
```

**Files to change:**
- `lib/data/repositories/order_repository.dart` — lines 47, 137
- `lib/data/repositories/address_repository.dart` — line 33
- `lib/data/repositories/cart_repository.dart` — line 45
- `lib/data/repositories/product_repository.dart` — lines 47, 87, 100

---

## Phase 5: Add `kDebugMode` Guard (Q6)

**File:** `lib/main.dart` line 75
```dart
// BEFORE:
debugPrint('[Zone] Uncaught error: $error');
// AFTER:
if (kDebugMode) {
  debugPrint('[Zone] Uncaught error: $error');
}
```
`kDebugMode` already available from existing `package:flutter/foundation.dart` import.

---

## Phase 6: RC5 Nice-to-Have Items

| Item | File | Action |
|------|------|--------|
| **S1** | `pubspec.yaml` | Remove `- assets/images/profile/` from assets (empty dir) |
| **S4** | `.env`, `env_config.dart` | Rename env var from `WHATSAPP_NUMBER` to `ADMIN_WHATSAPP_NUMBER`, change fallback from `'6281252078076'` to `'CHANGE_ME'` (already done in `.env` + `env_config.dart`) |
| **S7** | `app_router.dart` | Delete 6 dead Placeholder widget classes (lines 341-378) |
| **S3** | `api_client.dart` | Add `sendTimeout: const Duration(seconds: 30)` to Dio BaseOptions |
| **S6** | `.env`, `.env.example`, `env_config.dart` | **Align company name** — user confirmed correct name is `PT. Abadi Bangun Bersama (Otomasiku.com)`. Change `BCA_ACCOUNT_NAME` in `.env` and `.env.example` and `env_config.dart` fallback from `PT Otomasiku Nusantara` → `PT. Abadi Bangun Bersama (Otomasiku.com)`. Hardcoded `'PT Otomasiku Indonesia'` in payment_methods_screen.dart already replaced by `EnvConfig.bcaAccountName` in Phase 2d. ARB QRIS merchant name already correct. |
| **S10** | — | Already covered in Phase 2e |
| **S11** | — | **Skip** — auto-generated Flutter gen-l10n code, overwritten on regen |

### Explicitly skipped
- **S2** (fastlane): Post-launch
- **S5** (Firebase non-Android): v1 is Android-only
- **S8, S9**: Already fixed

---

## Phase 7: Regenerate & Verify

```bash
./rtk.exe flutter gen-l10n
./rtk.exe dart run build_runner build --delete-conflicting-outputs
./rtk.exe flutter analyze          # zero errors, zero warnings
./rtk.exe flutter build apk --release  # confirm no build errors
```

Manual smoke test: navigate login → register → settings (language toggle) → payment methods → address edit. Confirm text renders in both ID and EN.

---

## Dependency Order

```
Load skills (performance + ui-ux-pro-max)
  ↓
Phase 1 (ARB keys) ──→ Phase 2 (string replacements) ──→ Phase 7 (verify)
Phase 3 (ToStringConverter) ──→ Phase 7
Phase 4 (as List casts) ──────────────────────────────────→ Phase 7
Phase 5 (kDebugMode) ─────────────────────────────────────→ Phase 7
Phase 6 (RC5 items) ──────────────────────────────────────→ Phase 7
```

Skills must be loaded before any phase. Phases 3–6 are independent of 1–2 and can run in parallel. Phase 7 must come last.

---

## Files Modified Summary

| File | Changes |
|------|---------|
| `lib/l10n/app_id.arb` | +19 new keys |
| `lib/l10n/app_en.arb` | +19 new keys |
| `lib/features/auth/login_screen.dart` | ~12 string replacements |
| `lib/features/auth/register_screen.dart` | +1 import, +1 l10n var, ~15 string replacements |
| `lib/features/address/edit_address_screen.dart` | 1 string replacement |
| `lib/features/payment_methods/payment_methods_screen.dart` | ~14 string replacements, const→runtime step lists |
| `lib/features/profile/settings_screen.dart` | 2 string replacements |
| `lib/core/notifications/notification_channels.dart` | Add comment (no code change) |
| `lib/core/notifications/notification_service.dart` | Reference channel constant |
| `lib/core/utils/whatsapp_helper.dart` | Add comment (no code change) |
| `lib/core/converters/to_string_converter.dart` | **NEW** — shared converter |
| `lib/models/address.dart` | Import shared converter, delete local `_ToStringConverter` |
| `lib/models/cart_item.dart` | Same pattern |
| `lib/models/order.dart` | Same pattern |
| `lib/data/repositories/order_repository.dart` | 2 safe-cast fixes |
| `lib/data/repositories/address_repository.dart` | 1 safe-cast fix |
| `lib/data/repositories/cart_repository.dart` | 1 safe-cast fix |
| `lib/data/repositories/product_repository.dart` | 3 safe-cast fixes |
| `lib/main.dart` | Add `kDebugMode` guard |
| `pubspec.yaml` | Remove empty profile asset |
| `lib/core/config/env_config.dart` | Rename `WHATSAPP_NUMBER` → `ADMIN_WHATSAPP_NUMBER`, change fallback `'CHANGE_ME'`, align BCA account name |
| `.env` | Rename `WHATSAPP_NUMBER` → `ADMIN_WHATSAPP_NUMBER`, change `BCA_ACCOUNT_NAME` to `PT. Abadi Bangun Bersama (Otomasiku.com)` |
| `.env.example` | Rename `WHATSAPP_NUMBER` → `ADMIN_WHATSAPP_NUMBER` value `CHANGE_ME`, change `BCA_ACCOUNT_NAME` example |
| `lib/core/router/app_router.dart` | Delete 6 dead Placeholder classes |
| `lib/core/network/api_client.dart` | Add `sendTimeout` |
