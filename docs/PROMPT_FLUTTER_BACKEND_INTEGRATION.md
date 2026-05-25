# Prompt: Otomasiku Flutter App — Backend Integration (Milestone 3)

## Context

You are building the **backend integration layer** for the Otomasiku Flutter mobile app. The app is a B2B and B2C industrial automation marketplace (Android) selling Mitsubishi and Danfoss products (Inverters, PLCs, HMIs, Servos).

**Current state:**
- The Flutter app (`otomasiku-mobile`) has a complete UI built with dummy data (Milestone 2 complete)
- The Express.js backend (`otomasiku-backend`) is fully implemented and deployed on Railway (Milestone 3 complete)
- The backend has 14 API sections, 41 unit tests, 13 QA integration suites — all passing
- The backend is deployed at a Railway URL with Supabase PostgreSQL (ap-southeast-2 Sydney)

**Your task:** Replace all dummy data providers with real API calls to the Express backend, implementing proper auth flow, error handling, and offline support.

---

## Architecture

```
Flutter App (Android)
  ├── Supabase Flutter SDK ──→ Supabase Auth (login/register/logout, token refresh)
  └── Dio ──→ Express API (Railway)
               ├── All business logic (orders, cart, products, admin)
               └── Prisma ORM ──→ Supabase PostgreSQL
```

**Auth flow:** Supabase Auth issues JWT tokens. The same token is sent to Express API via `Authorization: Bearer <token>` header. Express verifies it using Supabase Admin SDK.

---

## Tech Stack & Conventions

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| State Management | Riverpod (`FutureProvider`, `StateNotifierProvider`) |
| Navigation | GoRouter with named routes |
| HTTP Client | Dio (for Express API) |
| Auth | Supabase Flutter SDK (`supabase_flutter`) |
| Secure Storage | `flutter_secure_storage` (Android Keystore) |
| Image Caching | `cached_network_image` |
| Crash Reporting | `firebase_crashlytics` |
| Performance Monitoring | `firebase_performance` |
| Push Notifications | `firebase_messaging` + `flutter_local_notifications` |
| Offline Detection | `connectivity_plus` |

### Critical Rules

- **Money:** All prices are `int` in Rupiah (smallest unit). `Rp 19.800.000` = `19800000`. Format with `CurrencyFormatter.format(price)`. NEVER use `double`.
- **State:** Always handle 3 states: loading, error, data (`.when()`)
- **Errors:** Express returns `{ "success": false, "error": { "code": "MACHINE_READABLE_CODE", "correlationId": "uuid" } }`. Flutter translates `error.code` to localized message via `AppLocalizations`. NEVER display raw error messages from the server.
- **Auth tokens:** Store in `flutter_secure_storage` only. NEVER in SharedPreferences.
- **Idempotency:** Send `X-Idempotency-Key` header (UUID v4) on `POST /api/orders` and `POST /api/cart`.
- **Files:** `snake_case.dart` files, `PascalCase` classes, `camelCase` variables.
- **No `dynamic`:** Always parse JSON into typed models.
- **i18n:** All user-facing strings via `AppLocalizations.of(context)!`. No hardcoded strings in widgets.
- **Offline:** Check connectivity before API calls. Show offline banner if no network.

---

## API Reference

Base URL: `{RAILWAY_BACKEND_URL}` (configured via environment/flavor)

All authenticated endpoints require: `Authorization: Bearer <supabase_jwt_token>`

Error response format (all endpoints):
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "correlationId": "uuid",
    "details": {}
  }
}
```

### Auth

| Method | Endpoint | Auth | Body | Response |
|--------|----------|------|------|----------|
| `POST` | `/api/auth/signup` | Public | `{ "email", "password" (min 8), "fullName"? }` | `201 { success, data: { accessToken, refreshToken, expiresAt, user: { id, email } } }` — or `201 { data: { message: "check email" } }` if email confirmation enabled |
| `POST` | `/api/auth/login` | Public | `{ "email", "password" }` | `200 { success, data: { accessToken, refreshToken, expiresAt, user: { id, email } } }` |
| `POST` | `/api/auth/logout` | Customer/Admin | None | `200 { success: true }` |
| `POST` | `/api/auth/refresh` | Public | `{ "refreshToken" }` | `200 { success, data: { accessToken, refreshToken, expiresAt, user: { id, email } } }` |

**Error responses:**
```json
// 400 — Invalid input
{ "success": false, "error": { "code": "VALIDATION_ERROR", "correlationId": "uuid", "details": { "email": "Invalid email format" } } }

