# Production Readiness Audit — `otomasiku-mobile`

**Date:** 2026-06-10
**Overall Verdict:** 🔴 **NOT READY** — 5 blockers. Cannot ship to Play Store without release signing, proper targetSdk, and production backend URL.

---

## 🔴 BLOCKERS — Must Fix Before Play Store Upload

| # | Issue | Location |
|---|-------|----------|
| **B1** | **Release build signed with debug keystore** — Google Play will reject the AAB/APK. `buildTypes { release { signingConfig = signingConfigs.debug } }` hardcoded. | `android/app/build.gradle.kts:40-42` |
| **B2** | **No release keystore generated** — no `.jks` / `.keystore` file exists, no `android/key.properties`. Cannot sign a release build at all. | `android/` (missing) |
| **B3** | **targetSdk likely below 35** — Google Play requires API 35 (Android 15) for new apps since Aug 2025 and app updates since Nov 2025. Uses Flutter default (`flutter.targetSdkVersion`), typically 34. | `android/app/build.gradle.kts:34` |
| **B4** | **Zero production backend configuration** — every API URL across the entire codebase points to staging Railway deployments. The `.env`, hardcoded fallbacks in `env_config.dart:9` and `bca_config.dart:12`, and `.env.example` all reference three different staging URLs. No production URL exists anywhere. | `.env:3`, `lib/core/config/env_config.dart:9`, `lib/core/constants/bca_config.dart:12` |
| **B5** | **Bare `throw Exception(errorMsg)`** in production code — interceptors/providers catch `ApiException` but this throws a generic `Exception`, skipping all typed error handling and showing users a crash screen instead of a translated error message. | `lib/core/services/api_service.dart:131` |

**Effort to fix all blockers: ~1 hour** (all are configuration/signing, not architecture changes).

### Fix Instructions

**B1+B2 — Release signing:**
```bash
# Generate keystore
keytool -genkey -v -keystore android/app/upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Create `android/key.properties`:
```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=upload
storeFile=upload.jks
```
Update `android/app/build.gradle.kts` — add before `buildTypes`:
```kotlin
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = java.util.Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

**B3 — Set targetSdk:**
In `android/app/build.gradle.kts`:
```kotlin
targetSdk = 35  // was: flutter.targetSdkVersion
```

**B4 — Production config:**
Update `.env` with production URLs. Update fallback in `lib/core/config/env_config.dart:9` from staging to production.

**B5 — Fix bare Exception:**
Replace `lib/core/services/api_service.dart:131`:
```dart
// ❌ throw Exception(errorMsg);
// ✅ throw ApiException(code: 'API_ERROR', statusCode: response.statusCode);
```

---

## 🟡 WARNINGS — Should Fix Before Real Users

### Build & Android

| # | Issue | Location |
|---|-------|----------|
| **W1** | **No adaptive Android icon** — `mipmap-anydpi-v26/` missing. App shows non-circular legacy icon on Android 8+, no masking, no visual effects. Looks unpolished. | `android/app/src/main/res/mipmap-anydpi-v26/` (missing) |
| **W2** | **App label is raw snake_case** `"otomasiku_mobile"` — shown under the launcher icon. Should be `"Otomasiku"`. | `android/app/src/main/AndroidManifest.xml:4` |
| **W3** | **ProGuard/R8 completely disabled** — no `isMinifyEnabled`, no `proguardFiles`. App ships with unobfuscated code, larger APK size, and no dead-code elimination. | `android/app/build.gradle.kts` |
| **W4** | **Duplicate JVM heap settings** — `org.gradle.jvmargs` appears twice (line 1: 8G, line 5: 2G). Gradle uses the last (2G), severely slowing builds. | `android/gradle.properties:1,5` |
| **W5** | **`POST_NOTIFICATIONS` permission not declared** — required on Android 13+ for FCM to show notifications. App has FCM configured (default channel `order_updates`) but users must manually grant permission in Settings. Add `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` to AndroidManifest. | `android/app/src/main/AndroidManifest.xml` |
| **W6** | **`android:allowBackup` not set** — defaults to `true`. User data may be backed up to Google Drive including app preferences. Add `android:allowBackup="false"` or configure auto-backup rules. | `android/app/src/main/AndroidManifest.xml` |
| **W7** | **Deep link scheme mismatch** — `android:scheme="io.otomasiku.app"` in manifest doesn't match `applicationId="com.otomasiku.app"`. | `android/app/src/main/AndroidManifest.xml:32` |
| **W8** | **Google Services plugin outdated** — `4.3.15` (latest is `4.4.2`). Same for Firebase Performance `1.4.1` and Crashlytics `2.8.1`. | `android/settings.gradle.kts:24-26` |
| **W9** | **Splash screen still default Flutter white** — `launch_background.xml` not customized for brand. | `android/app/src/main/res/drawable/launch_background.xml` |

