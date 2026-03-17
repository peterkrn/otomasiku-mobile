# 🤖 AI Rules & Codebase Conventions
# Otomasiku Marketplace Mobile App

> These rules MUST be followed by all AI assistants (Copilot, Cursor, Claude, etc.) and human developers working on this codebase. No exceptions.

---

## 🚫 Absolute Rules — NEVER Do These

### Data & Money
1. **NEVER use `float` or `double` for monetary values.** All prices are `BigInt` (Prisma) / `int` (Dart) in the smallest currency unit (Rupiah). `Rp 19.800.000` = `19800000`.
2. **NEVER store the `SUPABASE_SERVICE_ROLE_KEY` in client code.** It is server-only (Express `.env`). The Flutter app only uses `SUPABASE_ANON_KEY`.
3. **NEVER bypass Prisma's `$transaction` for order creation.** Stock validation, order creation, stock deduction, cart clearing, and BCA VA generation MUST happen in a single atomic transaction.
4. **NEVER use `SharedPreferences` for auth tokens.** Use `flutter_secure_storage` only (Android Keystore encrypted).
5. **NEVER write raw SQL queries.** Use Prisma for all database operations. If you think you need raw SQL, you're wrong — check Prisma docs first.
6. **NEVER store BCA API credentials (`BCA_API_KEY`, `BCA_API_SECRET`, `BCA_CLIENT_ID`, `BCA_CLIENT_SECRET`, `BCA_CALLBACK_SECRET`) in client code.** These are server-only (Express `.env`). The Flutter app never communicates with BCA directly.
7. **NEVER hard delete `Product`, `Address`, or any entity referenced by historical `Order` records.** Use soft delete (`deleted_at`) so that historical order data remains intact. The `DELETE /products/:id` endpoint MUST set `deleted_at = now()`, not remove the row.
8. **NEVER create an order or payment endpoint without idempotency key validation.** If the client retries due to a network timeout, the server must not create duplicate orders or charges. See the idempotency middleware pattern below.
9. **NEVER deduct stock with a simple `update` — use atomic check-and-decrement with optimistic locking.** A plain `update({ stock: { decrement: qty } })` is vulnerable to race conditions when two users buy the last unit simultaneously. See the optimistic locking pattern below.
10. **NEVER log sensitive user data.** Do NOT log full `req.body`, customer addresses, VA numbers, payment amounts linked to identifiable users, or any PII. Log only identifiers (`userId`, `orderId`, `correlationId`).

### Architecture
11. **NEVER call Express API directly from Flutter without the auth token.** Every authenticated request MUST include `Authorization: Bearer <token>` header.
12. **NEVER let Flutter upload files directly to Supabase Storage.** All file uploads go through Express API for validation first.
13. **NEVER create a new Express endpoint without `requireAuth` or explicitly marking it as `Public`.** Default is authenticated.
14. **NEVER skip Zod validation on Express endpoints.** Every `POST`, `PUT`, `PATCH` endpoint MUST have a Zod schema.
15. **NEVER import from another feature's internal files.** Features are isolated. Use `shared/widgets/` for cross-feature UI, and `data/repositories/` for cross-feature data.
16. **NEVER prefix API routes without `/api/`.** All Express endpoints MUST use the `/api/` prefix (e.g. `/api/products`, `/api/orders`). No version segment.

### Code Quality
17. **NEVER use `any` in TypeScript.** Use proper types. If you need flexibility, use generics or union types.
18. **NEVER use `dynamic` in Dart** unless absolutely unavoidable (e.g., JSON parsing). Always parse to typed models.
19. **NEVER commit `.env` files.** Only `.env.example` with placeholder values.
20. **NEVER use `print()` in Dart for production code.** Use a proper logger or `debugPrint()` wrapped in `kDebugMode` check.
21. **NEVER use `console.log()` in Express for production.** Use Pino logger with structured JSON.
22. **NEVER expose stack traces or internal error messages to API clients.** Use `AppError` for known errors with client-safe messages. Unknown errors return a generic "Internal server error" with a `correlationId` for support.
23. **NEVER pass unsanitized user input into fields that will be displayed to other users** (e.g., product descriptions, order notes, address fields). Sanitize with `sanitize-html` or equivalent before storing.
24. **NEVER hardcode user-facing strings directly in Flutter widgets.** Every label, button text, placeholder, error message, and toast must come from `AppLocalizations.of(context)!`. No exceptions. The only allowed hardcoded strings are: product names/SKUs (these are technical identifiers, not UI copy), brand names, and series codes.
25. **NEVER send human-readable error messages from Express to the Flutter client.** Express MUST only send machine-readable `error.code` (e.g., `INSUFFICIENT_STOCK`). The Flutter layer is responsible for translating that code into the correct language using `AppLocalizations`. Sending localized text from the server breaks i18n.