// 401 — Invalid credentials (login) or invalid refresh token
{ "success": false, "error": { "code": "UNAUTHORIZED", "correlationId": "uuid" } }

// 409 — Email already registered (signup)
{ "success": false, "error": { "code": "DUPLICATE_ENTRY", "correlationId": "uuid" } }

// 429 — Too many login attempts
{ "success": false, "error": { "code": "RATE_LIMIT_EXCEEDED", "correlationId": "uuid" } }
```

### Profile

| Method | Endpoint | Auth | Body/Input | Response |
|--------|----------|------|------------|----------|
| `GET` | `/api/me` | Customer/Admin | None | `200 { success, data: { id, email, role, profile: {...} } }` |
| `POST` | `/api/me/bootstrap` | Public (token in header) | None | `201 { success, data: { id, email, role, profile } }` |
| `PATCH` | `/api/me` | Customer/Admin | `{ "fullName"?, "phone"?, "companyName"?, "customerType"? }` | `200 { success, data: { ...updatedProfile } }` |
| `POST` | `/api/me/avatar` | Customer/Admin | `multipart/form-data` (jpeg/png/webp, max 2MB) | `200 { success, data: { avatarUrl } }` |

**Error responses:**
```json
// 401 — No token or invalid token
{ "success": false, "error": { "code": "UNAUTHORIZED", "correlationId": "uuid" } }

// 400 — Invalid profile fields or invalid file type/size (avatar)
{ "success": false, "error": { "code": "VALIDATION_ERROR", "correlationId": "uuid", "details": { "phone": "Invalid phone format" } } }

// 404 — Profile not found (GET /api/me before bootstrap)
{ "success": false, "error": { "code": "USER_NOT_FOUND", "correlationId": "uuid" } }
```

### Addresses

| Method | Endpoint | Auth | Body/Input | Response |
|--------|----------|------|------------|----------|
| `GET` | `/api/addresses` | Customer/Admin | Query: `includeDeleted=true|false` | `200 { success, data: [...] }` |
| `GET` | `/api/addresses/:id` | Customer/Admin | None | `200 { success, data: {...} }` |
| `POST` | `/api/addresses` | Customer/Admin | `{ "label", "recipient", "phone", "street", "city", "province", "postalCode", "isDefault"? }` | `200 { success, data: {...} }` |
| `PUT` | `/api/addresses/:id` | Customer/Admin | All fields optional | `200 { success, data: {...} }` |
| `DELETE` | `/api/addresses/:id` | Customer/Admin | None | `204` |

**Error responses:**
```json
// 400 — Missing required fields
{ "success": false, "error": { "code": "VALIDATION_ERROR", "correlationId": "uuid", "details": { "recipient": "Required" } } }

// 401 — Unauthorized
{ "success": false, "error": { "code": "UNAUTHORIZED", "correlationId": "uuid" } }

// 404 — Address not found or not owned by user
{ "success": false, "error": { "code": "ADDRESS_NOT_FOUND", "correlationId": "uuid" } }
```

### Brands & Categories

| Method | Endpoint | Auth | Response |
|--------|----------|------|----------|
| `GET` | `/api/brands` | Public | `200 { success, data: [{ id, name, slug, ... }] }` |
| `GET` | `/api/brands/:id` | Public | `200 { success, data: { id, name, slug, ... } }` |
| `GET` | `/api/categories` | Public | `200 { success, data: [{ id, name, slug, ... }] }` |
| `GET` | `/api/categories/:id` | Public | `200 { success, data: {...} }` |
| `GET` | `/api/categories/slug/:slug` | Public | `200 { success, data: {...} }` |

**Error responses:**
```json
// 404 — Brand or category not found
{ "success": false, "error": { "code": "BRAND_NOT_FOUND", "correlationId": "uuid" } }
{ "success": false, "error": { "code": "CATEGORY_NOT_FOUND", "correlationId": "uuid" } }
```

### Products

| Method | Endpoint | Auth | Input | Response |
|--------|----------|------|-------|----------|
| `GET` | `/api/products` | Public | Query: `brand`, `category`, `search`, `page`, `pageSize` | `200 { success, data: { data: [...], total, page, pageSize } }` |
| `GET` | `/api/products/:id` | Public | None | `200 { success, data: {...} }` |
| `GET` | `/api/products/slug/:slug` | Public | None | `200 { success, data: {...} }` |

**Error responses:**
```json
// 400 — Invalid query params
{ "success": false, "error": { "code": "INVALID_QUERY_PARAMS", "correlationId": "uuid", "details": { "pageSize": "Must be between 1 and 100" } } }

