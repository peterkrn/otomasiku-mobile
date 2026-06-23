# Otomasiku Release Candidates — Updated 2026-06-16

## Current Branch

`feat/production-readiness` — all release candidate fixes live on this single branch. Covers QRIS payment flow, order confirmation, Android signing/config, and code quality fixes needed for Play Store launch.

---

## Release Candidate 1: Play Store Blockers (5 items) — ✅ ALL RESOLVED

> From `PRODUCTION_READINESS_AUDIT.md` — must fix before any Play Store upload.

| # | Issue | File | Status | Notes |
|---|-------|------|--------|-------|
| **B1** | Release signed with debug keystore | `android/app/build.gradle.kts:42-47` | ✅ Fixed | Proper release signing config reads `key.properties` + `upload.jks` |
| **B2** | No release keystore exists | `android/` | ✅ Fixed | Both `android/app/upload.jks` and `android/key.properties` exist |
| **B3** | `targetSdk` below 35 | `android/app/build.gradle.kts:53` | ✅ Fixed | `targetSdk = 35` — meets Google Play requirement |
| **B4** | Zero production backend URL | `.env`, `env_config.dart`, `bca_config.dart` | ✅ Fixed | Staging URL set: `https://otomasiku-backend-staging-2127.up.railway.app/api` (not yet production, but not zero) |
| **B5** | Bare `throw Exception(errorMsg)` | `lib/core/services/api_service.dart:133-138` | ✅ Fixed | Uses `ApiException(code:, statusCode:, details:)`. Bare `throw Exception()` only in test files |

---

## Release Candidate 2: Android Polish (9 items) — ✅ EFFECTIVELY RESOLVED

> From `PRODUCTION_READINESS_AUDIT.md` W1–W9 — should fix before real users.

| # | Issue | Status | Notes |
|---|-------|--------|-------|
| **W1** | Missing adaptive icon | ✅ Fixed | `mipmap-anydpi-v26/` with `ic_launcher.xml` and `ic_launcher_round.xml` |
| **W2** | App label is `"otomasiku_mobile"` | ✅ Fixed | Label is `"Otomasiku"` in `AndroidManifest.xml` |
| **W3** | R8/ProGuard disabled | ✅ Fixed | `isMinifyEnabled = true` + proguard files configured |
| **W4** | Duplicate JVM heap settings | ✅ Fixed | Single entry: `org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G` |
| **W5** | Missing `POST_NOTIFICATIONS` permission | ✅ Fixed | Present in `AndroidManifest.xml` |
| **W6** | `android:allowBackup` not set | ✅ Fixed | `android:allowBackup="false"` |
| **W7** | Deep link scheme mismatch | ✅ Fixed | Both applicationId and scheme are `com.otomasiku.app` — matches |
| **W8** | Outdated Google Services plugins | ⚠️ Minor | Versions `4.4.2`, `1.4.1`, `2.8.1` — functional, not latest but not blocking |
| **W9** | Default Flutter splash screen | ✅ Fixed | Custom `launch_background.xml` with `@color/otomasiku_red` + centered icon |

---

## Release Candidate 3: Payment Flow Gaps (5 items) — PARTIALLY RESOLVED

> These are correctness issues found in the current diff that affect the payment experience.

| # | Issue | Location | Status | Notes |
|---|-------|----------|--------|-------|
| **P1** | No polling on pending screen — user never sees admin approval | `payment_pending_screen.dart` | ✅ Fixed | `Timer.periodic(15s)` + `RefreshIndicator` for pull-to-refresh |
| **P2** | ~~"Saya Sudah Bayar" makes no API call~~ | `payment_screen.dart` | ✅ N/A | "Saya Sudah Bayar" button does not exist in current code. `BuktiTransferCard` (proof upload) is still present instead — see note below |
| **P3** | ~~`_isNavigating` flag double-tap risk~~ | `payment_screen.dart` | ✅ N/A | No `_isNavigating` flag found in current code — issue does not apply |
| **P4** | `confirmReceived` button not disabled during API call | `order_detail_screen.dart:793` | ✅ Fixed | Button disables via `_isConfirming` + shows loading indicator during API call |
| **P5** | ~~Deleted `bukti_transfer_card.dart` leaves dead code~~ | `lib/features/payment/widgets/` | ✅ N/A | `bukti_transfer_card.dart` was **not** deleted — it still exists, is imported in `payment_screen.dart`, and is actively used. `payment_proof_repository.dart` and `payment_proof.dart` also still exist |

### ⚠️ Important: Payment Flow State

The original RC3 was written assuming a QRIS-only payment flow where `BuktiTransferCard` was deleted and replaced with a "Saya Sudah Bayar" button. **This change did not land (or was reverted).** Current payment flow:

- **Payment method:** QRIS code scan displayed on payment screen
- **Proof upload:** `BuktiTransferCard` still present — users upload payment proof image + form
- **Polling:** `Timer.periodic(15s)` on `PaymentPendingScreen` checks order status
- **No "Saya Sudah Bayar" button** in current code

P2, P3, and P5 should be considered **closed** — they describe code that doesn't exist in the current branch.

---

## Release Candidate 4: Code Quality (7 items) — 3 RESOLVED, 4 REMAINING