---

## ✅ Mandatory Patterns — ALWAYS Do These

### Dart / Flutter

```dart
// ✅ ALWAYS: Format money using the project's currency formatter
Text(CurrencyFormatter.format(product.price))  // "Rp 19.800.000"

// ❌ NEVER: Format money manually or use double
Text("Rp ${product.price / 100}")  // WRONG — never divide, never use double
```

```dart
// ✅ ALWAYS: Use Riverpod for state management
final productListProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  return repo.getProducts();
});

// ❌ NEVER: Use setState for anything beyond simple local UI state (animations, form fields)
```

```dart
// ✅ ALWAYS: Use GoRouter for navigation with named routes
context.goNamed('productDetail', pathParameters: {'id': product.id});

// ❌ NEVER: Use Navigator.push with MaterialPageRoute directly
```

```dart
// ✅ ALWAYS: Use typed models for API responses
final product = Product.fromJson(response.data);

// ❌ NEVER: Access JSON maps directly in UI code
final name = response.data['name'];  // WRONG
```

```dart
// ✅ ALWAYS: Handle loading, error, and data states — with Crashlytics on error
ref.watch(productListProvider).when(
  data: (products) => ProductGrid(products: products),
  loading: () => const LoadingIndicator(),
  error: (err, stack) {
    // ❌ NEVER expose stack trace or raw error to user
    // Text(err.toString())  // WRONG

    // ✅ Report to Crashlytics, show friendly message
    FirebaseCrashlytics.instance.recordError(err, stack);
    return ErrorView(message: 'Gagal memuat produk. Coba lagi.');
  },
);
```

```dart
// ✅ ALWAYS: Check connectivity before API calls, show offline banner
// Use: connectivity_plus package
final connectivityResult = await Connectivity().checkConnectivity();
if (connectivityResult == ConnectivityResult.none) {
  // Show offline SnackBar / banner — do not attempt API call
  showOfflineBanner(context);
  return;
}
```

```dart
// ✅ ALWAYS: Use the Product model with all catalog fields
// See DUMMY_PRODUCT_MAPPING_PLAN.md § 7 for the full model
final product = Product(
  id: 'MIT-INV-003',
  sku: 'FR-A840-2.2K-1',
  name: 'Mitsubishi FR-A840-2.2K-1',
  brand: 'Mitsubishi',
  category: 'Inverter',
  series: 'FR-A800',
  subSeries: 'FR-A840',
  variant: '2.2kW / 400V',
  price: 15000000,           // int — NEVER double
  primaryImage: 'assets/images/products/mitsubishi/inverter/fr_a840_2_2k_1.jpeg',
  galleryImages: ['assets/images/products/mitsubishi/inverter/fr_a840_2_2k_1_gallery.jpg'],
);

// ❌ NEVER: Use placeholder URLs for product images
// Image.network('https://placehold.co/300x300')  // WRONG
```

### TypeScript / Express

```typescript
// ✅ ALWAYS: Use Zod schema for request validation
router.post('/orders', requireAuth, validate(createOrderSchema), orderController.create);

// ❌ NEVER: Access req.body without validation
const { address_id } = req.body;  // WRONG without Zod
```

```typescript
// ✅ ALWAYS: Use service layer for business logic
// routes → controller → service → Prisma
// Controllers only handle req/res. Services handle logic.

// ❌ NEVER: Put business logic directly in route handlers
router.post('/orders', async (req, res) => {
  const order = await prisma.order.create(...);  // WRONG — use service
});
```

```typescript
// ✅ ALWAYS: Use AppError for known errors
throw new AppError(409, 'INSUFFICIENT_STOCK', 'Stok tidak mencukupi');

// ❌ NEVER: Throw plain Error or return ad-hoc error responses in services
throw new Error('something went wrong');  // WRONG
```

```typescript
// ✅ ALWAYS: Return standardized error response format
// Centralized in error-handler.ts middleware — never construct manually in routes
{
  "error": {
    "code": "INSUFFICIENT_STOCK",       // machine-readable snake_case constant
    "message": "Stok tidak mencukupi",  // human-readable Bahasa Indonesia
    "details": { "available": 2, "requested": 5 },  // optional context
    "correlationId": "abc-123-def-456"  // always present — for support tracing
  }
}

// ❌ NEVER: Ad-hoc error shapes
res.status(409).json({ error: 'not enough stock' });  // WRONG — inconsistent shape
```