// 404 — Product not found
{ "success": false, "error": { "code": "PRODUCT_NOT_FOUND", "correlationId": "uuid" } }
```

### Cart

> `POST /api/cart` requires `X-Idempotency-Key` header.

| Method | Endpoint | Auth | Body | Response |
|--------|----------|------|------|----------|
| `GET` | `/api/cart` | Customer/Admin | None | `200 { success, data: { items: [...], totalItems } }` |
| `POST` | `/api/cart` | Customer/Admin | `{ "productId": number, "quantity": number (min 1) }` + `X-Idempotency-Key` header | `200 { success, data: {...} }` |
| `PUT` | `/api/cart/:id` | Customer/Admin | `{ "quantity": number (min 1) }` | `200 { success, data: {...} }` |
| `DELETE` | `/api/cart/:id` | Customer/Admin | None | `204` |
| `DELETE` | `/api/cart` | Customer/Admin | None | `204` (clear all) |

**Error responses:**
```json
// 400 — Invalid quantity or product unavailable
{ "success": false, "error": { "code": "VALIDATION_ERROR", "correlationId": "uuid", "details": { "quantity": "Must be at least 1" } } }
{ "success": false, "error": { "code": "PRODUCT_UNAVAILABLE", "correlationId": "uuid" } }
{ "success": false, "error": { "code": "INSUFFICIENT_STOCK", "correlationId": "uuid", "details": { "available": 3, "requested": 10 } } }

// 401 — Unauthorized
{ "success": false, "error": { "code": "UNAUTHORIZED", "correlationId": "uuid" } }

// 404 — Cart item not found (PUT/DELETE by id) or product not found
{ "success": false, "error": { "code": "CART_ITEM_NOT_FOUND", "correlationId": "uuid" } }
{ "success": false, "error": { "code": "PRODUCT_NOT_FOUND", "correlationId": "uuid" } }

// 409 — Duplicate idempotency key or item already in cart
{ "success": false, "error": { "code": "IDEMPOTENCY_KEY_EXISTS", "correlationId": "uuid" } }
{ "success": false, "error": { "code": "CART_ITEM_ALREADY_EXISTS", "correlationId": "uuid" } }
```

### Orders

> `POST /api/orders` requires `X-Idempotency-Key` header.

| Method | Endpoint | Auth | Body | Response |
|--------|----------|------|------|----------|
| `GET` | `/api/orders` | Customer/Admin | Query: `page`, `pageSize` | `200 { success, data: { data: [...], total, page, pageSize } }` |
| `GET` | `/api/orders/:id` | Customer/Admin | None | `200 { success, data: { ...orderDetail } }` |
| `GET` | `/api/orders/:id/status-history` | Customer/Admin | None | `200 { success, data: [{ status, changedAt, changedBy, notes }] }` |
| `POST` | `/api/orders` | Customer/Admin | `{ "addressId": "uuid", "notes"?: "string (max 500)" }` + `X-Idempotency-Key` | `201 { success, data: { orderId, orderNumber, totalAmount } }` |

**Error responses:**
```json
// 400 — Validation, empty cart, insufficient stock, or address issues
{ "success": false, "error": { "code": "VALIDATION_ERROR", "correlationId": "uuid", "details": { "addressId": "Required" } } }
{ "success": false, "error": { "code": "BAD_REQUEST", "correlationId": "uuid" } }  // e.g. cart is empty
{ "success": false, "error": { "code": "INSUFFICIENT_STOCK", "correlationId": "uuid", "details": { "productId": "uuid", "available": 2, "requested": 5 } } }
{ "success": false, "error": { "code": "PRODUCT_UNAVAILABLE", "correlationId": "uuid" } }