### Flutter / Dart Code

| # | Issue | Location |
|---|-------|----------|
| **W10** | **`debugPrint` without `kDebugMode` guard** — stack traces leak to release build logs from the uncaught error handler. | `lib/main.dart:75` |
| **W11** | **10 hardcoded Indonesian strings in 7 files** — ARB keys exist for most but are unused. Breaks English localization for search, registration, hero banner, payment methods. | See table below |
| **W12** | **2-second blind delay in cart provider** — `await Future.delayed(Duration(seconds: 2))` to retry after bootstrap not-yet-ready. Fragile; should use a proper retry-with-backoff or bootstrap-completion signal. | `lib/providers/cart_provider.dart:138` |
| **W13** | **`_ToStringConverter` masks JSON type mismatches** — `fromJson(dynamic) => toString()` silently converts nulls to `"null"` strings. Used in 3 models (CartItem, Order, Address). | `lib/models/cart_item.dart:56-63`, `order.dart:126-133`, `address.dart:42-49` |
| **W14** | **Risky `as List` cast without generic** — if API returns wrong shape, crash. Also `result as String?` in checkout GoRouter return value. | `lib/data/repositories/order_repository.dart:46,134`, `lib/features/checkout/checkout_screen.dart:182` |
| **W15** | **`StackTrace.current` captures interceptor frame, not caller** — reduces Crashlytics debugging usefulness for API errors. | `lib/core/network/api_interceptor.dart:74-75` |

### W11 Detail — Hardcoded Indonesian Strings

| Location | String | ARB Key Available? |
|----------|--------|---------------------|
| `lib/features/search/search_screen.dart:343-347` | `'Relevansi'`, `'Harga Terendah'`, `'Harga Tertinggi'`, `'Nama A-Z'`, `'Nama Z-A'` | Yes (`sortRelevance`, `sortPriceLow`, `sortPriceHigh`, `sortNameAsc`, `sortNameDesc`) but unused |
| `lib/features/auth/register_screen.dart:436` | `'Anda harus setuju dengan Syarat & Ketentuan'` | Yes (`agreeTermsRequired`) but unused |
| `lib/features/auth/register_screen.dart:479` | `'Registrasi Berhasil!'` | No — needs new ARB key |
| `lib/features/auth/register_screen.dart:483-484` | `'Link konfirmasi telah dikirim ke ${_emailController.text}. Silakan cek email Anda dan klik link konfirmasi untuk mengaktifkan akun.'` | No — needs new ARB key with parameter |
| `lib/features/auth/register_screen.dart:496` | `'Ke Halaman Login'` | Yes (`goToLogin`) but unused |
| `lib/features/home/widgets/hero_banner.dart:197` | `'Lihat Detail'` | Yes (`viewDetails`) but unused |
| `lib/features/profile/profile_screen.dart:389` | `'Sedang keluar...'` | No — needs new ARB key |
| `lib/features/payment_methods/payment_methods_screen.dart:247-280` | ATM/m-banking/i-banking step instructions (10 strings) | Yes (`atmStep1-4`, `mbankingStep1-4`, `ibankingStep1-4`) but unused |
| `lib/features/checkout/widgets/checkout_payment_method_section.dart:113-146` | Duplicate of above ATM/banking instructions | Same ARB keys unused |

---

## 🟢 SUGGESTIONS — Nice to Have