```typescript
// ✅ ALWAYS: Attach correlationId to every request and every log entry
// middleware/correlation.ts
app.use((req, res, next) => {
  req.correlationId = (req.headers['x-correlation-id'] as string) || crypto.randomUUID();
  res.setHeader('x-correlation-id', req.correlationId);
  next();
});

// ✅ ALWAYS: Include correlationId in every log line
logger.info({ correlationId: req.correlationId, userId: req.user.id, orderId }, 'Order created');

// ❌ NEVER: Log without correlationId — impossible to trace in production
logger.info('Order created');  // WRONG
```

```typescript
// ✅ ALWAYS: Use idempotency middleware on order creation and payment endpoints
// middleware/idempotency.ts
// Client sends: X-Idempotency-Key: <uuid> header
// Server caches the response for that key for 24h
// If same key arrives again → return cached response immediately, no duplicate processing

router.post(
  '/api/v1/orders',
  requireAuth,
  idempotency(),           // ← REQUIRED for order creation
  validate(createOrderSchema),
  orderController.create
);

// ❌ NEVER: Create order/payment endpoints without idempotency protection
// Without this: network timeout → client retries → two orders created → two VA numbers
```

```typescript
// ✅ ALWAYS: Use optimistic locking for stock deduction — atomic check-and-decrement
// services/order.service.ts (inside $transaction)
const updated = await tx.product.updateMany({
  where: {
    id: item.product_id,
    stock: { gte: item.quantity },  // ← condition checked at DB level, not app level
    version: item.product.version,  // ← optimistic lock: reject if concurrent update happened
    deleted_at: null,               // ← never process soft-deleted products
  },
  data: {
    stock: { decrement: item.quantity },
    version: { increment: 1 },
  },
});

if (updated.count === 0) {
  throw new AppError(
    409,
    'STOCK_CONFLICT',
    `Stok tidak mencukupi atau produk diperbarui bersamaan. Silakan coba lagi.`
  );
}

// ❌ NEVER: Two-step read-then-write for stock — race condition window
const product = await tx.product.findUnique(...);
if (product.stock < qty) throw ...;          // ← WRONG: another request can win between these two lines
await tx.product.update({ stock: { decrement: qty } });
```

```typescript
// ✅ ALWAYS: Log important operations — with identifiers only, never PII
logger.info({ correlationId, orderId: order.id, userId }, 'Order created');
logger.warn({ correlationId, productId, available: product.stock, requested: qty }, 'Stock insufficient');

// ❌ NEVER: Log PII, full addresses, payment amounts tied to users, full request body
logger.info({ body: req.body, user: req.user });  // WRONG — exposes PII
```

```typescript
// ✅ ALWAYS: Sanitize user-generated string content before persisting
import sanitizeHtml from 'sanitize-html';

const cleanNotes = sanitizeHtml(req.body.notes, { allowedTags: [], allowedAttributes: {} });
// Strip all HTML tags from order notes, product descriptions, address fields
```

```dart
// ✅ ALWAYS: Use AppLocalizations for ALL user-facing strings — never hardcode
// Bad:
Text('Tambah ke Keranjang')          // ❌ WRONG — hardcoded Indonesian
Text('Add to Cart')                  // ❌ WRONG — hardcoded English

// Good:
final l10n = AppLocalizations.of(context)!;
Text(l10n.addToCart)                 // ✅ renders in active locale automatically
```

```dart
// ✅ ALWAYS: Translate backend error codes in Flutter — never display raw server messages
// In Express, throw with code only:
//   throw new AppError(409, 'INSUFFICIENT_STOCK', null, { available: 2 });
//
// In Flutter, map the code to localized text:
String translateErrorCode(String code, AppLocalizations l10n, [Map? details]) {
  switch (code) {
    case 'INSUFFICIENT_STOCK':
      return l10n.errorInsufficientStock(details?['available'] ?? 0);
    case 'PRODUCT_UNAVAILABLE':
      return l10n.errorProductUnavailable;
    case 'EMPTY_CART':
      return l10n.errorEmptyCart;
    case 'STOCK_CONFLICT':
      return l10n.errorStockConflict;
    default:
      return l10n.errorGeneric;
  }
}
```