// 401 — Unauthorized
{ "success": false, "error": { "code": "UNAUTHORIZED", "correlationId": "uuid" } }

// 404 — Order not found (GET) or address not found (POST)
{ "success": false, "error": { "code": "ORDER_NOT_FOUND", "correlationId": "uuid" } }
{ "success": false, "error": { "code": "ADDRESS_NOT_FOUND", "correlationId": "uuid" } }

// 409 — Duplicate idempotency key
{ "success": false, "error": { "code": "IDEMPOTENCY_KEY_EXISTS", "correlationId": "uuid" } }
```

### Payment (BCA Callback — server-to-server, not called by Flutter)

The BCA callback endpoint (`POST /api/payment/bca/callback`) is called by BCA's servers, not by the Flutter app. The Flutter app polls order status via `GET /api/orders/:id` to detect payment confirmation.

**Callback error responses (for reference — BCA receives these):**
```json
// 400 — Invalid payload or signature
{ "success": false, "error": { "code": "INVALID_SIGNATURE", "correlationId": "uuid" } }
{ "success": false, "error": { "code": "VALIDATION_ERROR", "correlationId": "uuid" } }

// 404 — Order not found for the given VA number
{ "success": false, "error": { "code": "ORDER_NOT_FOUND", "correlationId": "uuid" } }
```

---

## Existing Flutter Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # Primary: #E7192D (Mitsubishi Red)
│   │   └── bca_config.dart
│   ├── notifications/
│   │   ├── notification_service.dart    # FCM init, token management, foreground handling
│   │   ├── notification_handler.dart    # Tap routing → GoRouter navigation
│   │   └── notification_channels.dart   # Android channel config (order_updates, payment)
│   ├── router/
│   │   └── app_router.dart        # GoRouter setup
│   └── utils/
│       ├── currency_formatter.dart # CurrencyFormatter.format(int) → "Rp 19.800.000"
│       ├── date_formatter.dart
│       └── error_handler.dart
├── data/
│   └── dummy/                     # ← REPLACE these with real API calls
│       ├── dummy_products.dart
│       ├── dummy_orders.dart
│       ├── dummy_cart.dart
│       ├── dummy_addresses.dart
│       ├── dummy_user.dart
│       └── dummy_projects.dart
├── features/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── splash/
│       └── splash_screen.dart
├── l10n/                          # ARB-based i18n (Indonesian + English)
├── models/
│   ├── product.dart
│   ├── order.dart
│   ├── cart_item.dart
│   ├── address.dart
│   ├── user_profile.dart
│   ├── project.dart
│   └── bca_va_response.dart
└── providers/                     # ← REFACTOR to use real API
    ├── auth_provider.dart
    ├── product_provider.dart
    ├── cart_provider.dart
    ├── order_provider.dart
    ├── payment_provider.dart
    ├── project_provider.dart
    ├── notification_provider.dart # FCM token state + permission status
    └── locale_provider.dart
```

---

## Implementation Plan

### Phase 1: Infrastructure Setup

1. Add dependencies to `pubspec.yaml`:
   ```yaml
   supabase_flutter: ^2.x.x
   flutter_secure_storage: ^9.x.x
   cached_network_image: ^3.x.x
   json_annotation: ^4.x.x
   connectivity_plus: ^6.x.x
   uuid: ^4.x.x
   firebase_crashlytics: ^4.x.x
   firebase_performance: ^0.x.x
   firebase_messaging: ^15.x.x
   flutter_local_notifications: ^18.x.x
   ```
   Dev: `json_serializable`, `build_runner`

2. Create `lib/core/config/` with environment configuration:
   - `env_config.dart` — base URL, Supabase URL, Supabase anon key (per flavor: dev/staging/prod)