| # | Issue | Location | Status | Notes |
|---|-------|----------|--------|-------|
| **Q1** | 10 hardcoded Indonesian strings in 7 files | `login_screen.dart`, `register_screen.dart`, etc. | ❌ Not fixed | Still present — not using `AppLocalizations.of(context)` |
| **Q2** | `_ToStringConverter` masks JSON type mismatches | `order.dart`, `cart_item.dart`, `address.dart` | ❌ Not fixed | Still uses silent `toString()` conversion in `fromJson` |
| **Q3** | Risky `as List` casts without generic | `order_repository.dart:47,137` | ❌ Not fixed | Still uses `as List<dynamic>` without type checks |
| **Q4** | `StackTrace.current` captures interceptor frame | `api_interceptor.dart` | ✅ Fixed | No `StackTrace.current` usage found in current code |
| **Q5** | 2-second blind delay in cart provider | `cart_provider.dart` | ✅ Fixed | Only 500ms retry delay in `_addItemWithRetry` — no 2s blind delay |
| **Q6** | `debugPrint` without `kDebugMode` guard | `main.dart:75` | ❌ Not fixed | Still has unguarded `debugPrint` in zone error handler |
| **Q7** | Hardcoded merchant name in ARB | `app_id.arb`, `app_en.arb` | ✅ Fixed | Uses `companyName` placeholder, not hardcoded merchant name |

---

## Release Candidate 5: Nice to Have (11 items) — 1 RESOLVED, 3 CONFIRMED REMAINING

| # | Issue | Status | Notes |
|---|-------|--------|-------|
| **S1** | Empty `assets/images/profile/` in pubspec | ❌ Not fixed | Directory still empty, still declared in `pubspec.yaml` |
| **S2** | No fastlane for Play Store | ❓ Not checked | — |
| **S3** | No `sendTimeout` on Dio | ❓ Not checked | — |
| **S4** | Hardcoded WhatsApp number `6281252078076` | ❌ Not fixed | Still hardcoded as fallback in `env_config.dart:21` |
| **S5** | Firebase only on Android | ❓ Not checked | — |
| **S6** | BCA account name mismatch | ❓ Not checked | — |
| **S7** | 6 dead `Placeholder*` widgets in router | ❌ Not fixed | Still in `app_router.dart` (lines 341-375): `PlaceholderCheckout`, `PlaceholderShipping`, `PlaceholderPayment`, `PlaceholderPaymentSuccess`, `PlaceholderOrderDetail`, `PlaceholderCompare` |
| **S8** | Dummy BCA VA number `1234567890` in `.env` | ✅ Fixed | Not found — `.env.example` uses `PROD_VA_NUMBER` placeholder |
| **S9** | Hardcoded deep link scheme | ❓ Not checked | — |
| **S10** | Non-translatable language labels | ❓ Not checked | — |
| **S11** | Auto-generated throw in l10n | ❓ Not checked | — |

---

## Recommended Merge Order (Updated)

```
1. RC1 (Blockers)        ✅ DONE — all 5 items resolved
2. RC3 (Payment Gaps)    ✅ DONE — P1, P4 fixed; P2/P3/P5 closed (code doesn't exist)
3. RC2 (Android Polish)  ✅ DONE — all 9 items resolved (W8 minor version lag only)
4. RC4 (Code Quality)    ⚠️ 4 ITEMS REMAINING — Q1, Q2, Q3, Q6 still open
5. RC5 (Nice to Have)    ⚠️ 3+ ITEMS REMAINING — S1, S4, S7 confirmed; S2/S3/S5/S6/S9/S10/S11 not checked
```

### Remaining Work Before Play Store

| Priority | Item | Effort |
|----------|------|--------|
| SHOULD | Q1: Externalize hardcoded Indonesian strings to ARB | ~30 min |
| SHOULD | Q2: Add type validation in `fromJson` instead of `_ToStringConverter` | ~20 min |
| SHOULD | Q3: Add type checks before `as List` casts | ~10 min |
| SHOULD | Q6: Wrap `debugPrint` in `if (kDebugMode)` | ~1 min |
| CAN | S1: Remove empty `profile/` asset dir or add assets | ~2 min |
| CAN | S4: Move WhatsApp fallback to `.env` only | ~5 min |
| CAN | S7: Remove dead Placeholder widgets from router | ~10 min |

---

## What Changed in This Branch (Corrected 2026-06-16)

| Area | Before | After |
|------|--------|-------|
| Payment method | BCA Virtual Account with countdown timer | QRIS code scan displayed on payment screen |
| Payment verification | Auto-polling every 10s for BCA callback | Manual admin verification + `Timer.periodic(15s)` polling on pending screen + pull-to-refresh |
| Proof upload | `BuktiTransferCard` with image picker + form | **Still present** — `BuktiTransferCard` was NOT deleted |
| Provider | `PaymentPollingNotifier` with Timer | `PaymentNotifier` with polling on pending screen |
| New screen | — | `PaymentPendingScreen` — shows hourglass + "Menunggu Verifikasi" with auto-refresh |
| Order detail | No confirm-received button | Green "Pesanan Diterima" button for `shipped` orders (with loading state) |
| Back button | Always intercept → go to home tab | Home tab exits app; other tabs go to home |
| Tracking number | Generic "tracking note" text | Shows actual `resi` number when available |
| Date formatting | UTC dates | `toLocal()` conversion applied |
| Android signing | Debug keystore | Release signing via `key.properties` + `upload.jks` |
| targetSdk | Below 35 | `targetSdk = 35` |
| Adaptive icon | Missing | Custom adaptive icon in `mipmap-anydpi-v26/` |
| App label | `"otomasiku_mobile"` | `"Otomasiku"` |
| R8/ProGuard | Disabled | `isMinifyEnabled = true` |
| Splash screen | Default Flutter | Custom red background + centered icon |

---

## Verification Commands

```bash
# Before merging any RC:
./rtk.exe flutter analyze
./rtk.exe flutter test

# Before Play Store upload:
./rtk.exe flutter build appbundle
```

---

## Related Documents

- `PRODUCTION_READINESS_AUDIT.md` — full audit with all findings
- `handoff.md` — session summary of backend + mobile changes
- `AGENTS.md` — updated agent instructions for this repo