```dart
// ✅ ALWAYS: Switch language via localeProvider — persisted to secure storage
// In Profile screen or settings:
ref.read(localeProvider.notifier).setLocale('en');  // switch to English
ref.read(localeProvider.notifier).setLocale('id');  // switch to Indonesian

// The localeProvider persists the choice to flutter_secure_storage
// so it survives app restarts
```

---

## 🎨 UI/Styling Patterns

### Glass-morphism Input Fields (Dark Background Screens)

For auth screens and other dark-themed forms with glass-morphism effect:

```dart
// ✅ ALWAYS: Use this pattern for glass input fields on dark backgrounds
Widget _buildGlassInput({
  required TextEditingController controller,
  required String hintText,
  required IconData prefixIcon,
  bool obscureText = false,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.15),  // Semi-transparent background
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),  // Subtle border
      ),
    ),
    child: TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),  // White text for dark BG
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white70,  // 70% opacity for hints
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.white70,
          size: 20,
        ),
        border: InputBorder.none,
        fillColor: Colors.transparent,  // Prevent theme override
        filled: true,                   // Enable fill color
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    ),
  );
}

// ❌ NEVER: Use default Colors.black87 text on dark backgrounds
// ❌ NEVER: Forget fillColor: Colors.transparent — theme will override with white
// ❌ NEVER: Use alpha > 0.3 for borders — keeps it subtle
// ❌ NEVER: Hardcode hint colors — use Colors.white70 or withValues(alpha: 0.7)
```

### Scaffold Background for Dark Screens

```dart
// ✅ ALWAYS: Set backgroundColor on Scaffold for dark screens
return Scaffold(
  backgroundColor: Colors.black,  // Prevents white background showing through
  body: Stack(
    children: [
      // Background image with dark overlay
      // ... content
    ],
  ),
);

// ❌ NEVER: Rely on default Scaffold background — it will be white/light
```

---

## 📐 API Design Rules

1. **All routes MUST be prefixed with `/api/`.** Example: `GET /api/products`, `POST /api/orders`.
2. **Every error response MUST follow the standardized format** (see AppError pattern above).
3. **Every mutating endpoint (`POST`, `PUT`, `PATCH`) MUST have a Zod schema.**
4. **Every response MUST include the `x-correlation-id` header** for traceability.
5. **Order creation and payment endpoints MUST have idempotency key enforcement.**
6. **Pagination is MANDATORY for list endpoints.** Always support `?page=&limit=` (default limit: 20, max: 100).
7. **Health check endpoints MUST exist:**
   - `GET /health` — liveness: returns `200 { status: 'ok' }` immediately, no DB check
   - `GET /health/ready` — readiness: checks DB connection + returns `200 { status: 'ok', db: 'connected' }` or `503`

---

## 📁 File Naming Conventions

### Dart (Flutter)
- Files: `snake_case.dart` — e.g., `product_card.dart`, `cart_provider.dart`
- Classes: `PascalCase` — e.g., `ProductCard`, `CartProvider`
- Variables/functions: `camelCase` — e.g., `totalAmount`, `getProducts()`
- Constants: `camelCase` — e.g., `defaultPageSize`, `apiBaseUrl`
- Providers: `camelCase` ending with `Provider` — e.g., `productListProvider`

### TypeScript (Express)
- Files: `kebab-case.ts` or `camelCase.ts` — e.g., `order.routes.ts`, `order.service.ts`
- Classes: `PascalCase` — e.g., `AppError`
- Variables/functions: `camelCase` — e.g., `createOrder`, `getProducts`
- Constants: `SCREAMING_SNAKE_CASE` — e.g., `MAX_FILE_SIZE`, `ALLOWED_MIME_TYPES`
- Zod schemas: `camelCase` ending with `Schema` — e.g., `createOrderSchema`

### Database (Prisma)
- Tables: `snake_case` plural — e.g., `products`, `order_items`, `cart_items`
- Columns: `snake_case` — e.g., `user_id`, `total_amount`, `created_at`
- Models: `PascalCase` singular — e.g., `Product`, `OrderItem`, `CartItem`

### Product Image Assets
- Path: `assets/images/products/{brand}/{category}/{filename}.{ext}`
- Brand folders: `mitsubishi/`, `danfoss/`
- Category folders: `inverter/`, `plc/`, `hmi/`, `servo/`
- Filename convention: `{series_lowercase}_{variant}.{ext}` — e.g., `fr_a840_2_2k_1.jpeg`, `fc302_131b0001.jpg`
- Replace hyphens and dots with underscores; all lowercase
- Full mapping: see `DUMMY_PRODUCT_MAPPING_PLAN.md` § 5.1