3. Create `lib/core/network/`:
   - `api_client.dart` — Dio instance with interceptors (auth token injection, error mapping, retry on 401 with token refresh)
   - `api_response.dart` — Generic typed response wrapper
   - `connectivity_service.dart` — Network state monitoring

4. Create `lib/core/auth/`:
   - `auth_service.dart` — Supabase auth wrapper (login, signup, logout, token refresh, session listener)
   - `token_storage.dart` — flutter_secure_storage wrapper

### Phase 2: Models & Repositories

1. Update models in `lib/models/` to match API response shapes:
   - Add `fromJson`/`toJson` (use `json_serializable`)
   - Ensure all monetary fields are `int` (BigInt from API → int in Dart)

2. Create `lib/data/repositories/`:
   - `auth_repository.dart`
   - `product_repository.dart`
   - `cart_repository.dart`
   - `order_repository.dart`
   - `address_repository.dart`
   - `profile_repository.dart`

   Each repository calls the Dio API client and returns typed models.

### Phase 3: Provider Refactoring

Replace dummy data providers with real API-backed providers:

```dart
// Before (dummy):
final productListProvider = Provider<List<Product>>((ref) => dummyProducts);

// After (real API):
final productListProvider = FutureProvider.autoDispose.family<ProductListResponse, ProductFilter>((ref, filter) async {
  final repo = ref.read(productRepositoryProvider);
  return repo.getProducts(filter);
});
```

### Phase 4: Auth Flow

1. Initialize Supabase in `main.dart`
2. Implement login/register screens to call Supabase Auth
3. On successful auth, call `POST /api/me/bootstrap` to ensure profile exists
4. Store session tokens in flutter_secure_storage
5. GoRouter auth guard: redirect to login if no valid session
6. Auto-refresh token via Supabase SDK's `onAuthStateChange`

### Phase 5: Feature Integration

Wire up each feature screen to use real providers:
- Home/Catalog → `GET /api/products` with pagination
- Product Detail → `GET /api/products/:id`
- Cart → `GET/POST/PUT/DELETE /api/cart`
- Checkout → `POST /api/orders` (with idempotency key)
- Order History → `GET /api/orders`
- Order Detail → `GET /api/orders/:id`
- Profile → `GET/PATCH /api/me`
- Addresses → CRUD `/api/addresses`

### Phase 6: Payment Flow

The payment flow is partially implemented (BCA VA creation is NOT yet wired on the backend — `va_number` field is never populated). For now:
- After `POST /api/orders`, the order is created with status `pending`
- The Flutter app should show "Menunggu Pembayaran" and poll `GET /api/orders/:id` for status changes
- When the backend eventually wires BCA VA creation, the order response will include `va_number` and `va_expires_at`

**Stub the payment screen** to display order confirmation and status polling. Full VA display will work once the backend implements BCA VA creation.

---

## Order Status Flow

```
pending → processing (BCA confirms payment)
pending → cancelled (expired or admin cancels)
processing → shipped (admin enters resi_number)
shipped → done (admin confirms delivery)
```

---

## Error Code Mapping

The Flutter app must map these backend error codes to localized messages:

