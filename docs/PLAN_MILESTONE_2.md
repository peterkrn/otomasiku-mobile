# 📋 Milestone 2 Execution Plan — Flutter Complete UI (Dummy Data)
# Otomasiku Marketplace Mobile App

> **Scope:** Build ALL Flutter screens with **hardcoded dummy data and mockup images**. No Supabase. No production backend. The goal is a fully navigable app on a real Android device that the client can tap through end-to-end.
>
> **⚠️ Exception — BCA Sandbox Only:** The payment flow uses a **real mini Express backend deployed to Railway**, but ONLY for BCA Developer API Sandbox integration. This backend has exactly 2 endpoints and zero database. Everything else (auth, products, cart, orders, profile) remains hardcoded dummy data in Flutter — no backend calls whatsoever.

> **Payment Milestone:** This plan fulfills **Tahap 2 (Progres 1) — 40% / Rp 2.800.000**
> _"Tampilan aplikasi sudah bisa dicoba di HP, data masih menggunakan data contoh (dummy), & sistem pembayaran sudah bisa diuji coba (sandbox)."_

---

## ⚡ Ground Rules

1. **NO backend calls — except BCA Sandbox.** Every screen uses hardcoded data from local Dart files. The ONLY exception is the payment flow, which calls the M2 mini Express backend for BCA VA creation and status polling. No other feature touches a backend.
2. **NO Supabase SDK initialization.** Auth is faked with a simple `isLoggedIn` boolean in a Riverpod provider.
3. **USE real product images** from `assets/images/products/` (10 product images from `docs/dummy-products/`). Use `AssetImage` / `Image.asset()` — NO placeholder URLs from `placehold.co`.
4. **ALL navigation must work.** Every button, tab, and link in the mockups must navigate to the correct screen.
5. **ALL screens must be pixel-faithful** to the HTML mockups in `ui-otomasiku-marketplace/`.
6. **ALL prices use `CurrencyFormatter`** — never format manually, never use `double`.
7. Follow **AI_RULES.md** for all code conventions (Riverpod, GoRouter, snake_case files, etc.).
8. **ALL 10 products** from `DUMMY_PRODUCT_MAPPING_PLAN.md` must be present in `dummy_products.dart`.
9. **NO hardcoded user-facing strings in widgets.** Every label, button text, and error message must come from `AppLocalizations.of(context)!`. See i18n setup in Phase M2-0.
10. **BCA mini backend scope is FROZEN.** Do NOT add auth, product endpoints, order DB, or any other feature to the M2 mini backend. It has exactly 2 endpoints: create VA and callback. Nothing else.

---

## 📦 Dummy Data Catalog

All dummy data lives in `lib/data/dummy/`. These files are the single source of truth for the entire UI phase.

### Products (10 items — from DUMMY_PRODUCT_MAPPING_PLAN.md)

> **⚠️ Limited dummy catalog for Milestone 2 UI development.**
> The 10-product catalog is defined in **`docs/DUMMY_PRODUCT_MAPPING_PLAN.md`** (updated 2026-03-12).

Create `lib/data/dummy/dummy_products.dart` with **10 products** selected from the real OTOMASIKU catalog:

| Category | Count | Products |
|----------|-------|----------|
| Inverter | 5 | FR-A820-0.4K, FR-A820-2.2K, FR-D720-0.75K, FC 302, FC 051 |
| PLC | 2 | FX5U-32MT, FX3G-24MR |
| Servo | 2 | MR-J4-10B, MR-J4-10A |
| HMI | 1 | GT2103-PMBDS |

Each product includes: `id`, `sku`, `name`, `brand`, `category`, `series`, `subSeries`, `variant`, `price`, `originalPrice`, `stock`, `stockStatus`, `primaryImage` (asset path), `galleryImages` (asset paths), and `description`.

Refer to `DUMMY_PRODUCT_MAPPING_PLAN.md` § 4 for the product details and § 3 for image file mappings.

**Categories:** Inverter, PLC, Servo, HMI
**Brands:** Mitsubishi, Danfoss

### Other Dummy Data Files

| File | Contents |
|------|----------|
| `dummy_user.dart` | Single hardcoded user: John Doe, johndoe@gmail.com, PT Otomasi Indonesia, +62 812 3456 7890 |
| `dummy_addresses.dart` | 2 addresses: (1) Jl. Sudirman Kav. 28-30 Jakarta Selatan 12920 — Utama, (2) Jl. Raya Bekasi Km.25 Cakung, Jakarta Timur 13910 — Gudang |
| `dummy_cart.dart` | Pre-filled cart: FR-A820-0.4K-1 × 2, FX5U-32MT/ESS × 1 |
| `dummy_orders.dart` | 3 orders with different statuses: (1) INV-2024-8XJ2M9 — Sedang Diproses, (2) INV-2024-7KP4L2 — Dikirim, (3) INV-2024-5MN8R1 — Selesai |
| `dummy_projects.dart` | 2 projects: "Maintenance Line Conveyor 3" (4 items, Rp 58.5jt), "Upgrade Panel CNC-01" (3 items, Rp 42jt) |

---

## How to Use This Plan

Each phase has:
- **Depends On:** — which phase(s) must be complete before starting
- **Entry Criteria:** — what must be true before you start
- **Tasks:** — what to build, in order
- **Exit Criteria:** — what must be true before this phase is "done"
- **Reference:** — which HTML mockup to match

> **CRITICAL:** Each phase MUST be fully completed and visually verified on a real device / emulator before moving to the next phase. No skipping.

---

## Phase M2-0: Project Setup & Dummy Data
**Depends On:** Nothing
**Estimated Effort:** 1 day

### Entry Criteria
- [ ] Flutter SDK installed and `flutter doctor` passes
- [ ] Android emulator or physical device connected

### Tasks
1. **Initialize Flutter project**
   ```
   flutter create --org com.otomasiku otomasiku_mobile_app
   ```