---

## 🎨 UI Rules

1. **Primary color:** Mitsubishi Red `#E7192D` — used for CTAs, active states, brand elements
2. **Font family:** Inter — all weights from 300 to 700
3. **Background:** `#F9FAFB` (gray-50) — consistent across all screens
4. **Border radius:** `rounded-2xl` (16px) for cards, `rounded-xl` (12px) for buttons, `rounded-lg` (8px) for inputs
5. **Bottom navigation:** 5 tabs — Beranda, Cari, Proyek, Keranjang, Profil
6. **Minimum touch target:** 44x44dp for all interactive elements
7. **Price display:** Always use `CurrencyFormatter` — never format manually
8. **Stock badges:** Green for "Ready Stock", Orange for "Sisa X Unit", Red for "Habis"
9. **Indonesian language:** All user-facing text in Bahasa Indonesia
10. **Bottom padding:** All screens must have `pb-24` (96px) to account for bottom nav
11. **Product images:** Use **real product images** from `assets/images/products/` — NEVER use placeholder URLs (`placehold.co`, `via.placeholder.com`). All 125 product images are pre-mapped in `DUMMY_PRODUCT_MAPPING_PLAN.md`.
12. **Product image loading:** Use `Image.asset()` for local product images. Use `AssetImage` in `DecorationImage`. Always provide an `errorBuilder` fallback for missing assets.
13. **Offline state:** All screens that fetch data MUST show an offline banner / snackbar using `connectivity_plus` when device has no network. Do not show a spinner indefinitely.
14. **Error states:** Never show raw error messages or stack traces to users. Always show a friendly Bahasa Indonesia message + retry button.
15. **All user-facing strings MUST use `AppLocalizations`** — accessed via `AppLocalizations.of(context)!`. Define every string key in both `app_id.arb` (Indonesian) and `app_en.arb` (English) before using it. A missing key in either ARB file will cause a build failure.
16. **ARB key naming:** use `camelCase` descriptive names. Prefix error messages with `error`, screen titles with the screen name. Examples: `addToCart`, `homeTitle`, `errorInsufficientStock`, `profileMenuOrders`.

---

## 🔒 Security Rules

1. Every Express endpoint that is not explicitly `Public` MUST use `requireAuth` middleware.
2. Every Admin endpoint MUST use both `requireAuth` AND `requireAdmin` middleware.
3. Every data access in Express services MUST verify ownership: `WHERE user_id = req.user.id`.
4. File uploads MUST validate: MIME type (JPEG/PNG only), file size (max 5MB), and business rules (order ownership, order status).
5. All environment variables MUST be accessed through a typed config module, never raw `process.env`.
6. CORS MUST be configured to only allow the Flutter app domain and admin web panel origin.
7. Rate limiting MUST be applied to: order creation, BCA callback endpoint, and login-adjacent endpoints.
8. The BCA callback endpoint (`POST /payments/bca/callback`) is PUBLIC (no JWT auth) but MUST validate the HMAC-SHA256 signature from BCA using `BCA_CALLBACK_SECRET`. Reject all requests with invalid signatures.
9. **NEVER trust BCA callback payloads without signature verification.** Always validate the `X-BCA-Signature` header before processing payment confirmations.
10. BCA OAuth tokens MUST be cached server-side and refreshed before expiry. Never request a new token on every API call.
11. **Sanitize all user-generated string inputs** before persisting to the database. Use `sanitize-html` to strip HTML tags from notes, descriptions, and address fields.
12. **Never expose internal error details** (stack traces, Prisma error codes, DB column names) in API error responses. Use `AppError` with client-safe messages only.

---

## 🧪 Testing Rules

1. Every Prisma transaction (especially order creation + BCA VA generation) MUST have a corresponding test.
2. Every Zod schema MUST have validation tests for both valid and invalid inputs.
3. Currency formatting MUST be tested with edge cases: 0, large numbers, BigInt boundaries.
4. API error responses MUST be tested: 401, 403, 404, 409, 422.
5. Flutter widgets that display money MUST be widget-tested to verify correct formatting.
6. BCA callback signature verification MUST be tested: valid signature → 200, invalid/missing signature → 401, tampered payload → 401.
7. Payment expiry logic MUST be tested: order unpaid after 24h → status becomes 'expired', stock is restored.
8. **Idempotency MUST be tested:** same `X-Idempotency-Key` sent twice → second call returns cached response, no duplicate order created.
9. **Optimistic locking MUST be tested:** concurrent stock deduction for same product → exactly one succeeds, the other returns `409 STOCK_CONFLICT`.
10. **Soft delete MUST be tested:** `DELETE /products/:id` sets `deleted_at`, product does not appear in `GET /products`, but `OrderItem` relation still resolves correctly.
11. **i18n MUST be tested:** Every ARB key must exist in both `app_id.arb` and `app_en.arb` — a missing key is a build-time failure and must never reach CI. Widget tests for screens that contain user-facing strings must verify the correct `AppLocalizations` key is rendered, not a hardcoded string.
12. **Language switch MUST be tested:** switching locale via `localeProvider` updates all visible strings on screen without restart, and the choice persists after app restart.