| Error Code | HTTP | Meaning | Indonesian Message |
|-----------|------|---------|-------------------|
| `UNAUTHORIZED` | 401 | No/invalid token | "Sesi berakhir. Silakan login kembali." |
| `INVALID_TOKEN` | 401 | Malformed token | "Sesi berakhir. Silakan login kembali." |
| `TOKEN_EXPIRED` | 401 | Token expired | "Sesi berakhir. Silakan login kembali." |
| `MISSING_AUTH_HEADER` | 401 | No Authorization header | "Sesi berakhir. Silakan login kembali." |
| `FORBIDDEN` | 403 | Insufficient role | "Anda tidak memiliki akses." |
| `ADMIN_ONLY` | 403 | Admin-only endpoint | "Anda tidak memiliki akses." |
| `NOT_FOUND` | 404 | Generic not found | "Data tidak ditemukan." |
| `USER_NOT_FOUND` | 404 | Profile doesn't exist | "Profil tidak ditemukan." |
| `PRODUCT_NOT_FOUND` | 404 | Product doesn't exist | "Produk tidak ditemukan." |
| `ORDER_NOT_FOUND` | 404 | Order doesn't exist | "Pesanan tidak ditemukan." |
| `ADDRESS_NOT_FOUND` | 404 | Address doesn't exist | "Alamat tidak ditemukan." |
| `CART_ITEM_NOT_FOUND` | 404 | Cart item doesn't exist | "Item keranjang tidak ditemukan." |
| `BRAND_NOT_FOUND` | 404 | Brand doesn't exist | "Brand tidak ditemukan." |
| `CATEGORY_NOT_FOUND` | 404 | Category doesn't exist | "Kategori tidak ditemukan." |
| `VALIDATION_ERROR` | 400 | Invalid input | "Data tidak valid. Periksa kembali." |
| `INVALID_REQUEST_BODY` | 400 | Malformed JSON body | "Format data tidak valid." |
| `INVALID_QUERY_PARAMS` | 400 | Bad query parameters | "Parameter tidak valid." |
| `INSUFFICIENT_STOCK` | 400 | Not enough stock | "Stok tidak mencukupi." |
| `PRODUCT_UNAVAILABLE` | 400 | Product deleted/unpublished | "Produk tidak tersedia." |
| `INVALID_STATUS_TRANSITION` | 400 | Invalid order status change | "Status pesanan tidak dapat diubah." |
| `DUPLICATE_ENTRY` | 409 | Resource already exists | "Data sudah ada." |
| `IDEMPOTENCY_KEY_EXISTS` | 409 | Duplicate request | "Permintaan sudah diproses sebelumnya." |
| `CART_ITEM_ALREADY_EXISTS` | 409 | Product already in cart | "Produk sudah ada di keranjang." |
| `ORDER_ALREADY_CANCELLED` | 409 | Order was already cancelled | "Pesanan sudah dibatalkan." |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests | "Terlalu banyak permintaan. Coba lagi nanti." |
| `INTERNAL_ERROR` | 500 | Server error | "Terjadi kesalahan. Silakan coba lagi." |
| `DATABASE_ERROR` | 500 | DB failure | "Terjadi kesalahan. Silakan coba lagi." |
| `EXTERNAL_SERVICE_ERROR` | 500 | Third-party failure | "Layanan sedang gangguan. Coba lagi nanti." |

---

## Product Data Shape (from API)

```json
{
  "id": "uuid",
  "name": "Mitsubishi FR-A820-0.4K-1",
  "slug": "mitsubishi-fr-a820-0-4k-1",
  "sku": "FR-A820-0.4K-1",
  "brand": { "id": 1, "name": "Mitsubishi", "slug": "mitsubishi" },
  "category": { "id": 1, "name": "Inverter", "slug": "inverter" },
  "series": "FR-A800",
  "subSeries": "FR-A820",
  "variant": "0.4kW / 200V",
  "price": "19800000",
  "originalPrice": "22000000",
  "stock": 15,
  "version": 3,
  "unit": "pcs",
  "minOrder": 1,
  "descriptionId": "Inverter Mitsubishi seri FR-A800...",
  "descriptionEn": "Mitsubishi FR-A800 series inverter...",
  "images": [
    { "url": "https://supabase-storage-url/...", "isPrimary": true },
    { "url": "https://supabase-storage-url/...", "isPrimary": false }
  ],
  "specifications": [...],
  "tiers": [...],
  "isPublished": true,
  "createdAt": "ISO8601",
  "updatedAt": "ISO8601"
}
```

Note: `price` and `originalPrice` come as strings (BigInt serialization). Parse to `int` in Dart.

---

## Cart Item Shape (from API)

```json
{
  "id": "uuid",
  "productId": "uuid",
  "quantity": 2,
  "productSnapshot": {
    "name": "Mitsubishi FR-A820-0.4K-1",
    "price": "19800000",
    "primaryImageUrl": "https://..."
  },
  "createdAt": "ISO8601"
}
```

The `productSnapshot` captures the price at add-to-cart time. This is the price used at checkout.

---

## Order Shape (from API)

