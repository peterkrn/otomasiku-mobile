# AFTER_OTOMASIKU_MOBILE_REMED.md

> **Session:** 2026-06-05 · **Phase executed:** Phase 2 — Workstream A (Zero Raw Errors)
> **Verification:** `flutter pub get` ✅ · `flutter analyze` ✅ (1 pre-existing warning) · 12 new tests pass ✅

---

## What was done

### A1 — Global `ErrorWidget.builder` safety net
- **New file:** `lib/core/errors/app_error_widget.dart`
- `AppErrorWidget(FlutterErrorDetails)` — branded, `mainAxisSize.min`, safe in any parent constraint.
- Debug mode: shows `exceptionAsString()`. Release mode: shows friendly "Terjadi kesalahan" only.
- Registered in `main.dart`: `ErrorWidget.builder = (d) => AppErrorWidget(d);`

### A2 — Global async/zone error catching
- **Modified:** `lib/main.dart`
- `runApp` wrapped in `runZonedGuarded` → zone errors → Crashlytics.
- `FlutterError.onError` → `FlutterError.presentError` + `FirebaseCrashlytics.recordFlutterFatalError`.
- `PlatformDispatcher.instance.onError` → Crashlytics `recordError(fatal: true)`.

### A3 — Reusable typed error view
- **New file:** `lib/shared/widgets/app_error_view.dart`
- `AppErrorView({required Object error, VoidCallback? onRetry})` — box widget.
- `AppErrorSliver({required Object error, VoidCallback? onRetry})` — wraps `AppErrorView` in `SliverToBoxAdapter` for `CustomScrollView` contexts.
- **Modified:** `lib/core/utils/error_handler.dart`
  - Added `ErrorL10n` abstract interface.
  - Added `errorMessageFor(Object error, ErrorL10n l10n) → String` — sealed-class switch over all `AppException` subtypes + `ApiException` code translation + unknown fallback.

### A5 — Product image-specific error state
- **Modified:** `lib/shared/widgets/product_image.dart`
- Converted `StatelessWidget` → `StatefulWidget` to support tap-to-retry (key bump).
- Added `ProductNetworkImage.detail()` named constructor.
- Detail variant shows broken-image icon + `l10n.errorImageLoad` + refresh icon + tap-to-retry.
- Debug mode appends failing URL under the message.

### A6 — Per-page error-state sweep (8 files)
All raw `Text('...')` and bare `RetryWidget` error states replaced with `AppErrorView`:

| File | Before | After |
|------|--------|-------|
| `features/checkout/widgets/address_selector.dart` | `Text('Gagal memuat alamat')` | `AppErrorView(error: e, onRetry: ...)` |
| `features/home/screens/home_screen.dart` | `RetryWidget(...)` in `SliverToBoxAdapter` | `SliverToBoxAdapter(child: AppErrorView(...))` |
| `features/order/orders_screen.dart` | `RetryWidget(...)` | `AppErrorView(...)` |
| `features/shipping/shipping_screen.dart` | Inline `Center(Column[Icon, Text, Button])` | `AppErrorView(...)` |
| `features/payment/payment_screen.dart` | Inline `Center(Column[Icon, Text, Button])` | `AppErrorView(...)` |
| `features/product_detail/product_detail_screen.dart` | `_buildErrorScreen` with inline column | `AppErrorView(...)` in Scaffold body |
| `features/order/order_detail_screen.dart` | `Center(child: Text(l10n.orderNotFound))` | `AppErrorView(error: error, onRetry: ...)` |

### A7 — Hardcoded string cleanup
Replaced 4 hardcoded Indonesian strings (AI_RULES violation) with l10n keys:

| File | Hardcoded | Key |
|------|-----------|-----|
| `product_detail_screen.dart` (×2) | `'Anda belum login. Silakan login terlebih dahulu.'` | `l10n.notLoggedIn` |
| `edit_address_screen.dart` | `'Gagal menyimpan alamat'` | `l10n.addressSaveFailed` |
| `search_screen.dart` | `'Maksimal 2 produk untuk dibandingkan'` | `l10n.compareMaxError` |
| `search_screen.dart` | `'Ditambahkan ke perbandingan'` | `l10n.addedToCompare` |

### ARB — New localization keys (both `app_id.arb` + `app_en.arb`)
| Key | EN | ID |
|-----|----|----|
| `errorOffline` | No internet connection… | Tidak ada koneksi internet… |
| `errorTimeout` | Request timed out… | Permintaan timeout… |
| `errorSessionExpired` | Your session has expired… | Sesi Anda telah berakhir… |
| `errorServer` | Server error… | Kesalahan server… |
| `errorLoadAddress` | Failed to load addresses. | Gagal memuat alamat. |
| `errorImageLoad` | Failed to load image. | Gagal memuat gambar. |
| `notLoggedIn` | You are not logged in… | Anda belum login… |
| `addressSaveFailed` | Failed to save address… | Gagal menyimpan alamat… |
| `goToLogin` | Go to Login | Ke Halaman Login |

---

## New test files

| File | Tests | Coverage |
|------|-------|----------|
| `test/core/errors/error_handler_test.dart` | 6 | `errorMessageFor` — all 5 exception types + unknown fallback |
| `test/shared/widgets/app_error_view_test.dart` | 4 | `AppErrorView` renders, fires retry, fits constrained box; `AppErrorSliver` in `CustomScrollView` |
| `test/core/errors/app_error_widget_test.dart` | 2 | `AppErrorWidget` builds without throwing in constrained + unconstrained contexts |

**All 12 new tests pass (GREEN).**

---

## Verification results

```
flutter pub get        ✅  l10n regenerated (9 new keys per locale)
flutter analyze        ✅  1 issue — pre-existing unused_local_variable in profile_screen.dart (unrelated)
flutter test (new)     ✅  12/12 pass
flutter test (full)    ⚠️  5 pre-existing failures in product_test.dart + product_repository_test.dart
                           Cause: ProductImage.id/path/sortOrder added to model before this session;
                           test fixtures missing those fields. Not introduced by Phase 2.
```

---

## Remaining work (not in Phase 2)

| Phase | Item | Status |
|-------|------|--------|
| Phase 1 | Backend: product list images, filter contract, admin order items | ⬜ Pending |
| Phase 3 | Mobile: `ProductImage` JSON casing contract, filter slugs, pagination fix | ⬜ Blocked on Phase 1 |
| Phase 2 | Pre-existing product model test failures (product_test + product_repository_test) | ⚠️ Pre-existing |

## Owner device test checklist (manual)
- [ ] Force a build error (temp throw in any widget build) → confirm branded screen, not red box. Revert.
- [ ] Airplane mode → open Home → `AppErrorView` shows offline message + retry works.
- [ ] Toggle ID ↔ EN — all new error strings are localized correctly.
- [ ] Product detail gallery broken image → "Gagal memuat gambar" tile + tap to retry.
- [ ] Cart / checkout / payment / orders error paths never show raw text.