---

## 📦 Dependency Rules

### Flutter — Approved Packages Only
- `flutter_localizations` (Flutter SDK — no version needed) — i18n delegates for Material, Widgets, Cupertino
- `flutter_riverpod` — state management
- `go_router` — navigation
- `dio` — HTTP client
- `retrofit` — type-safe API client generator
- `supabase_flutter` — Supabase SDK
- `flutter_secure_storage` — secure token storage
- `cached_network_image` — image caching (for production — Supabase Storage CDN images)
- `flutter_form_builder` — forms
- `json_annotation` + `json_serializable` — JSON serialization
- `intl` — date/number formatting
- `google_fonts` — Inter font family
- `firebase_crashlytics` — crash reporting
- `firebase_performance` — screen load time + API response time monitoring
- `connectivity_plus` — offline detection and handling

> **Milestone 2 (UI-only) note:** For the UI-only phase, product images use `Image.asset()` from local `assets/images/products/`. Do NOT add `dio`, `retrofit`, `supabase_flutter`, or `flutter_secure_storage` until backend integration phase.

> Do NOT add packages without CTO approval. Every dependency is a liability.

### Express — Approved Packages Only

> **Package manager: `pnpm`** — NEVER use `npm` or `yarn` on the backend. Always `pnpm install`, `pnpm add`, `pnpm run`. Commit `pnpm-lock.yaml`, never `package-lock.json`.

- `express` — web framework
- `@prisma/client` + `prisma` — ORM
- `zod` — validation
- `@supabase/supabase-js` — Supabase Admin SDK
- `pino` + `pino-pretty` — logging
- `multer` — file upload parsing
- `cors` — CORS middleware
- `express-rate-limit` — rate limiting
- `dotenv` — environment config
- `json2csv` — CSV export
- `helmet` — security headers
- `axios` — HTTP client (for BCA Developer API calls)
- `nodemailer` — email sending (order notifications to company)
- `node-cron` — scheduled tasks (payment expiry checks)
- `sanitize-html` — strip HTML from user-generated string inputs
- `crypto` (Node.js built-in) — UUID generation for correlation IDs, idempotency key storage

> Do NOT add packages without CTO approval.

---

## 🔀 Git Rules

1. **Branch naming:** `feat/OMA-XX-description`, `fix/OMA-XX-description`, `chore/description`
2. **Commit messages:** `feat(OMA-XX): add product list endpoint` — follow Conventional Commits
3. **Never commit to `main` directly.** Always use feature branches + PR.
4. **Every PR must pass:** TypeScript compile (no errors), Prisma generate (no drift), lint check.
5. **`.env` files are in `.gitignore`.** Only `.env.example` is committed.
6. **Backend package manager is `pnpm`.** Never commit `package-lock.json` or `yarn.lock` — only `pnpm-lock.yaml`. If you see `node_modules/` installed by npm, delete and reinstall with `pnpm install`.
6. **Branching strategy:**
   - `main` → production (Play Store / Railway production)
   - `develop` → staging (Railway staging environment)
   - `feat/*` / `fix/*` → feature branches, merged into `develop` first via PR
   - `develop` → `main` only via a release PR, after QA sign-off
7. **Semantic versioning for APK releases:**
   - `versionName`: `MAJOR.MINOR.PATCH` (e.g. `1.0.0`) — human-readable
   - `versionCode`: auto-incrementing integer (e.g. `1`, `2`, `3`) — required by Play Store
   - Bump `versionCode` on every Play Store submission, no exceptions
8. **Every PR must include:**
   - Screenshot or screen recording of UI changes (for Flutter PRs)
   - List of test cases run
   - AI_RULES.md compliance checklist self-review
   - JIRA ticket reference in the PR title (e.g. `feat(OMA-12): add checkout screen`)