```json
{
  "id": "uuid",
  "orderNumber": "ORD-20260525-XXXX",
  "status": "pending",
  "paymentStatus": "unpaid",
  "totalAmount": "39600000",
  "vaNumber": null,
  "vaExpiresAt": null,
  "shippingAddress": { "recipient": "...", "street": "...", ... },
  "items": [
    {
      "productId": "uuid",
      "productName": "...",
      "quantity": 2,
      "unitPrice": "19800000",
      "subtotal": "39600000"
    }
  ],
  "notes": "...",
  "resiNumber": null,
  "createdAt": "ISO8601",
  "updatedAt": "ISO8601"
}
```

---

## Key Implementation Notes

1. **Token refresh:** Use Dio interceptor. On 401 response, attempt token refresh via Supabase SDK. If refresh fails, redirect to login.

2. **Pagination:** Products and orders use cursor-based pagination (`page` + `pageSize`). Implement infinite scroll with `FutureProvider.family`.

3. **Optimistic UI:** For cart operations (add/remove/update quantity), update local state immediately and revert on API failure.

4. **Image loading:** Product images are hosted on Supabase Storage. Use `cached_network_image` with placeholder and error widgets.

5. **Pull-to-refresh:** Implement on product list, order list, and cart screens using `RefreshIndicator` + provider invalidation.

6. **Search:** `GET /api/products?search=FR-A820` — debounce 300ms before calling API.

7. **Deep linking:** GoRouter already supports it. Ensure product detail and order detail routes work with direct URLs.

8. **Logout:** Clear flutter_secure_storage, sign out Supabase, invalidate all providers, redirect to login.

---

## Phase 7: Push Notifications (Firebase Cloud Messaging)

### Overview

Push notifications notify customers when order status changes and notify admins when new orders arrive. Uses **Firebase Cloud Messaging (FCM)** — free, unlimited messages, already in the project via `firebase_crashlytics`.

### Architecture

```
Express API (Railway)
  └── firebase-admin SDK ──→ FCM ──→ Android Device
                                       └── flutter_local_notifications (foreground display)
```

**Trigger points (Express sends push):**
| Event | Recipient | Title | Body |
|-------|-----------|-------|------|
| Payment confirmed (BCA callback) | Customer | "Pembayaran Berhasil" | "Pesanan {orderNumber} telah dikonfirmasi." |
| Order status → processing | Customer | "Pesanan Diproses" | "Pesanan {orderNumber} sedang diproses." |
| Order status → shipped | Customer | "Pesanan Dikirim" | "Pesanan {orderNumber} telah dikirim. Resi: {resiNumber}" |
| Order status → done | Customer | "Pesanan Selesai" | "Pesanan {orderNumber} telah sampai." |
| New order created | Admin | "Pesanan Baru" | "Pesanan baru {orderNumber} dari {customerName}." |
| Payment confirmed | Admin | "Pembayaran Masuk" | "Pembayaran {orderNumber} sebesar {amount} telah diterima." |

### Flutter Setup

1. Add dependencies to `pubspec.yaml`:
   ```yaml
   firebase_messaging: ^15.x.x
   flutter_local_notifications: ^18.x.x
   ```

2. Create `lib/core/notifications/`:
   ```
   lib/core/notifications/
   ├── notification_service.dart      # Init FCM, request permission, handle token
   ├── notification_handler.dart      # Route notification taps to correct screen
   └── notification_channels.dart     # Android notification channel config
   ```

3. **`notification_service.dart`** responsibilities:
   - Initialize FCM on app start
   - Request notification permission (`firebase_messaging` handles Android 13+ POST_NOTIFICATIONS)
   - Get FCM device token and send to backend via `POST /api/me/device-token`
   - Listen to token refresh and update backend
   - Handle foreground messages → show local notification
   - Handle background/terminated message taps → navigate to relevant screen

4. **Device token registration:**
   ```dart
   // After successful login or on token refresh:
   final token = await FirebaseMessaging.instance.getToken();
   await apiClient.post('/api/me/device-token', data: {'token': token, 'platform': 'android'});
   ```

5. **Foreground notification display:**
   ```dart
   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     // Show local notification using flutter_local_notifications
     localNotificationsPlugin.show(
       message.hashCode,
       message.notification?.title,
       message.notification?.body,
       notificationDetails,
       payload: jsonEncode(message.data),
     );
   });
   ```

