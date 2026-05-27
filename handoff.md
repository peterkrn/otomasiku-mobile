# Handoff — API Integration & Model Alignment

**Branch:** `feat/spec-08-09-profile-push` · **Base:** `master` (merged through PR #8)

---

## What's Done This Session

### 1. Firebase Setup (merged via PR #8)
- `firebase_core`, `firebase_crashlytics`, `firebase_performance`, `firebase_messaging` added
- `Firebase.initializeApp()` in `main.dart`
- `android/build.gradle.kts` (root) created — was missing entirely
- `android/app/build.gradle.kts` rewritten — had wrong content
- `android/settings.gradle.kts` fixed — syntax error + FlutterFire plugins
- `google-services.json` configured for `com.otomasiku.app`
- `lib/firebase_options.dart` generated

### 2. API Base URL Fixed
- Changed from `https://otomasiku-api-staging.up.railway.app/api` to `https://otomasiku-backend-staging.up.railway.app/api`
- `ApiClient.dio.baseUrl` was empty string `''` — now reads from `EnvConfig.apiBaseUrl`

### 3. Product Model Aligned to Actual API
**Problem:** Model expected nested `brand`/`category` objects + `images` array + `id` as String. API returns flat `brandId`/`categoryId` ints, no images, `id` as int.

**Fix:**
- `Product.id` → `int` (added `idString` getter for UI)
- `brand`/`category` → `brandId`/`categoryId` (int) with optional `brandObj`/`categoryObj` for future nested responses
- `images` → optional, defaults to `[]`
- Convenience getters (`brand`, `category`, `primaryImageUrl`) preserved for UI compatibility
- All screen references updated from `product.id` → `product.idString`

### 4. Repository Response Parsing Fixed
All repositories had double-nesting bugs (`apiResponse.data!['data']` when `apiResponse.data` already IS the object).

| Repository | Method | Fix |
|---|---|---|
| `product` | `getProductById` | Removed `['data']` nesting |
| `order` | `getOrderById` | Removed `['data']` nesting |
| `order` | `getStatusHistory` | Changed to parse `data` as array directly |
| `order` | `createOrder` | `orderId` → `.toString()`, `totalAmount` → `BigIntStringConverter` |
| `address` | `getAddresses` | Parse `data` as array directly (not `data.data`) |
| `address` | `getAddressById/create/update` | Removed `['data']` nesting |
| `profile` | `getProfile/updateProfile` | Removed `['data']` nesting |
| `cart` | `addItem/updateItem` | Removed `['data']` nesting |

### 5. API Route Mismatches Fixed

| Issue | Before | After |
|---|---|---|
| Order status history | `/orders/$id/status` | `/orders/$id/status-history` |
| Profile update method | `PUT /me` | `PATCH /me` |
| Products page size param | `limit` | `pageSize` |
| Orders page size param | `limit` | `pageSize` |
| Cart addItem productId | sent as String | sent as `int.parse(productId)` |

### 6. Model Resilience (int/String ID handling)
API returns IDs as integers but Flutter code uses Strings for route params and state. Added `_ToStringConverter` to:
- `CartItem.id`, `CartItem.productId`
- `Order.id`, `OrderItem.productId`
- `Address.id`

### 7. UserProfile Model Updated
API returns `{ "id", "email", "role", "profile": { "fullName", "phone", ... } }` (nested). Model now handles both flat and nested `profile` field.

### 8. Dummy Data Removed
- Deleted `lib/data/dummy/dummy_products.dart`
- Deleted `lib/data/dummy/dummy_cart.dart`

### 9. Push Notifications (in progress)
- `lib/core/notifications/notification_service.dart` — FCM token management
- `lib/core/notifications/notification_handler.dart` — foreground/background message handling
- `lib/core/notifications/notification_channels.dart` — Android notification channels
- Android manifest updated with FCM permissions

### 10. Profile & Address Screens (in progress)
- `lib/features/profile/edit_profile_screen.dart` — new screen
- `lib/providers/address_provider.dart` — new provider
- `lib/features/address/edit_address_screen.dart` — updated to match new Address model
- `lib/features/shipping/shipping_screen.dart` — updated to match new Address model

---

## Current State

`flutter analyze` passes with only 2 info-level warnings (BuildContext across async gaps in checkout_screen.dart — pre-existing).

---

## Files Modified (not yet committed)

**Core:**
- `lib/core/config/env_config.dart` — API base URL
- `lib/core/network/api_client.dart` — baseUrl from EnvConfig
- `lib/core/network/api_interceptor.dart` — Crashlytics error recording
- `lib/core/router/app_router.dart` — new routes
- `lib/core/auth/token_storage.dart`
- `lib/main.dart` — Firebase init, notification init

**Models (all regenerated with build_runner):**
- `product.dart` — flat brandId/categoryId, int id
- `cart_item.dart` — _ToStringConverter for ids
- `order.dart` — _ToStringConverter for ids
- `address.dart` — _ToStringConverter for id
- `user_profile.dart` — nested profile handling

**Repositories:**
- `product_repository.dart` — pageSize param, direct data parsing
- `cart_repository.dart` — int productId, direct data parsing
- `order_repository.dart` — pageSize param, BigIntStringConverter, direct parsing
- `address_repository.dart` — array/direct data parsing
- `profile_repository.dart` — PATCH method, direct data parsing

**Screens:**
- `product_card.dart` — `product.idString`
- `product_detail_screen.dart` — `product.idString`
- `compare_screen.dart` — `product.idString`
- `search_screen.dart` — `product.idString`
- `profile_screen.dart` — updated
- `edit_address_screen.dart` — new Address model fields
- `shipping_screen.dart` — new Address model fields

**New files:**
- `lib/core/notifications/` (3 files)
- `lib/features/profile/edit_profile_screen.dart`
- `lib/providers/address_provider.dart`
- `.env.example`
- Tests in `test/`

---

## Still Pending

| Item | Status | Notes |
|---|---|---|
| FCM token registration on login | 🔲 | Wire `notificationService.registerToken()` after auth |
| Push notification deep linking | 🔲 | Navigate to order detail on tap |
| Profile screen full wiring | 🔲 | Edit profile, avatar upload |
| Address CRUD screens | 🔲 | edit_address_screen partially done |
| Brand/category filtering | 🔲 | API returns flat IDs — need to fetch brands/categories list for filter labels |
| iOS `GoogleService-Info.plist` | 🔲 | Needed for iOS builds |
| Commit & push this branch | 🔲 | All changes uncommitted |

---

## Key Architecture Decisions Made

1. **Product.id is `int` internally, `String` externally** — `idString` getter bridges the gap. All route params and provider keys use String.
2. **`_ToStringConverter`** pattern — handles API returning int IDs where Flutter expects String. Defined per-model (private) to avoid coupling.
3. **`UserProfile.fromJson` is hand-written** — handles both flat and nested `profile` object from API.
4. **Dummy data deleted** — no longer needed with real API connected.
5. **`ApiClient.baseUrl` set once** — from `EnvConfig.apiBaseUrl`, no per-request URL needed.