| # | Issue | Location |
|---|-------|----------|
| **S1** | `assets/images/profile/` declared in `pubspec.yaml:89` but empty — bundle includes nothing from this folder. Either add profile assets or remove the declaration. | `pubspec.yaml:89` |
| **S2** | No `android/fastlane/` — manual Play Store upload every release. Consider setting up fastlane for automated deployment. | `android/fastlane/` (missing) |
| **S3** | No `sendTimeout` configured on Dio — large file uploads (e.g., payment proofs) would only time out at receive stage. Add `sendTimeout: Duration(seconds: 30)`. | `lib/core/network/api_client.dart:24-31` |
| **S4** | WhatsApp phone number hardcoded `+6281252078076` — requires code change if number changes. Consider moving to `.env`. | `lib/core/utils/whatsapp_helper.dart:4` |
| **S5** | Firebase only configured for Android — iOS/web/macOS/Linux/Windows all throw `UnsupportedError`. Remove or add placeholder stubs if multi-platform is planned. | `lib/firebase_options.dart:29-47` |
| **S6** | `BCA_ACCOUNT_NAME` mismatch — `.env` has `PT. Abadi Bangun Bersama`, `.env.example` has `PT Otomasiku Nusantara`. Confirm which is correct for production. | `.env:5`, `.env.example:10` |
| **S7** | Placeholder widgets in `app_router.dart` (6 unused `Placeholder*` classes: `PlaceholderCheckout`, `PlaceholderShipping`, `PlaceholderPayment`, `PlaceholderPaymentSuccess`, `PlaceholderOrderDetail`, `PlaceholderCompare`) — dead code. | `lib/core/router/app_router.dart:326-364` |
| **S8** | Dummy BCA VA number `1234567890` in `.env` — should be updated for production if BCA VA is still in use. | `.env:4` |
| **S9** | Deep link `io.otomasiku.app://login-callback` hardcoded in 2 files — should be configurable via `.env` for different environments (staging vs production). | `lib/features/profile/settings_screen.dart:441`, `lib/features/auth/forgot_password_screen.dart:208` |
| **S10** | Language code labels `'ID'` / `'EN'` hardcoded in settings SegmentedButton — not translatable. | `lib/features/profile/settings_screen.dart:514-515` |
| **S11** | `app_localizations.dart` line 2450: auto-generated `throw FlutterError('...')` in `asErrorL10n` subclass. No caller uses this path today, but worth cleaning up if the auto-generated code is regenerated. | `lib/l10n/app_localizations.dart:2450` |

---

## ✅ Positive Findings — Already Production-Ready

### Security
- Token storage uses `flutter_secure_storage` exclusively — no secrets in `shared_preferences`
- `shared_preferences` used only for theme preference (non-sensitive), per conventions
- `.env` is gitignored
- Supabase uses PKCE auth flow (`AuthFlowType.pkce`)
- No `SERVICE_ROLE` key detected anywhere in client code
- Firebase API key is public by design (per Firebase docs)
- All debug logging properly gated behind `kDebugMode` (except W10)

### Code Quality
- Zero `print()` statements in `lib/`
- No `import 'package:flutter/material.dart'` in model files — models are pure Dart
- All `Image.network` usages use `CachedNetworkImage` with `errorWidget` fallback
- No `dynamic` types outside standard JSON parsing
- Zero TODO/FIXME/HACK comments — all features completed

### Error Handling
- `debugShowCheckedModeBanner: false` — no debug banner in release
- 401 handling with single token refresh + graceful session expiry → login redirect
- Error codes from Express translated client-side via `translateErrorCode()` in `core/utils/error_handler.dart`
- `runZonedGuarded` catches uncaught async errors and routes them to Crashlytics
- All repositories throw typed `ApiException` (except B5)
- Dio timeouts configured: 10s connect, 30s receive

### i18n
- All 387 ARB keys perfectly matched between `app_id.arb` and `app_en.arb` — zero missing
- `nullable-getter: false` in `l10n.yaml` — no null-safety issues on `AppLocalizations.of(context)`
- ARB codegen runs automatically with `flutter pub get`

### Assets & Icons
- All 5 Android launcher icon densities present (`mdpi` through `xxxhdpi`)
- All 19 iOS app icon sizes present and matched in `Contents.json`
- QRIS image asset exists at `assets/images/qris/qris_code.png` and declared in pubspec
- All product image subfolders declared in pubspec and have images

---

## URL Consistency — Three Different Staging URLs

The same API base URL is referenced inconsistently across the project. All three are staging, none is production:

| Source | URL |
|--------|-----|
| `.env` (actual) | `https://otomasiku-backend-staging-2127.up.railway.app/api` |
| `env_config.dart:9` (hardcoded fallback) | `https://otomasiku-backend-staging.up.railway.app/api` |
| `bca_config.dart:12` (hardcoded fallback) | `https://otomasiku-backend-staging.up.railway.app/api` |
| `.env.example` | `https://otomasiku-api-staging.up.railway.app/api` |

**Action:** Unify on a single production URL across all sources. Remove hardcoded fallbacks or point them to production.