6. **Notification tap routing:**
   ```dart
   // message.data contains: { "type": "order_status", "orderId": "uuid" }
   // Route to order detail screen via GoRouter
   ```

### Express Backend Changes

1. Add `firebase-admin` to Express dependencies
2. Create `src/services/notification.service.ts`:
   - `sendToUser(userId, title, body, data)` — lookup user's FCM tokens, send via `admin.messaging()`
   - `sendToAdmins(title, body, data)` — send to all admin device tokens
3. Add `device_tokens` table:
   ```prisma
   model DeviceToken {
     id        String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
     userId    String   @db.Uuid @map("user_id")
     token     String   @unique
     platform  String   @default("android")  // "android" | "ios" (future)
     createdAt DateTime @default(now()) @map("created_at")
     updatedAt DateTime @updatedAt @map("updated_at")

     user Profile @relation(fields: [userId], references: [id], onDelete: Cascade)

     @@index([userId])
     @@map("device_tokens")
   }
   ```
4. New API endpoints:
   | Method | Endpoint | Auth | Body | Description |
   |--------|----------|------|------|-------------|
   | `POST` | `/api/me/device-token` | Customer/Admin | `{ "token": "fcm_token", "platform": "android" }` | Register/update FCM token |
   | `DELETE` | `/api/me/device-token` | Customer/Admin | `{ "token": "fcm_token" }` | Remove token on logout |

5. Integrate notification sends into existing flows:
   - `payment.service.ts` → after BCA callback confirms payment → notify customer + admins
   - `order.service.ts` → after admin updates status → notify customer

### Android Configuration

1. `android/app/google-services.json` — already present (from Crashlytics setup)
2. `android/app/src/main/AndroidManifest.xml` — add:
   ```xml
   <meta-data
     android:name="com.google.firebase.messaging.default_notification_channel_id"
     android:value="order_updates" />
   ```
3. Create notification channels in `notification_channels.dart`:
   - `order_updates` — Order status changes (high importance)
   - `payment` — Payment confirmations (high importance)
   - `general` — Other notifications (default importance)

### Notification Permission Flow

```
App Launch
  → Check if permission already granted
  → If not: show in-app explanation screen FIRST ("Aktifkan notifikasi untuk update pesanan")
  → Then request system permission
  → If denied: app works normally, user misses push updates (can enable later in Profile)
```

### Logout Cleanup

On logout, remove the device token from backend:
```dart
final token = await FirebaseMessaging.instance.getToken();
if (token != null) {
  await apiClient.delete('/api/me/device-token', data: {'token': token});
}
await FirebaseMessaging.instance.deleteToken();
```

---

## Phase 8: Supabase Realtime — Order Status (Future v2)

> **Not implemented in v1.** Documented here for architecture awareness.

When ready, subscribe to order status changes via Supabase Realtime instead of polling:
```dart
supabase.from('orders').stream(primaryKey: ['id']).eq('user_id', userId).listen((data) {
  // Update local order state when status changes
});
```

This replaces the current polling approach (`GET /api/orders/:id` every 30s on payment screen).

---

## Updated Implementation Plan Summary

| Phase | Scope | Status |
|-------|-------|--------|
| Phase 1 | Infrastructure (Dio, Supabase, secure storage, connectivity) | Ready |
| Phase 2 | Models & Repositories | Ready |
| Phase 3 | Provider Refactoring (dummy → real API) | Ready |
| Phase 4 | Auth Flow (Supabase Auth + bootstrap) | Ready |
| Phase 5 | Feature Integration (all screens) | Ready |
| Phase 6 | Payment Flow (BCA VA display + polling) | Ready |
| Phase 7 | Push Notifications (FCM) | **New — implement after Phase 6** |
| Phase 8 | Supabase Realtime (future v2) | Deferred |

---

## What NOT to Implement Yet

- Supabase Realtime order status updates (Phase 8 — v2)
- iOS push notifications (Android only for v1)
- Admin features in mobile app (admin uses Flutter Web panel)
- Product comparison feature
- Project/saved lists feature (keep dummy for now)
- PPN / volume discount calculation
