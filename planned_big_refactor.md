# Planned Big Refactor — Bug Fixes & Caching

**Branch:** `feat/spec-08-09-profile-push`  
**Session started:** 2026-05-26

---

## What's Done

### Tests written (RED phase)
- `test/providers/product_provider_test.dart` — TTL caching + cache-first detail lookup
- `test/providers/catalog_provider_test.dart` — brands/categories fetch + slug resolution
- `test/providers/address_list_notifier_test.dart` — non-autoDispose address list + refresh
- `test/providers/profile_persistence_test.dart` — updateProfile rethrows + calls refreshProfile

### Production code implemented

| File | Change |
|------|--------|
| `lib/data/repositories/product_repository.dart` | Added `getBrands()` + `getCategories()` to abstract + impl |
| `lib/providers/product_provider.dart` | Rewrote with 5-min TTL caching + cache-first `productDetailProvider` (no autoDispose) |
| `lib/providers/catalog_provider.dart` | **New** — `brandsProvider`, `categoriesProvider`, `brandSlugForIdProvider`, `categorySlugForIdProvider` |
| `lib/providers/address_provider.dart` | Converted `addressListProvider` from `FutureProvider.autoDispose` → `AsyncNotifierProvider` with `refresh()` |
| `lib/providers/auth_provider.dart` | `updateProfile` rethrows on error + calls `refreshProfile()` after PATCH; added `onAuthenticated` callback to load cart on login/init |
| `lib/providers/order_provider.dart` | Wrapped `build()` in try/catch to prevent raw parse errors leaking to UI |
| `lib/features/profile/profile_screen.dart` | Removed "Bantuan" menu item |
| `lib/features/projects/projects_screen.dart` | Replaced `dummyProjects` with empty list + empty state UI |
| `lib/features/home/screens/home_screen.dart` | Added `_CartBadgeButton` widget with red badge showing cart count |
| `lib/features/search/search_screen.dart` | Fixed compare button color (red when in compare); fixed filter logic to use `categorySlugForIdProvider`/`brandSlugForIdProvider` |
| `lib/features/checkout/checkout_screen.dart` | Switched `_loadAddresses()` from direct repository call → `addressListProvider.future` |
| `lib/l10n/app_id.arb` + `app_en.arb` | Added `noProjects` + `createProjectHint` keys |

---

## Remaining Work

### Step 1 — Fix remaining `flutter analyze` errors

- `checkout_screen.dart:877` — inline `FutureProvider` inside `build()` still references `addressRepositoryProvider`; replace with `addressListProvider`
- `auth_provider.dart` — `VoidCallback` requires `package:flutter/foundation.dart` import
- Run `flutter pub get` to regenerate l10n from updated ARB files (so `noProjects`/`createProjectHint` are available)

### Step 2 — Run `flutter analyze` until clean (0 errors)

### Step 3 — Run `flutter test` (RED → GREEN verification)

All 4 new test files must pass. Existing tests must not regress.

### Step 4 — Fix any test failures

### Step 5 — Final verification (verification-before-completion)

```bash
flutter analyze   # must show 0 errors
flutter test      # must show all pass
```

Evidence of both outputs required before claiming complete.

---

## Root Causes Fixed

| Bug | Root Cause | Fix |
|-----|-----------|-----|
| Cart badge missing | `cartProvider` never loaded on start; no badge widget | `_CartBadgeButton` + `onAuthenticated` callback loads cart |
| Address loading forever | `FutureProvider.autoDispose` re-fetches on every mount | Converted to `AsyncNotifierProvider` (persistent) |
| Profile edit data lost | `updateProfile` caught errors silently; PATCH returns partial object | Rethrows + calls `refreshProfile()` (GET /me) after PATCH |
| Raw error on Orders | Parse exceptions leaked as raw `AsyncError` | Wrapped in try/catch, rethrow as `ApiException` |
| Bantuan menu | Hardcoded menu item in `profile_screen.dart` | Removed |
| Projects pre-filled | Screen used `dummyProjects` directly | Replaced with empty list + empty state |
| Compare button not red | `IconButton` color never checked `compareProvider` | Watch `compareProvider`, use red when `isInCompare` |
| Beli from Compare fails | `productDetailProvider` always fetched from API (rate limited) | Check `productListProvider` cache first |
| Filters broken | Filter matched `p.category.slug` which is always `''` (API returns flat IDs) | Use `categorySlugForIdProvider(p.categoryId)` from catalog cache |
| Rate limit exceeded | No caching; every navigation re-fetched products | 5-min TTL on `ProductListNotifier`; brands/categories fetched once |