2. **Add approved dependencies to `pubspec.yaml`**
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_localizations:   # i18n — official Flutter SDK package
       sdk: flutter
     intl: ^0.19.0            # date/number formatting + ARB codegen support
     flutter_riverpod: ^2.5.1
     go_router: ^13.2.0
     flutter_form_builder: ^9.3.0
     google_fonts: ^6.2.1
     dio: ^5.4.3              # HTTP client — needed for BCA mini backend calls ONLY
   flutter:
     generate: true           # REQUIRED for ARB codegen
   ```
   > ⚠️ Do NOT add: `retrofit`, `supabase_flutter`, `flutter_secure_storage` — not needed for M2.
   > `dio` is added here because the payment phase will call the M2 mini Express backend.

3. **Set up `analysis_options.yaml`** with strict rules per AI_RULES.md

4. **Set up i18n (ARB-based)**
   - Create `l10n.yaml` at project root:
     ```yaml
     arb-dir: lib/l10n
     template-arb-file: app_id.arb
     output-localization-file: app_localizations.dart
     ```
   - Create `lib/l10n/app_id.arb` (Bahasa Indonesia — primary):
     ```json
     {
       "@@locale": "id",
       "appName": "Otomasiku",
       "homeTitle": "Katalog Produk",
       "searchHint": "Cari FR-A820, FX5U, MR-J4...",
       "addToCart": "Tambah ke Keranjang",
       "buyNow": "Beli Sekarang",
       "checkout": "Checkout",
       "continueToCheckout": "Lanjut ke Checkout",
       "createInvoiceAndPay": "Buat Invoice & Bayar",
       "stockReady": "Ready Stock",
       "stockLow": "Sisa {count} Unit",
       "@stockLow": { "placeholders": { "count": { "type": "int" } } },
       "stockEmpty": "Habis",
       "paymentTitle": "Pembayaran",
       "paymentWaiting": "Menunggu Pembayaran",
       "paymentSuccess": "Pembayaran Berhasil!",
       "paymentExpiry": "Batas Waktu Pembayaran",
       "paymentVaNumber": "Nomor Virtual Account",
       "paymentCopy": "Salin",
       "paymentCopied": "Berhasil disalin",
       "paymentCheckStatus": "Cek Status",
       "errorGeneric": "Terjadi kesalahan. Silakan coba lagi.",
       "errorNetwork": "Tidak ada koneksi internet.",
       "errorBcaCreateVa": "Gagal membuat Virtual Account. Coba lagi.",
       "errorBcaVaExpired": "Virtual Account sudah kedaluwarsa.",
       "language": "Bahasa",
       "logout": "Keluar",
       "profileTitle": "Profil Saya",
       "cartTitle": "Keranjang Belanja",
       "cartEmpty": "Keranjang Kosong",
       "cartStartShopping": "Mulai Belanja"
     }
     ```
   - Create `lib/l10n/app_en.arb` (English — mirror, every key must exist):
     ```json
     {
       "@@locale": "en",
       "appName": "Otomasiku",
       "homeTitle": "Product Catalog",
       "searchHint": "Search FR-A820, FX5U, MR-J4...",
       "addToCart": "Add to Cart",
       "buyNow": "Buy Now",
       "checkout": "Checkout",
       "continueToCheckout": "Continue to Checkout",
       "createInvoiceAndPay": "Create Invoice & Pay",
       "stockReady": "Ready Stock",
       "stockLow": "{count} Units Left",
       "@stockLow": { "placeholders": { "count": { "type": "int" } } },
       "stockEmpty": "Out of Stock",
       "paymentTitle": "Payment",
       "paymentWaiting": "Awaiting Payment",
       "paymentSuccess": "Payment Successful!",
       "paymentExpiry": "Payment Deadline",
       "paymentVaNumber": "Virtual Account Number",
       "paymentCopy": "Copy",
       "paymentCopied": "Copied to clipboard",
       "paymentCheckStatus": "Check Status",
       "errorGeneric": "Something went wrong. Please try again.",
       "errorNetwork": "No internet connection.",
       "errorBcaCreateVa": "Failed to create Virtual Account. Try again.",
       "errorBcaVaExpired": "Virtual Account has expired.",
       "language": "Language",
       "logout": "Logout",
       "profileTitle": "My Profile",
       "cartTitle": "Shopping Cart",
       "cartEmpty": "Cart is Empty",
       "cartStartShopping": "Start Shopping"
     }
     ```
   - Run `flutter gen-l10n` to verify no missing keys → must produce zero errors
   - Create `lib/providers/locale_provider.dart`:
     ```dart
     import 'package:flutter_riverpod/flutter_riverpod.dart';

     final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
       (ref) => LocaleNotifier(),
     );

     class LocaleNotifier extends StateNotifier<Locale> {
       LocaleNotifier() : super(const Locale('id'));

       void setLocale(String code) => state = Locale(code);
       // Note: persistence via flutter_secure_storage added in Milestone 3
     }
     ```

5. **Create folder structure:**
   ```
   lib/
   ├── main.dart
   ├── app.dart                          # MaterialApp.router + localizationsDelegates
   ├── l10n/
   │   ├── app_id.arb                    # Indonesian — primary
   │   └── app_en.arb                    # English — must mirror every key
   ├── core/
   │   ├── constants/
   │   │   ├── app_colors.dart           # Color constants (#E7192D, #0066AE, etc.)
   │   │   ├── app_typography.dart       # Inter font styles
   │   │   └── bca_config.dart           # BCA mini backend URL config (sandbox only)
   │   ├── theme/
   │   │   └── app_theme.dart
   │   ├── router/
   │   │   └── app_router.dart
   │   └── utils/
   │       ├── currency_formatter.dart
   │       ├── date_formatter.dart
   │       └── error_handler.dart        # translateErrorCode(code, l10n) helper
   ├── data/
   │   ├── dummy/
   │   │   ├── dummy_products.dart
   │   │   ├── dummy_user.dart
   │   │   ├── dummy_addresses.dart
   │   │   ├── dummy_cart.dart
   │   │   ├── dummy_orders.dart
   │   │   └── dummy_projects.dart
   │   └── services/
   │       └── bca_payment_service.dart  # Dio calls to M2 mini backend — BCA ONLY
   ├── models/
   │   ├── product.dart
   │   ├── cart_item.dart
   │   ├── order.dart
   │   ├── address.dart
   │   ├── user_profile.dart
   │   ├── project.dart
   │   └── bca_va_response.dart          # Model for VA number + expiry from mini backend
   ├── providers/
   │   ├── auth_provider.dart
   │   ├── cart_provider.dart
   │   ├── product_provider.dart
   │   ├── order_provider.dart
   │   ├── project_provider.dart
   │   ├── locale_provider.dart          # Language switch state
   │   └── payment_provider.dart         # BCA VA state (va_number, expiry, status)
   └── features/
       └── [same as before — all screen folders]
   ```

6. **Create `bca_config.dart`** — the ONLY place BCA mini backend URL is configured:
   ```dart
   // lib/core/constants/bca_config.dart
   class BcaConfig {
     // M2 mini backend — BCA Sandbox only
     // This URL points to the Railway-deployed mini Express backend
     // Switch to production URL in Milestone 3 when full backend is ready
     static const String miniBackendBaseUrl =
         'https://otomasiku-bca-sandbox.up.railway.app'; // update after deploy

     static const Duration vaExpiry = Duration(hours: 24);
   }
   ```

7. **Create all model classes** with typed fields. Use the updated `Product` model from `DUMMY_PRODUCT_MAPPING_PLAN.md` § 7.

8. **Create all dummy data files** — `dummy_products.dart` must contain all **10 products** from `DUMMY_PRODUCT_MAPPING_PLAN.md` § 4.

9. **Register image assets in `pubspec.yaml`:**
   ```yaml
   flutter:
     assets:
       - assets/images/products/
   ```

10. **Create `CurrencyFormatter`** utility:
    ```dart
    // Output: "Rp 5.200.000" for input 5200000
    // Uses int only — NEVER double
    ```

11. **Create `AppColors`** constants:
    - `mitsubishiRed` = `Color(0xFFE7192D)`
    - `background` = `Color(0xFFF9FAFB)`
    - `bcaBlue` = `Color(0xFF0066AE)`
    - `danfossBlue` = `Color(0xFF005A8C)`

12. **Create `AppTheme`** with Inter font, Mitsubishi Red primary, gray-50 scaffold background

13. **Set up GoRouter** with all routes (stubbed to empty Scaffold for now) — same routes as original plan

### Exit Criteria
- [ ] `flutter run` launches without errors
- [ ] `flutter gen-l10n` produces zero errors — all ARB keys valid
- [ ] Language switch: tap ID→EN in Profile → all labels on screen update without restart
- [ ] All routes navigable (even if screens are empty Scaffolds)
- [ ] `CurrencyFormatter.format(5200000)` returns `"Rp 5.200.000"`
- [ ] Theme shows Mitsubishi Red and Inter font
- [ ] Dummy data loads: **10 products**, 1 user, 2 addresses, 3 orders, 2 projects
- [ ] All 10 product images exist in `assets/images/products/` and load without errors
- [ ] `pubspec.yaml` has assets directory registered
- [ ] No widget in the project contains a hardcoded user-facing string (grep for `Text('` → should only find non-UI strings like IDs)

---

## Phase M2-1: Splash, Login & Register Screens
**Depends On:** Phase M2-0 ✅
**Estimated Effort:** 0.5 day

### Entry Criteria
- [ ] Phase M2-0 Exit Criteria ALL met
- [ ] GoRouter has auth guard: if `isLoggedIn = false` → redirect to `/login`

### Tasks
1. **Splash Screen** (`splash_screen.dart`)
   - Full-screen dark background with gradient overlay
   - Mitsubishi logo icon (centered)
   - "Oseï" branding text + "Automation Spareparts Marketplace" subtitle
   - "Mulai Sekarang!" CTA button → navigates to Login
   - Reference: `ui-otomasiku-marketplace/index.html`

2. **Login Screen** (`login_screen.dart`)
   - Dark background with factory image overlay (use placeholder or AssetImage)
   - "Selamat Datang!" heading + "Masuk untuk melanjutkan" subtitle in red
   - Email/username input (glass morphism style: `bg-white/10`, white text)
   - Password input (same style)
   - "Ingat saya" checkbox + "Lupa password?" link
   - "Masuk" button (Mitsubishi Red, full width, shadow)
   - "Belum punya akun? **Daftar**" link → navigates to Register
   - On submit: set `isLoggedIn = true` → navigate to Home
   - Reference: `ui-otomasiku-marketplace/login.html`

3. **Register Screen** (`register_screen.dart`)
   - Same dark background style as Login
   - "Buat Akun Baru" heading
   - Fields: Nama Lengkap, Email, Nama Perusahaan, Password, Konfirmasi Password
   - Form validation (email format, password min 8 chars, passwords match)
   - "Daftar" button → set `isLoggedIn = true` → navigate to Home
   - "Sudah punya akun? **Masuk**" link → navigates to Login
   - Reference: No HTML mockup — follow login.html visual style

4. **Auth Provider** (`auth_provider.dart`)
   - `isLoggedInProvider` — `StateProvider<bool>` initialized to `false`
   - Login action: set to `true`
   - Logout action: set to `false`, navigate to splash
   - GoRouter redirect: if not logged in → `/login`, if logged in and on `/login` → `/home`

### Exit Criteria
- [ ] App launches to Splash → tap → Login screen
- [ ] Login form submits → navigates to Home
- [ ] Register form validates and submits → navigates to Home
- [ ] Logout from Profile → returns to Splash/Login
- [ ] Auth guard prevents accessing Home without login

### Reference
- `ui-otomasiku-marketplace/index.html` (Splash)
- `ui-otomasiku-marketplace/login.html` (Login)

---

## Phase M2-2: Bottom Navigation Shell & Home Screen
**Depends On:** Phase M2-1 ✅
**Estimated Effort:** 1 day

### Entry Criteria
- [ ] Phase M2-1 Exit Criteria ALL met
- [ ] Login redirects to Home successfully

### Tasks
1. **Bottom Navigation Bar** (`bottom_nav_bar.dart`)
   - 5 tabs: Beranda (🏠), Cari (🔍), Proyek (📁), Keranjang (🛒), Profil (👤)
   - Active state: Mitsubishi Red icon + text
   - Inactive state: Gray-400
   - Cart badge on Keranjang tab showing item count from `cartProvider`
   - Implemented via GoRouter `ShellRoute` with `StatefulNavigationShell`
   - Reference: Bottom nav in `home.html`, `profile.html`, `projects.html`

2. **Home Screen** (`home_screen.dart`)
   - **Header:** Mitsubishi logo (left) + Cart icon with badge + Profile avatar (right)
   - **Search bar:** Placeholder text "Cari FR-A820, FX5U, MR-J4..." + barcode icon button
   - **Category filter chips:** Semua, Mitsubishi, Inverter, PLC, Servo (horizontal scroll)
     - Active chip: Mitsubishi Red bg, white text
     - Inactive chip: Gray-200 bg, gray-700 text
     - Tapping a chip filters the product grid from dummy data
   - **Hero banner:** Dark gradient card "Melsec iQ-R Series" — "New Arrival" badge, "Lihat Detail" CTA → navigates to product detail of R04CPU
   - **Product grid:** 2 columns, loaded from `dummy_products.dart`
     - Each `ProductCard`: real product image from assets, stock badge (green/orange/red), product name, short description, price (Mitsubishi Red), "Tambah" button
     - Tap card → navigate to `/product/:id`
     - "Tambah" button → add 1 unit to cart (updates `cartProvider`)
   - **Compare bar:** Fixed bar above bottom nav, shows when ≥1 product selected for compare, "Bandingkan" button → `/compare`
   - Reference: `ui-otomasiku-marketplace/home.html`

3. **ProductCard Widget** (`product_card.dart`)
   - Reusable widget matching the HTML card design
   - Props: Product model
   - Stock badge: Green "X Unit" for stock > 5, Orange "Sisa X Unit" for stock 1-5, Red "Habis" for stock 0, Orange "Indent X Hari" for indent items
   - Price formatted with `CurrencyFormatter`
   - Compare button (scales icon) on hover/long-press

4. **Shared Widgets:**
   - `PriceText` — takes `int price`, renders formatted with Mitsubishi Red bold
   - `StockBadge` — takes stock count, renders correct color/text

### Exit Criteria
- [ ] Bottom nav shows 5 tabs, switching works, active states correct
- [ ] Cart badge shows item count and updates dynamically
- [ ] Home screen shows header, search bar, filter chips, hero banner, product grid
- [ ] Category filter chips filter the product grid correctly
- [ ] Product cards display all 10 products with correct prices, stock badges, and real product images
- [ ] Tapping product card navigates to product detail
- [ ] "Tambah" button adds item to cart
- [ ] All prices formatted as "Rp X.XXX.XXX"

### Reference
- `ui-otomasiku-marketplace/home.html`

---

## Phase M2-3: Search Results & Product Detail Screens
**Depends On:** Phase M2-2 ✅
**Estimated Effort:** 1 day

### Entry Criteria
- [ ] Phase M2-2 Exit Criteria ALL met
- [ ] Home screen product grid and navigation working

### Tasks
1. **Search Results Screen** (`search_results_screen.dart`)
   - Header: Back button + search input (pre-filled with query)
   - Active filter chips (removable): e.g. "Inverter ×", "Ready Stock ×"
   - Result count: "Ditemukan X produk"
   - Sort dropdown: Relevansi, Harga Terendah, Harga Tertinggi
   - Product list (vertical, not grid): image + stock badge + name + specs tags + price + "Detail" button
   - Search filters from dummy_products (by name, category, brand)
   - Sort actually reorders the list
   - Reference: `ui-otomasiku-marketplace/search-results.html`

2. **Product Detail Screen** (`product_detail_screen.dart`)
   - Header: Back button + "Detail Produk" title + Compare button
   - **Image area:** Real product image from `primaryImage` asset + gallery carousel from `galleryImages`, "New Arrival" + "Ready Stock" badges
   - **Product info:** Name (bold 2xl), subtitle, stock info card (green bg if ready, orange if limited)
   - **Price section:** Large red price + strikethrough original price (if exists)
   - **Tiered pricing card (B2B):**
     - 1-5 unit: normal price (red border, selected)
     - 6-10 unit: discounted price (green bg, "Best Deal" badge, "Hemat Rp Xrb/unit")
     - 11+ unit: "Hubungi sales" → RFQ modal
   - **Tab bar (sticky):** Spesifikasi | Dokumen | Kompatibel
     - Spesifikasi tab: specs table (Kapasitas Daya, Tegangan Input, Arus Output, Proteksi IP)
     - Dokumen tab: PDF datasheet card (icon + file name + size)
     - Kompatibel tab: list of compatible products (can be "Segera hadir" placeholder)
   - **Bottom action bar (fixed):**
     - Quantity selector: − [1] +
     - Bookmark/save-to-project button → prompt or bottom sheet
     - "Beli Sekarang" CTA → navigate to `/checkout`
   - **RFQ Modal:** Bottom sheet with quantity input + company name + "Kirim RFQ" button
   - Reference: `ui-otomasiku-marketplace/product-detail.html`

### Exit Criteria
- [ ] Search results screen filters and sorts correctly from dummy data
- [ ] Product detail shows all sections: real product image, gallery carousel, info, price, tiered pricing, tabs, specs
- [ ] Tab switching works (Spesifikasi / Dokumen / Kompatibel)
- [ ] Quantity selector increments/decrements (min 1)
- [ ] "Beli Sekarang" navigates to checkout
- [ ] RFQ modal opens and closes
- [ ] Tiered pricing cards render with correct styles

### Reference
- `ui-otomasiku-marketplace/search-results.html`
- `ui-otomasiku-marketplace/product-detail.html`

---

## Phase M2-4: Cart Screen (Keranjang Tab)
**Depends On:** Phase M2-3 ✅
**Estimated Effort:** 0.5 day

### Entry Criteria
- [ ] Phase M2-3 Exit Criteria ALL met
- [ ] Cart provider works (add/remove/update from home and product detail)

### Tasks
1. **Cart Screen** (`cart_screen.dart`)
   - Accessible from the **Keranjang tab** in bottom navigation (4th tab)
   - **If cart is empty:** Empty state illustration + "Keranjang Kosong" text + "Mulai Belanja" button → Home
   - **If cart has items:**
     - List of cart items, each showing:
       - Product image (from `primaryImage` asset)
       - Product name + short description
       - Quantity controls: − [qty] + (inline)
       - Price (red, bold) + savings text if volume discount
       - Remove button (× icon)
     - Cart summary at bottom: Subtotal
     - "Lanjut ke Checkout" button → navigate to `/checkout`
   - **Cart Provider** (`cart_provider.dart`):
     - State: `List<CartItem>` (initialized from `dummy_cart.dart`)
     - Actions: `addItem(product, qty)`, `removeItem(cartItemId)`, `updateQuantity(cartItemId, newQty)`, `clearCart()`
     - Computed: `totalItems` (for badge), `subtotal` (sum of price × qty)
   - Reference: Items section of `ui-otomasiku-marketplace/checkout.html`

### Exit Criteria
- [ ] Keranjang tab in bottom nav opens Cart screen
- [ ] Cart badge on tab icon shows correct count
- [ ] Cart items display with image, name, qty controls, price
- [ ] Quantity +/− updates price in real-time
- [ ] Remove item works (with confirmation or swipe)
- [ ] Empty cart shows empty state
- [ ] "Lanjut ke Checkout" navigates to checkout screen

### Reference
- Items section of `ui-otomasiku-marketplace/checkout.html`

---

## Phase M2-5: Checkout & Shipping Screens
**Depends On:** Phase M2-4 ✅
**Estimated Effort:** 1 day

### Entry Criteria
- [ ] Phase M2-4 Exit Criteria ALL met
- [ ] Cart has items, subtotal computed correctly

### Tasks
1. **Checkout Screen** (`checkout_screen.dart`)
   - Header: Back button + "Checkout" title
   - **Ringkasan Pesanan:** Cart items summary (image, name, qty, price per item) — item count badge
   - **Alamat Pengiriman:** Shows selected address card (name, company, full address, phone) + "Utama" badge + "Ubah" link → `/shipping`
   - **PO Number field** (optional): "Nomor PO Perusahaan" input
   - **Metode Pembayaran:** BCA Virtual Account card (selected, blue border) + info box explaining steps
   - **Pengiriman:** "Pengiriman Standar — Estimasi 3-5 hari kerja — GRATIS" (green text)
   - **Ringkasan Pembayaran:**
     - Subtotal (X item)
     - Diskon Volume (green, negative) — hardcoded for demo
     - Ongkir: GRATIS (green)
     - PPN (11%) — hardcoded for demo
     - **Total Pembayaran** (large, red, bold)
   - **Terms checkbox** + "Syarat dan Ketentuan" link
   - **Fixed bottom bar:** Total amount + "Buat Invoice & Bayar" button
     - On tap: validate terms checked → navigate to `/payment/:orderId`
   - Reference: `ui-otomasiku-marketplace/checkout.html`

2. **Shipping Address Screen** (`shipping_screen.dart`)
   - Header: Back button + "Alamat Pengiriman" title
   - **Saved addresses** list (from `dummy_addresses.dart`):
     - Radio select, selected = red border + red bg tint
     - Each card: name + "Utama" badge, company, full address, phone
     - Edit (pencil) + Delete (trash) icons
   - **"+ Tambah Alamat Baru"** button → opens form bottom sheet:
     - Fields: Nama Penerima, Perusahaan, Alamat Lengkap, Kota, Kode Pos, Telepon
     - "Jadikan alamat utama" checkbox
     - "Simpan" button
   - **Fixed bottom bar:** "Gunakan Alamat Ini" button → pop back to checkout with selected address
   - Reference: `ui-otomasiku-marketplace/shipping.html`

### Exit Criteria
- [ ] Checkout screen shows all sections matching the HTML mockup
- [ ] Cart items render correctly with prices
- [ ] Shipping address displays selected address
- [ ] "Ubah" link navigates to shipping screen and back
- [ ] Payment method shows BCA VA (non-interactive, pre-selected)
- [ ] Payment summary shows subtotal, discount, PPN, total
- [ ] Terms checkbox validation works
- [ ] "Buat Invoice & Bayar" navigates to payment screen
- [ ] Shipping screen shows address list with radio selection
- [ ] Add new address form opens in bottom sheet

### Reference
- `ui-otomasiku-marketplace/checkout.html`
- `ui-otomasiku-marketplace/shipping.html`

---

## Phase M2-BCA: Mini Express Backend — BCA Sandbox Only
**Depends On:** Phase M2-5 ✅ (Checkout screen must exist before payment can be wired up)
**Estimated Effort:** 1 day
**Directory:** `C:\dev\projects\otomasiku-api` — completely separate from the Flutter project at `C:\dev\projects\otomasiku-mobile`

> **Scope is FROZEN.** This mini backend exists for ONE reason only: generate a real BCA Sandbox Virtual Account number and receive its callback. It has no database, no auth, no product logic, no order persistence. When Milestone 3 begins, this mini backend GROWS into the full Express API — it is NOT retired, it is expanded.

### ⚠️ What this backend IS and IS NOT

| ✅ IS | ❌ IS NOT |
|---|---|
| A mini Express app with 3 endpoints | A full backend |
| BCA Sandbox VA creation | Real BCA production API |
| In-memory VA storage (Map, no DB) | Supabase / Prisma / any DB |
| Deployed to Railway (separate service) | Inside the Flutter project folder |
| BCA callback receiver + signature check | Auth, products, orders, profile |

### Entry Criteria
- [ ] BCA Developer API Sandbox account registered at `developer.bca.co.id`
- [ ] Sandbox credentials obtained: `BCA_CLIENT_ID`, `BCA_CLIENT_SECRET`, `BCA_API_KEY`, `BCA_API_SECRET`
- [ ] BCA Sandbox VA prefix assigned
- [ ] `C:\dev\projects\` directory exists (parent folder is ready)

### Tasks

#### 1. Create and initialize the backend project

Open a **new terminal** (separate from the Flutter project):

```powershell
# Navigate to projects root — NOT inside otomasiku-mobile
cd C:\dev\projects

# Create the backend folder
mkdir otomasiku-api
cd otomasiku-api

# Initialize with pnpm (NOT npm)
pnpm init

# Install runtime dependencies
pnpm add express cors dotenv helmet express-rate-limit axios pino pino-pretty

# Install TypeScript + type definitions as dev dependencies
pnpm add -D typescript ts-node @types/express @types/node @types/cors

# Initialize TypeScript config
npx tsc --init
```

After this, your directory structure across projects should look like:

```
C:\dev\projects\
├── otomasiku-mobile\     ← Flutter app (already exists)
│   ├── lib\
│   ├── pubspec.yaml
│   ├── CLAUDE.md
│   └── docs\
└── otomasiku-api\        ← Express backend (just created)
    ├── src\
    ├── package.json
    ├── pnpm-lock.yaml    ← commit this, NEVER package-lock.json
    └── tsconfig.json
```

> ⚠️ **Never run `pnpm install` or any Node.js commands inside `otomasiku-mobile\`.** Flutter and Node.js are completely separate projects with separate terminals.

#### 2. Create `.env` (NEVER commit — only `.env.example`)

Create both files at `C:\dev\projects\otomasiku-api\.env`:

```env
# .env — BCA Sandbox credentials ONLY
# Milestone 2 scope: BCA Sandbox integration only.
# Do NOT add Supabase, database, or any other service credentials here yet.

NODE_ENV=development
PORT=3001

# BCA Developer API — SANDBOX environment
BCA_CLIENT_ID=your_sandbox_client_id
BCA_CLIENT_SECRET=your_sandbox_client_secret
BCA_API_KEY=your_sandbox_api_key
BCA_API_SECRET=your_sandbox_api_secret
BCA_VA_PREFIX=your_sandbox_va_prefix
BCA_API_BASE_URL=https://sandbox.bca.co.id    # SANDBOX — never change to production here
BCA_CALLBACK_SECRET=your_callback_hmac_secret

# CORS — allow local Flutter web preview + Railway
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001
```

Create `C:\dev\projects\otomasiku-api\.env.example` with the same keys but empty values — commit this file, never `.env`.

#### 3. Project structure

Full structure for `C:\dev\projects\otomasiku-api\`:

```
otomasiku-api\
├── src\
│   ├── index.ts               # Entry point — Express app bootstrap
│   ├── config\
│   │   └── env.ts             # Typed env variables — never use raw process.env
│   ├── routes\
│   │   ├── health.ts          # GET /health — Railway liveness check
│   │   └── payment.ts         # POST /payment/create-va
│   │                          # POST /payment/callback
│   │                          # GET  /payment/status/:vaNumber
│   ├── services\
│   │   ├── bca_auth.ts        # BCA OAuth2 token — cache + refresh before expiry
│   │   └── bca_va.ts          # Call BCA Sandbox API to create VA
│   ├── middleware\
│   │   ├── bca_signature.ts   # Validate X-BCA-Signature on callback
│   │   ├── rate_limit.ts      # Rate limiting
│   │   └── logger.ts          # Pino structured logging
│   └── store\
│       └── va_store.ts        # In-memory Map: vaNumber → { orderId, amount, status, expiry }
│                              # No DB — resets on server restart (fine for sandbox demo)
├── .env                       # NEVER commit — add to .gitignore
├── .env.example               # Commit this — empty values as template
├── .gitignore                 # node_modules, .env, dist
├── tsconfig.json
├── package.json
├── pnpm-lock.yaml             # Commit this — pnpm lockfile
└── README.md
```

> **Milestone 3 note:** When building the full backend in Milestone 3, this `otomasiku-api\` folder is expanded — NOT replaced. Add Prisma, Supabase SDK, auth routes, product routes, order routes, etc. to this same project. The BCA payment routes stay as-is.

#### 4. In-memory VA store (no database needed for M2)

```typescript
// src/store/va_store.ts
interface VaRecord {
  orderId: string;       // generated locally — "ORD-" + timestamp
  amount: bigint;        // payment amount in Rupiah
  vaNumber: string;      // VA number returned by BCA Sandbox
  status: 'pending' | 'paid' | 'expired';
  createdAt: Date;
  expiresAt: Date;       // createdAt + 24 hours
}

// Simple in-memory store — resets on server restart
// Acceptable for sandbox demo — DO NOT use this pattern in production
const store = new Map<string, VaRecord>();

export const vaStore = {
  set: (vaNumber: string, record: VaRecord) => store.set(vaNumber, record),
  get: (vaNumber: string) => store.get(vaNumber),
  markPaid: (vaNumber: string) => {
    const record = store.get(vaNumber);
    if (record) store.set(vaNumber, { ...record, status: 'paid' });
  },
  all: () => Array.from(store.values()),
};
```

#### 5. Two endpoints

```typescript
// src/routes/payment.ts

// POST /payment/create-va
// Called by Flutter after user taps "Buat Invoice & Bayar" in checkout
// Body: { amount: number }
// Returns: { vaNumber, amount, expiresAt, orderId }
router.post('/payment/create-va', async (req, res) => {
  const { amount } = req.body;
  if (!amount || typeof amount !== 'number' || amount <= 0) {
    return res.status(400).json({ error: { code: 'INVALID_AMOUNT' } });
  }

  // 1. Get BCA OAuth token (cached in bca_auth.ts)
  const token = await bcaAuth.getToken();

  // 2. Call BCA Sandbox API to create VA
  const vaResult = await bcaVa.create({ token, amount: BigInt(amount) });

  // 3. Store in memory
  const orderId = `ORD-${Date.now()}`;
  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
  vaStore.set(vaResult.vaNumber, { orderId, amount: BigInt(amount), vaNumber: vaResult.vaNumber, status: 'pending', createdAt: new Date(), expiresAt });

  return res.json({ vaNumber: vaResult.vaNumber, amount, expiresAt, orderId });
});

// POST /payment/callback
// Called by BCA Sandbox when payment is received
// Validates BCA HMAC signature before processing
router.post('/payment/callback', validateBcaSignature, async (req, res) => {
  const { virtual_account, paid_amount } = req.body;

  const record = vaStore.get(virtual_account);
  if (!record) return res.status(404).json({ error: { code: 'VA_NOT_FOUND' } });
  if (record.status === 'paid') return res.status(200).json({ status: 'already_processed' });

  vaStore.markPaid(virtual_account);

  logger.info({ vaNumber: virtual_account, orderId: record.orderId }, 'Payment confirmed via BCA callback');

  // For M2: no email, no DB update — just log and return 200
  return res.json({ status: 'ok' });
});

// GET /payment/status/:vaNumber
// Called by Flutter to poll payment status
router.get('/payment/status/:vaNumber', (req, res) => {
  const record = vaStore.get(req.params.vaNumber);
  if (!record) return res.status(404).json({ error: { code: 'VA_NOT_FOUND' } });

  const isExpired = new Date() > record.expiresAt;
  const status = isExpired && record.status === 'pending' ? 'expired' : record.status;

  return res.json({ vaNumber: record.vaNumber, status, orderId: record.orderId, expiresAt: record.expiresAt });
});
```

#### 6. BCA OAuth token caching

```typescript
// src/services/bca_auth.ts
// BCA Sandbox uses OAuth2 — token expires every 3600s
// Cache it server-side and refresh before expiry
// NEVER request a new token on every API call — BCA rate limits this

let cachedToken: string | null = null;
let tokenExpiresAt: Date | null = null;

export const bcaAuth = {
  getToken: async (): Promise<string> => {
    const now = new Date();
    // Refresh 60s before actual expiry
    if (cachedToken && tokenExpiresAt && tokenExpiresAt.getTime() - now.getTime() > 60_000) {
      return cachedToken;
    }
    // Fetch new token from BCA Sandbox OAuth endpoint
    const response = await axios.post(`${env.BCA_API_BASE_URL}/api/oauth/token`, ...);
    cachedToken = response.data.access_token;
    tokenExpiresAt = new Date(now.getTime() + response.data.expires_in * 1000);
    return cachedToken;
  }
};
```

#### 7. Deploy to Railway

```powershell
# Open a terminal in the backend folder (NOT otomasiku-mobile)
cd C:\dev\projects\otomasiku-api

# Install Railway CLI
pnpm add -g @railway/cli

# Login and deploy
railway login
railway init    # creates new Railway project named "otomasiku-api"
railway up      # deploys from current directory
```

> Set all environment variables from `.env` via the **Railway dashboard → Variables tab** — NOT via CLI to avoid credentials appearing in shell history.

After deploy, Railway gives you a URL like `https://otomasiku-api-production.up.railway.app`. Copy this and update `BcaConfig.miniBackendBaseUrl` in Flutter:

```dart
// lib/core/constants/bca_config.dart
static const String miniBackendBaseUrl =
    'https://otomasiku-api-production.up.railway.app'; // ← paste Railway URL here
```

#### 8. Wire up Flutter `BcaPaymentService`

This code lives in the **Flutter project** (`C:\dev\projects\otomasiku-mobile`), not the backend. It calls the deployed Railway URL via Dio:

```dart
// lib/data/services/bca_payment_service.dart  (inside otomasiku-mobile)
import 'package:dio/dio.dart';
import '../../models/bca_va_response.dart';
import '../../core/constants/bca_config.dart';

class BcaPaymentService {
  final Dio _dio = Dio(BaseOptions(baseUrl: BcaConfig.miniBackendBaseUrl));

  // Called after "Buat Invoice & Bayar" is tapped in checkout
  Future<BcaVaResponse> createVa(int amount) async {
    try {
      final response = await _dio.post('/payment/create-va', data: {'amount': amount});
      return BcaVaResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Poll payment status — called every 10s on payment screen
  Future<String> getStatus(String vaNumber) async {
    final response = await _dio.get('/payment/status/$vaNumber');
    return response.data['status'] as String; // 'pending' | 'paid' | 'expired'
  }
}
```

```dart
// lib/models/bca_va_response.dart
class BcaVaResponse {
  final String vaNumber;
  final int amount;
  final DateTime expiresAt;
  final String orderId;

  const BcaVaResponse({
    required this.vaNumber,
    required this.amount,
    required this.expiresAt,
    required this.orderId,
  });

  factory BcaVaResponse.fromJson(Map<String, dynamic> json) => BcaVaResponse(
    vaNumber: json['vaNumber'] as String,
    amount: json['amount'] as int,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    orderId: json['orderId'] as String,
  );
}
```

### Exit Criteria
- [ ] Mini backend deployed to Railway and accessible via HTTPS URL
- [ ] `GET /health` returns `200 { "status": "ok" }`
- [ ] `POST /payment/create-va` with `{ "amount": 5200000 }` returns a real BCA Sandbox VA number
- [ ] VA number is a valid BCA format (starts with configured `BCA_VA_PREFIX`)
- [ ] `GET /payment/status/:vaNumber` returns correct status
- [ ] BCA Sandbox callback from BCA Developer Portal → `POST /payment/callback` → status changes to `paid`
- [ ] Signature validation rejects requests with invalid `X-BCA-Signature`
- [ ] Flutter `BcaPaymentService.createVa()` successfully calls mini backend and returns `BcaVaResponse`
- [ ] Mini backend has ZERO endpoints other than: `/health`, `/payment/create-va`, `/payment/callback`, `/payment/status/:vaNumber`

---

## Phase M2-6: Payment & Payment Success Screens
**Depends On:** Phase M2-BCA ✅ + Phase M2-5 ✅
**Estimated Effort:** 1 day

### Entry Criteria
- [ ] Phase M2-BCA Exit Criteria ALL met (mini backend deployed, VA creation working)
- [ ] Phase M2-5 Exit Criteria ALL met
- [ ] `BcaConfig.miniBackendBaseUrl` updated with live Railway URL
- [ ] `BcaPaymentService.createVa()` tested manually and returns real VA number

### Tasks
1. **Payment Provider** (`payment_provider.dart`)
   - State: `vaNumber`, `amount`, `expiresAt`, `orderId`, `status` (`idle | loading | pending | paid | expired | error`), `errorCode`
   - `createVa(int amount)` → calls `BcaPaymentService.createVa()`, updates state
   - `pollStatus()` → calls `BcaPaymentService.getStatus()` every 10s via `Timer.periodic`
   - Auto-cancels polling timer when `status == 'paid'` or `status == 'expired'`

2. **Payment Screen** (`payment_screen.dart`)
   - **On init:** call `paymentProvider.notifier.createVa(totalAmount)` — show loading spinner while VA is created from BCA Sandbox
   - Header: Back button + `l10n.paymentTitle`
   - **Invoice card:** `l10n.paymentWaiting` badge (pulsing) + total + `l10n.paymentCopy`
   - **Countdown box** (BCA blue gradient): live countdown from `expiresAt` returned by mini backend — NOT hardcoded 24:00:00
   - **BCA VA card:** real VA number from `paymentState.vaNumber` (mono font) + copy button → clipboard → `l10n.paymentCopied` snackbar
   - **Status polling:** every 10s → if `paid` → auto-navigate to success; if `expired` → show expired state
   - **Error state:** if mini backend unreachable → show `l10n.errorBcaCreateVa` + retry button (no crash)
   - Payment instructions accordion (ATM BCA + BCA Mobile steps)
   - **Fixed bottom bar:** "Lihat Produk Lain" + `l10n.paymentCheckStatus` (manual status trigger)
   - Reference: `ui-otomasiku-marketplace/payment.html`

3. **Payment Success Screen** (`payment_success_screen.dart`)
   - Green checkmark animation (scale-in)
   - `l10n.paymentSuccess` heading
   - Summary card: real `orderId` from mini backend + date + amount
   - Status timeline: Pembayaran Diterima ✅ → Sedang Diproses 🔴
   - Buttons: "Lihat Detail Pesanan" → `/order/:id` | "Kembali ke Beranda" → `/home`
   - Reference: `ui-otomasiku-marketplace/payment-success.html`

### Exit Criteria
- [ ] Payment screen calls mini backend on load — real BCA Sandbox VA number displayed (NOT hardcoded)
- [ ] Countdown runs from `expiresAt` from API (NOT a fixed 24:00:00 start)
- [ ] Copy button copies real VA number → clipboard → snackbar `l10n.paymentCopied`
- [ ] Status polling every 10s — auto-navigates to success when BCA callback triggers `paid`
- [ ] Error state shown (friendly message) if mini backend unreachable — app does NOT crash
- [ ] Payment success screen shows real `orderId` from mini backend
- [ ] All strings use `AppLocalizations` — zero hardcoded user-facing text

### Reference
- `ui-otomasiku-marketplace/payment.html`
- `ui-otomasiku-marketplace/payment-success.html`

---

## Phase M2-7: Order Detail Screen
**Depends On:** Phase M2-6 ✅
**Estimated Effort:** 0.5 day

### Entry Criteria
- [ ] Phase M2-6 Exit Criteria ALL met

### Tasks
1. **Order Detail Screen** (`order_detail_screen.dart`)
   - Header: Back button + "Detail Pesanan" title + invoice number subtitle + Share button
   - **Status banner:** Gradient blue card (matching order status)
     - Status icon + "Sedang Diproses" text
     - "Estimasi pengiriman: 13-15 Maret 2024"
   - **Riwayat Status (Timeline):**
     - Vertical timeline with dot indicators
     - ✅ Green dot: Pembayaran Diterima (with date)
     - 🔴 Red pulsing dot: Sedang Diproses (current)
     - ⚪ Gray dots: Dikirim, Selesai (future steps)
   - **Item Dipesan:** List of ordered items (image, name, qty × price, line total) + Grand total
   - **Info Pengiriman:** Address card + "Nomor resi akan muncul setelah barang dikirim"
   - **Action buttons:**
     - "Unduh Invoice" (outline) — show toast "Segera tersedia"
     - "Hubungi Support" (red) — show WhatsApp link or toast
   - Reference: `ui-otomasiku-marketplace/order-detail.html`

### Exit Criteria
- [ ] Order detail loads from `dummy_orders.dart`
- [ ] Status banner shows correct status with icon
- [ ] Timeline renders with correct active/completed/future states
- [ ] Items list shows all products with correct prices
- [ ] Shipping address displays correctly
- [ ] Both action buttons are functional (even if just showing toast)

### Reference
- `ui-otomasiku-marketplace/order-detail.html`

---

## Phase M2-8: Profile, Projects & Compare Screens
**Depends On:** Phase M2-7 ✅
**Estimated Effort:** 1 day

### Entry Criteria
- [ ] Phase M2-7 Exit Criteria ALL met

### Tasks
1. **Profile Screen** (`profile_screen.dart`)
   - Header: Back button + "Profil" title + Settings gear icon
   - **User card:** Dark gradient, avatar image, name, email
   - **Stats grid (3 cols):** Pesanan (24), Selesai (20), Process (4) — from `dummy_orders.dart` counts
   - **Menu list:**
     - Pesanan Saya (clipboard icon, blue) → `/order/:id` (first order)
     - Alamat Pengiriman (pin icon, red) → `/shipping`
     - Pembayaran (card icon, green) — shows "BCA Virtual Account"
     - Bantuan (headset icon, purple) — toast
   - **Logout button** (red outline) → confirm dialog → set `isLoggedIn = false` → navigate to splash
   - **Bottom nav:** Profil tab active (red)
   - Reference: `ui-otomasiku-marketplace/profile.html`

2. **Projects Screen** (`projects_screen.dart`)
   - Header: Back button + "Proyek Saya" title + "+" add button (red)
   - **Stats grid (3 cols):** Proyek Aktif (3), Total Item (12), Total Estimasi (Rp 145jt)
   - **Project cards:** For each project in `dummy_projects.dart`:
     - Project name + date created
     - Share button
     - Item list (compact): image icon + name + qty × price
     - Footer: item count + total price
     - Two buttons: "Checkout Proyek" (red) → `/checkout` | "Ajukan RFQ" (outline) → toast
   - **Create project modal:** Bottom sheet with project name input + "Buat Proyek" button
   - **Bottom nav:** Proyek tab active (red)
   - Reference: `ui-otomasiku-marketplace/projects.html`

3. **Compare Screen** (`compare_screen.dart`)
   - Header: Back button + "Bandingkan Produk" title + "Hapus Semua" (red text)
   - **Comparison grid** (horizontal scrollable):
     - Column 1: Spec labels (PRODUK, DAYA, TEGANGAN, GARANSI, etc.)
     - Columns 2-3: Selected products with image, name, brand, price, stock badge, specs
     - Column 4: "+ Tambah Produk" placeholder (dashed border circle)
     - Remove (×) button per product column
   - **Bottom row:** "Beli" button per product → `/checkout`
   - **Compare provider:** max 3 products, add/remove from home screen
   - Reference: `ui-otomasiku-marketplace/compare.html`

### Exit Criteria
- [ ] Profile screen shows user info, stats, menu items, logout
- [ ] Logout works → returns to splash
- [ ] Projects screen shows project list with items and totals
- [ ] Create new project modal works
- [ ] Compare screen shows side-by-side product comparison
- [ ] Compare grid scrolls horizontally on small screens
- [ ] All bottom nav tabs navigate correctly and show active state

### Reference
- `ui-otomasiku-marketplace/profile.html`
- `ui-otomasiku-marketplace/projects.html`
- `ui-otomasiku-marketplace/compare.html`

---

## Phase M2-9: Full Flow Polish & Device Testing
**Depends On:** Phase M2-8 ✅
**Estimated Effort:** 1 day

### Entry Criteria
- [ ] ALL previous phases complete
- [ ] All 15 screens built and navigable

### Tasks
1. **Full flow walkthrough #1 — Customer journey:**
   - Splash → Login → Home → Search → Product Detail → Add to Cart → Cart → Checkout → Shipping (change address) → back to Checkout → "Buat Invoice" → Payment (countdown running) → "Cek Status" → Payment Success → Order Detail → back to Home
   - Fix any navigation bugs, broken layouts, missing data

2. **Full flow walkthrough #2 — Tab navigation:**
   - Beranda → Cari → Proyek → Keranjang → Profil
   - Verify each tab loads correct screen
   - Verify active states (red icon/text)
   - Verify cart badge updates across tabs

3. **Full flow walkthrough #3 — Edge cases:**
   - Empty cart → checkout should be blocked or show warning
   - Compare with 0, 1, 2, 3 products
   - Register form validation (empty fields, password mismatch)
   - Quantity selector: can't go below 1
   - Very long product names (text overflow handling)

4. **Visual QA against HTML mockups:**
   - Open each HTML file in a browser side-by-side with the Flutter screen on device
   - Verify: colors, spacing, font sizes, border radius, shadows, icon usage
   - Fix any deviations

5. **Performance check:**
   - Smooth scrolling on product grid (10 items — lazy loading not needed for small catalog)
   - No jank on tab switching
   - Payment countdown doesn't cause frame drops
   - Product images (AssetImage) load without flicker or errors

6. **Physical device testing:**
   - Build release APK: `flutter build apk --release`
   - Install on at least 1 physical Android device
   - Full flow test on real device
   - Check: touch targets ≥ 44dp, bottom nav doesn't overlap content, keyboard doesn't cover inputs

### Exit Criteria
- [ ] Complete customer flow works end-to-end without crashes
- [ ] Payment flow: real BCA Sandbox VA generated → countdown live → status polling works → payment success on callback
- [ ] All 5 bottom nav tabs work correctly
- [ ] All 15 screens match HTML mockups visually
- [ ] No text overflow or layout issues on different screen sizes
- [ ] Release APK installs and runs on physical device
- [ ] Language switch ID↔EN works on every screen — no hardcoded strings visible
- [ ] Cart state persists across screen navigation (within session)
- [ ] Mini backend `/health` returns 200 at milestone demo time

---

## 📊 Screen & Phase Inventory

### Phase Summary

| Phase | Scope | Effort |
|-------|-------|--------|
| M2-0 | Project setup, dummy data, i18n, folder structure | 1 day |
| M2-1 | Splash, Login, Register | 0.5 day |
| M2-2 | Bottom nav shell, Home screen | 1 day |
| M2-3 | Search Results, Product Detail | 1 day |
| M2-4 | Cart screen | 0.5 day |
| M2-5 | Checkout, Shipping Address | 1 day |
| **M2-BCA** | **Express backend in `otomasiku-api\` — BCA Sandbox only (Railway deploy)** | **1 day** |
| M2-6 | Payment screen (real VA), Payment Success | 1 day |
| M2-7 | Order Detail | 0.5 day |
| M2-8 | Profile, Projects, Compare | 1 day |
| M2-9 | Full flow polish, device testing | 1 day |
| **Total** | | **~9.5 days** |

### Screen Inventory

| # | Screen | Route | HTML Reference | Phase |
|---|--------|-------|----------------|-------|
| 1 | Splash | `/` | `index.html` | M2-1 |
| 2 | Login | `/login` | `login.html` | M2-1 |
| 3 | Register | `/register` | — (follows login style) | M2-1 |
| 4 | Home (Beranda) | `/home` | `home.html` | M2-2 |
| 5 | Search Results (Cari) | `/search` | `search-results.html` | M2-3 |
| 6 | Product Detail | `/product/:id` | `product-detail.html` | M2-3 |
| 7 | Cart (Keranjang) | `/cart` | `checkout.html` (items section) | M2-4 |
| 8 | Checkout | `/checkout` | `checkout.html` | M2-5 |
| 9 | Shipping Address | `/shipping` | `shipping.html` | M2-5 |
| 10 | Payment (BCA VA) | `/payment/:orderId` | `payment.html` | M2-6 |
| 11 | Payment Success | `/payment-success/:orderId` | `payment-success.html` | M2-6 |
| 12 | Order Detail | `/order/:id` | `order-detail.html` | M2-7 |
| 13 | Profile (Profil) | `/profile` | `profile.html` | M2-8 |
| 14 | Projects (Proyek) | `/projects` | `projects.html` | M2-8 |
| 15 | Compare | `/compare` | `compare.html` | M2-8 |

---

## 📋 HTML Mockup Feature Inventory

Complete feature breakdown of all 17 HTML mockups in `ui-otomasiku-marketplace/`. Each Flutter screen must replicate these features with pixel-perfect fidelity.

### 1. Splash Screen (`index.html`)

| Feature | Description |
|---------|-------------|
| Full-screen dark background | `#1a1a1a` with gradient overlay |
| Mitsubishi logo | Centered, prominent |
| "Oseï" branding | Main brand text |
| "Automation Spareparts Marketplace" | Subtitle text |
| "Mulai Sekarang!" CTA button | Navigates to Login |

---

### 2. Login Screen (`login.html`)

| Feature | Description |
|---------|-------------|
| Dark background with factory image overlay | Glass morphism effect |
| "Selamat Datang!" heading | Welcome text |
| "Masuk untuk melanjutkan" subtitle | Red accent text |
| Email/username input | Glass style: `bg-white/10`, white text |
| Password input | Same glass style |
| "Ingat saya" checkbox | Remember me |
| "Lupa password?" link | Password recovery |
| "Masuk" button | Mitsubishi Red, full width, shadow |
| "Belum punya akun? **Daftar**" link | Navigates to Register |
| Form validation | Email/password required |
| Auto-redirect to Home on success | Sets `isLoggedIn = true` |

---

### 3. Home Screen (`home.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Mitsubishi logo | Left aligned |
| Cart icon with badge | Shows item count, right side |
| Profile avatar | Circular, right side |
| **Search Bar** | |
| Search input | Placeholder: "Cari FR-A820, FX5U, MR-J4..." |
| Barcode scanner button | Icon button, right |
| **Category Filter Chips** | |
| Horizontal scrollable chips | Semua, Mitsubishi, Danfoss, Inverter, PLC, Servo, HMI |
| Active chip | Mitsubishi Red bg, white text |
| Inactive chip | Gray-200 bg, gray-700 text |
| Filter functionality | Filters product grid |
| **Hero Banner** | |
| Dark gradient card | "Melsec iQ-R Series" |
| "New Arrival" badge | Red badge |
| "Lihat Detail" CTA | Navigates to product detail |
| **Product Grid** | |
| 2-column grid | Responsive |
| Product cards (10 products) | Image, name, specs, price, stock badge |
| Stock badges | Green (Ready), Orange (Limited), Red (Out) |
| Hover effects | Scale, shadow |
| "Tambah" button | Add to cart |
| Compare icon | Add to compare list |
| **Compare Bar** | |
| Fixed above bottom nav | Shows when ≥1 product selected |
| "Bandingkan (X)" button | Navigates to compare screen |
| **Bottom Navigation** | 5 tabs active |
| **Toast Notifications** | Slide-in confirmation |

---

### 4. Product Detail Screen (`product-detail.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left aligned |
| "Detail Produk" title | Centered |
| Compare button | Right aligned |
| **Product Image Area** | |
| Main product image | Large, centered |
| Gallery carousel | Multiple images |
| "New Arrival" badge | Red badge overlay |
| "Ready Stock" badge | Green badge overlay |
| **Product Information** | |
| Product name | Bold, large |
| Subtitle/description | Gray text |
| Stock availability card | Green bg if ready |
| **Pricing** | |
| Large red price | Prominent display |
| Strikethrough original price | If discount exists |
| **Tiered Pricing (B2B)** | |
| 1-5 unit tier | Normal price, red border |
| 6-10 unit tier | Discounted price, green bg, "Best Deal" |
| 11+ unit tier | "Hubungi sales" → RFQ modal |
| **Tab Bar (Sticky)** | |
| Spesifikasi tab | Specs table |
| Dokumen tab | PDF datasheet download |
| Kompatibel tab | Compatible products list |
| **Bottom Action Bar (Fixed)** | |
| Quantity selector | − [1] + buttons |
| Save to project button | Bookmark icon |
| "Beli Sekarang" CTA | Mitsubishi Red, navigates to checkout |
| **RFQ Modal** | |
| Bottom sheet | Quantity input, company name |
| "Kirim RFQ" button | Submit |

---

### 5. Search Results Screen (`search-results.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left aligned |
| Search input | Pre-filled with query |
| Clear button | X icon |
| **Active Filters** | |
| Removable filter chips | "Inverter ×", "Ready Stock ×" |
| **Sort Dropdown** | |
| Relevansi | Default |
| Harga Terendah | Low to high |
| Harga Tertinggi | High to low |
| **Result Count** | "Ditemukan X produk" |
| **Product List (Vertical)** | |
| 10 products | Vertical list layout |
| Product image | Left thumbnail |
| Stock badge | Green/Orange/Red |
| Product name | Bold |
| Specs tags | Small gray chips |
| Price | Red, bold |
| "Detail" button | Navigates to detail |
| **Filter Bottom Sheet** | |
| Category filter | Checkboxes |
| Brand filter | Checkboxes |
| Stock filter | Ready/Indent/Out |
| Power range slider | Min-max kW |
| **Empty State** | When no results found |

---

### 6. Cart Screen (`cart.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left aligned |
| "Keranjang Belanja" title | Centered |
| "Hapus Semua" button | Right aligned, red text |
| **Empty State** | |
| Illustration | Cart icon |
| "Keranjang Kosong" text | Gray |
| "Mulai Belanja" button | Returns to home |
| **Cart Items List** | |
| Product image | Left thumbnail |
| Product name + description | Bold + small gray |
| Quantity controls | − [qty] + inline |
| Price per item | Red |
| Remove button | × icon |
| **Cart Summary** | |
| Subtotal | Bold, right aligned |
| **Checkout Button** | |
| "Lanjut ke Checkout" | Full width, Mitsubishi Red |

---

### 7. Checkout Screen (`checkout.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left |
| "Checkout" title | Center |
| **Order Summary** | |
| Item count badge | "X Item" |
| Item images | Thumbnails |
| Quantity display | "X unit" |
| Price per item | Gray |
| **Address Section** | |
| Selected address card | Name, company, full address, phone |
| "Utama" badge | Primary address |
| "Ubah" link | Navigates to shipping |
| Map icon | Visual decoration |
| **PO Number** | |
| Optional input | "Nomor PO Perusahaan" |
| **Payment Method** | |
| BCA Virtual Account card | Selected, blue border |
| Payment instructions | Info box |
| **Shipping Method** | |
| "Pengiriman Standar" | Free shipping |
| "Estimasi 3-5 hari" | Green text |
| **Payment Summary** | |
| Subtotal | X item |
| Discount (volume) | Green, negative |
| Shipping | GRATIS (green) |
| PPN (11%) | Hardcoded for demo |
| **Total** | Large, red, bold |
| **Terms Checkbox** | |
| Checkbox + link | "Syarat dan Ketentuan" |
| **Fixed Bottom Bar** | |
| Total amount display | Left |
| "Buat Invoice & Bayar" button | Right, validates terms |

---

### 8. Shipping Address Screen (`shipping.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left |
| "Alamat Pengiriman" title | Center |
| **Saved Addresses List** | |
| Radio selection | Selected = red border + tint |
| Address cards | Name, "Utama" badge, company, address, phone |
| Edit button | Pencil icon |
| Delete button | Trash icon |
| **"Tambah Alamat Baru"** | |
| Bottom sheet form | Nama, Perusahaan, Alamat, Kota, Pos, Telepon |
| "Jadikan utama" checkbox | |
| "Simpan" button | |
| **Fixed Bottom Bar** | |
| "Gunakan Alamat Ini" | Full width, navigates back |

---

### 9. Payment Screen (`payment.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left |
| "Pembayaran" title | Center |
| **Invoice Card** | |
| Invoice number | Mono font, bold |
| "Menunggu Pembayaran" badge | Yellow, pulsing dot |
| Total amount | Large red + "Salin" button |
| **Countdown Timer** | |
| BCA blue gradient card | |
| "Batas Waktu Pembayaran" | |
| Live countdown | 24:00:00 ticking down (Jam | Menit | Detik) |
| **BCA Virtual Account Card** | |
| BCA logo badge | Blue box |
| VA number | "1234 5678 9012 3456" mono + "Salin" |
| Dashed blue border | |
| **Payment Instructions** | |
| Accordion: "via ATM BCA" | Numbered steps |
| Accordion: "via BCA Mobile" | Numbered steps |
| **Help Card** | |
| "Butuh bantuan?" | Phone number |
| **Fixed Bottom Bar** | |
| "Lihat Produk Lain" | Outline |
| "Cek Status" | Red → payment success |

---

### 10. Payment Success Screen (`payment-success.html`)

| Feature | Description |
|---------|-------------|
| **Success Animation** | |
| Green circle with checkmark | Scale-in animation |
| Confetti (optional) | On load |
| **Success Message** | |
| "Pembayaran Berhasil!" | Large heading |
| Subtitle | "Terima kasih, pembayaran Anda telah terverifikasi" |
| **Summary Card** | |
| Invoice number | |
| Payment date | Formatted |
| Total paid | Red, bold |
| **Status Timeline** | |
| ✅ Pembayaran Diterima | With datetime |
| 🔴 Sedang Diproses | Pulsing, current |
| **Info Box** | |
| "Apa selanjutnya?" | Bullet points |
| **Action Buttons** | |
| "Lihat Detail Pesanan" | Red → order detail |
| "Kembali ke Beranda" | Outline → home |

---

### 11. Order Detail Screen (`order-detail.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left |
| "Detail Pesanan" title | Center |
| Invoice number subtitle | Small gray |
| Share button | Right |
| **Status Banner** | |
| Gradient blue card | |
| Status icon + text | "Sedang Diproses" |
| "Estimasi pengiriman" | Date range |
| **Status Timeline** | |
| Vertical line with dots | |
| ✅ Green: Pembayaran Diterima | Completed |
| 🔴 Red pulsing: Sedang Diproses | Current |
| ⚪ Gray: Dikirim, Selesai | Future |
| **Ordered Items** | |
| Item image | Thumbnail |
| Name, qty × price | |
| Line total | |
| Grand total | Red, bold |
| **Shipping Info** | |
| Address card | Full address |
| "Nomor resi akan muncul" | Info text |
| **Action Buttons** | |
| "Unduh Invoice" | Outline |
| "Hubungi Support" | Red → WhatsApp |

---

### 12. Orders Screen (`orders.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left |
| "Pesanan Saya" title | Center |
| **Status Tabs** | |
| Semua | All orders |
| Sedang Diproses | Processing only |
| Selesai | Completed only |
| **Order List** | |
| Order cards | Invoice number, date, status badge, total |
| Status badges | Color-coded per status |
| **Empty State** | When no orders match filter |

---

### 13. Profile Screen (`profile.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left |
| "Profil" title | Center |
| Settings gear icon | Right |
| **User Card** | |
| Dark gradient background | |
| Avatar image | Circular, large |
| Name + email | |
| **Stats Grid (3 cols)** | |
| Pesanan | Count from orders |
| Selesai | Completed count |
| Process | Processing count |
| **Menu List** | |
| Pesanan Saya | Clipboard icon, blue → orders |
| Alamat Pengiriman | Pin icon, red → shipping |
| Pembayaran | Card icon, green → payment methods |
| Bantuan | Headset icon, purple → help |
| **Logout Button** | |
| Red outline | Full width |
| Confirmation dialog | Before logout |

---

### 14. Projects Screen (`projects.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left |
| "Proyek Saya" title | Center |
| "+" button | Right, add project |
| **Stats Grid (3 cols)** | |
| Proyek Aktif | Count |
| Total Item | Sum of items |
| Total Estimasi | Sum of prices |
| **Project Cards** | |
| Project name + date | |
| Share button | |
| Item list (compact) | Image + name + qty × price |
| Footer | Item count + total |
| "Checkout Proyek" | Red → checkout |
| "Ajukan RFQ" | Outline |
| **Create Project Modal** | |
| Bottom sheet | Project name input |
| "Buat Proyek" button | |

---

### 15. Compare Screen (`compare.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left |
| "Bandingkan Produk" title | Center |
| "Hapus Semua" button | Right, red text |
| **Comparison Grid** | |
| Horizontal scrollable | On small screens |
| Column 1: Spec labels | PRODUK, DAYA, TEGANGAN, GARANSI |
| Columns 2-3: Products | Image, name, brand, price, specs |
| Column 4: Add slot | "+ Tambah Produk" dashed circle |
| Remove buttons | × per product |
| **Bottom Row** | |
| "Beli" buttons | Per product → checkout |

---

### 16. Edit Address Screen (`edit-address.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left |
| "Edit Alamat" title | Center |
| **Form Fields** | |
| Nama Depan | Input field |
| Nama Belakang | Input field |
| Nomor Telepon | Input with +62 prefix |
| Alamat Lengkap | Textarea (3 rows) |
| Kota | Input field |
| Kode Pos | Input field |
| **Form Validation** | |
| Required field check | Error message in red |
| **Fixed Bottom Bar** | |
| "Simpan Perubahan" button | Full width, saves to sessionStorage |

---

### 17. Payment Methods Screen (`payment-methods.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left |
| "Metode Pembayaran" title | Center |
| **Saved Payment Methods** | |
| BCA Virtual Account card | Selected, blue border, "Utama" badge |
| **Add New Method** | |
| "+ Tambah Metode Pembayaran" | Bottom sheet option |
| **Info Box** | |
| Payment instructions | Transfer guide |

---

### 18. Cart Screen (`cart.html`)

| Feature | Description |
|---------|-------------|
| **Header** | |
| Back button | Left |
| "Keranjang Belanja" title | Center |
| "Kosongkan" button | Right, red text |
| **Empty State** | |
| Cart icon illustration | Gray circle |
| "Keranjang Kosong" text | |
| "Mulai Belanja" button | Returns to home |
| **Cart Items List** | |
| Product placeholder icon | Box icon (no images in this mockup) |
| Product name | Bold |
| Price | Red |
| Quantity controls | − [qty] + with animated buttons |
| Trash icon on minus | When qty = 1 |
| **Cart Summary** | |
| Total Item count | |
| Subtotal | |
| "Gratis" ongkir | Green text |
| Total price | Large, red |
| **Recommendations** | |
| Horizontal scroll | Product suggestions |
| "Tambah" buttons | Add to cart |
| **Fixed Bottom Bar** | |
| "Lanjut ke Checkout" | Full width |
| **Toast Notifications** | |
| Slide-in confirmation | "Produk ditambahkan", "Item dihapus" |

---

### 19. Additional Screens (Reference Only)

| Screen | Features |
|--------|----------|
| `register.html` | Dark background, form fields (Name, Email, Company, Password, Confirm), validation, "Daftar" button |
| `forgot-password.html` | Email input, "Kirim Link Reset" button |
| `verification.html` | OTP input fields, countdown timer, "Verifikasi" button |

---

## Feature Summary by Category

### Navigation Patterns
- **Bottom Navigation Bar**: 5 tabs (Beranda, Cari, Proyek, Keranjang, Profil)
- **Header Pattern**: Back button + Title + Action button
- **Tab Bar**: Sticky tabs for content sections (Spesifikasi/Dokumen/Kompatibel)
- **Modal/Bottom Sheet**: RFQ, Add Address, Create Project

### Interactive Elements
- **Filter Chips**: Active/inactive states, removable
- **Quantity Selectors**: − [n] + pattern
- **Toast Notifications**: Slide-in confirmations
- **Accordions**: Expandable instruction lists
- **Radio Selection**: Address selection
- **Checkboxes**: Terms, "Ingat saya", "Jadikan utama"

### Data Display Patterns
- **Stock Badges**: Color-coded (Green/Orange/Red)
- **Price Display**: Mitsubishi Red, bold, formatted with `CurrencyFormatter`
- **Timeline**: Vertical dot-and-line for order status
- **Grid Layouts**: 2-column (products), 3-column (stats)
- **Tiered Pricing**: B2B volume discount cards

### E-commerce Features
- **Add to Cart**: From home, product detail
- **Add to Compare**: From home, compare screen
- **Cart Management**: Quantity controls, remove items
- **Checkout Flow**: Address → Payment → Confirmation
- **Order Tracking**: Status timeline, invoice download

---

## ⏱️ Estimated Timeline

| Phase | Description | Effort | Running Total |
|-------|-------------|--------|---------------|
| M2-0 | Project Setup & Dummy Data | 0.5 day | 0.5 day |
| M2-1 | Splash, Login & Register | 0.5 day | 1 day |
| M2-2 | Bottom Nav & Home Screen | 1 day | 2 days |
| M2-3 | Search Results & Product Detail | 1 day | 3 days |
| M2-4 | Cart Screen | 0.5 day | 3.5 days |
| M2-5 | Checkout & Shipping | 1 day | 4.5 days |
| M2-6 | Payment & Payment Success | 0.5 day | 5 days |
| M2-7 | Order Detail | 0.5 day | 5.5 days |
| M2-8 | Profile, Projects & Compare | 1 day | 6.5 days |
| M2-9 | Polish & Device Testing | 1 day | **7.5 days** |

**Total: ~7.5 working days** (1.5 weeks)

---

## 🎯 MILESTONE 2 DEMO CHECKPOINT

> **Present to client (Tahap 2 — Progres 1):**
> - Working app on **physical Android device**
> - Complete customer flow: Splash → Login → Browse → Search → Product Detail → Cart → Checkout → BCA VA Payment → Payment Success → Order Detail
> - All **15 screens** navigable with real product data (**10 dummy products**, real images from OTOMASIKU catalog)
> - Bottom nav with 5 tabs fully functional
> - All prices displayed correctly in Rupiah format
> - Visual fidelity matches HTML mockups
> - Product images are real product photos (not placeholders)
>
> **Deliverable:** Release APK on physical device + screen recording of full flow
>
> **Note:** 10-product dummy catalog documented in `DUMMY_PRODUCT_MAPPING_PLAN.md`
>
> **Payment trigger:** Rp 2.800.000 (40%)