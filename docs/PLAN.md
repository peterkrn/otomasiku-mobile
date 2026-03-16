# 📋 Execution Plan
# Otomasiku Marketplace Mobile App

> **CRITICAL RULE:** Each phase MUST be fully completed, tested, and verified before moving to the next phase. No skipping. No parallel execution of dependent phases. This is a sequential pipeline.

---

## How to Use This Plan

Each phase has:
- **Depends On:** — which phase(s) must be complete before starting
- **Entry Criteria:** — what must be true before you start this phase
- **Tasks:** — what to build, in order
- **Exit Criteria:** — what must be true before this phase is "done"
- **Verification:** — how to prove it's done

If the **Entry Criteria** are not met, STOP. Fix the previous phase first.

---

## Phase 0: Project Scaffolding
**Depends On:** Nothing
**Milestone:** 1 | **Sprint:** 1

### Entry Criteria
- [ ] Git repository created
- [ ] Developer has access to all accounts (Supabase, Railway, Google Play Console)

### Tasks
1. Initialize Flutter project with `flutter create --org com.otomasiku otomasiku_mobile_app`
2. Initialize Express project with `npm init` + TypeScript config
3. Set up monorepo structure:
   ```
   flutter-otomasiku-marketplace/
   ├── otomasiku-mobile-app/          # Flutter
   ├── otomasiku-api/          # Express
   ├── docs/                   # This documentation
   └── ui-otomasiku-marketplace/  # HTML mockups (reference only)
   ```
4. Configure Flutter:
   - Add all approved dependencies to `pubspec.yaml`
   - Set up `analysis_options.yaml` with strict rules
   - Create folder structure per ARCHITECTURE.md
   - Configure Supabase Flutter SDK initialization
   - Configure Dio with base URL and interceptors
5. Configure Express:
   - Add all approved dependencies to `package.json`
   - Set up `tsconfig.json` with strict mode
   - Create folder structure per ARCHITECTURE.md
   - Create `.env.example` with all required variables
   - Set up Pino logger
   - Set up centralized error handler
6. Set up Supabase project:
   - Create Supabase project
   - Note down: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `DATABASE_URL`
   - Enable Email/Password auth
7. Set up Prisma:
   - Initialize Prisma with PostgreSQL
   - Copy schema from ARCHITECTURE.md
   - Run `prisma migrate dev` to create all tables
   - Verify tables exist in Supabase dashboard
8. Set up Railway:
   - Connect Express repo
   - Configure environment variables
   - Verify deploy works with health check endpoint
9. Set up Git:
   - Create `.gitignore` (include `.env`, `node_modules/`, `build/`, etc.)
   - Create `main` and `develop` branches
   - Push initial commit

### Exit Criteria
- [ ] `flutter run` launches a blank app without errors
- [ ] `npm run dev` starts Express on localhost:3000
- [ ] `GET /health` returns `{ status: "ok" }` on both local and Railway
- [ ] Prisma Studio shows all tables (empty) in Supabase PostgreSQL
- [ ] Supabase Auth is enabled (can create test user via dashboard)
- [ ] All `.env.example` files committed, no `.env` files committed

### Verification
```bash
# Flutter
cd otomasiku-mobile-app && flutter run

# Express (local)
cd otomasiku-api && npm run dev
curl http://localhost:3000/api/v1/health

# Express (Railway)
curl https://otomasiku-api-staging.up.railway.app/api/v1/health

# Prisma
cd otomasiku-api && npx prisma studio
```

---

## Phase 1: Authentication System
**Depends On:** Phase 0 ✅
**Milestone:** 2 | **Sprint:** 1

### Entry Criteria
- [ ] Phase 0 Exit Criteria ALL met
- [ ] Supabase project is running with auth enabled
- [ ] Express server is deployed to Railway

### Tasks
1. **Express: Auth middleware**
   - Implement `requireAuth` middleware (verify Supabase JWT)
   - Implement `requireAdmin` middleware (check role in profiles table)
   - Write tests: valid token → pass, expired token → 401, missing token → 401, non-admin → 403
2. **Express: Profile endpoints**
   - `GET /profile` — return own profile
   - `PATCH /profile` — update own profile
   - Both with `requireAuth` middleware
3. **Supabase: Database trigger**
   - Create trigger: on `auth.users` INSERT → create `profiles` row with `role = 'customer'`
   - Test: create user via Supabase dashboard → verify profiles row exists
4. **Flutter: Auth repository**
   - Implement `AuthRepository` using Supabase Flutter SDK
   - Methods: `signUp()`, `signIn()`, `signOut()`, `getCurrentUser()`, `onAuthStateChange()`
5. **Flutter: Auth provider (Riverpod)**
   - Create `authStateProvider` — stream of auth state changes
   - Create `currentUserProvider` — current user profile
6. **Flutter: Login screen**
   - Email + password form with validation
   - Error handling (wrong password, user not found, network error)
   - Navigate to home on success
   - Reference: `ui-otomasiku-marketplace/login.html`
7. **Flutter: Register screen**
   - Email, password, full name, company name
   - Form validation (email format, password min 8 chars)
   - Auto-login after registration
8. **Flutter: Auth guard (GoRouter)**
   - Redirect to login if not authenticated
   - Redirect to home if already authenticated and trying to access login
9. **Flutter: Secure token storage**
   - Store Supabase session in `flutter_secure_storage`
   - Auto-restore session on app restart

### Exit Criteria
- [ ] User can register → profile row created automatically
- [ ] User can login → JWT stored securely → navigated to home
- [ ] User can logout → token cleared → redirected to login
- [ ] App restart → session restored → user stays logged in
- [ ] Express `requireAuth` correctly blocks unauthenticated requests
- [ ] Express `requireAdmin` correctly blocks non-admin users
- [ ] Invalid/expired tokens return 401

### Verification
```bash
# Test auth middleware
curl -X GET http://localhost:3000/api/v1/profile  # → 401
curl -X GET http://localhost:3000/api/v1/profile -H "Authorization: Bearer <valid_token>"  # → 200
```

---

## Phase 2: Product Catalog (Read-Only)
**Depends On:** Phase 1 ✅
**Milestone:** 2 | **Sprint:** 1

### Entry Criteria
- [ ] Phase 1 Exit Criteria ALL met
- [ ] Auth system fully working end-to-end

### Tasks
1. **Express: Product endpoints (public)**
   - `GET /products` — list with pagination, search, filter, sort
   - `GET /products/:id` — single product detail
   - Zod validation for query params
   - Test: search, filter by category, pagination, sort by price
2. **Express: Seed products**
   - Create seed script (`prisma/seed.ts`)
   - Seed all **125 products** from `DUMMY_PRODUCT_MAPPING_PLAN.md` catalog across categories with real pricing and stock data
   - Run seed: `npx prisma db seed`
3. **Flutter: Product model**
   - `Product` data class with `fromJson` / `toJson`
   - Price as `int` (BigInt from API comes as string, parse to int)
4. **Flutter: Product repository**
   - `getProducts()` with search, filter, sort, pagination params
   - `getProductById()`
5. **Flutter: Home screen (product catalog)**
   - Product grid view (2 columns on mobile)
   - Category filter chips
   - Search bar with debounce
   - Infinite scroll pagination
   - Pull-to-refresh
   - Reference: `ui-otomasiku-marketplace/home.html`
6. **Flutter: Product detail screen**
   - Image gallery (carousel + zoom)
   - Product info: name, price, original price (strikethrough), description, stock, category
   - Stock badge: "Ready Stock" / "Sisa X Unit" / "Habis"
   - Quantity selector
   - Add to Cart button (wired up in Phase 3)
   - Reference: `ui-otomasiku-marketplace/product-detail.html`
7. **Flutter: Search results screen**
   - Full-page search with results
   - Reference: `ui-otomasiku-marketplace/search-results.html`
8. **Flutter: Shared widgets**
   - `ProductCard` widget
   - `PriceText` widget (currency formatted)
   - `StockBadge` widget
   - `BottomNavBar` widget

### Exit Criteria
- [ ] `GET /products` returns paginated products with correct data
- [ ] `GET /products?search=inverter` returns filtered results
- [ ] `GET /products?category=automation` returns category-filtered results
- [ ] `GET /products/:id` returns single product with all fields
- [ ] Home screen shows product grid, search works, filter works
- [ ] Infinite scroll loads more products
- [ ] Product detail screen shows all info correctly
- [ ] Prices display as "Rp 12.500.000" (properly formatted)
- [ ] Stock badges show correct state

---

## Phase 3: Cart System
**Depends On:** Phase 2 ✅
**Milestone:** 2 | **Sprint:** 1

### Entry Criteria
- [ ] Phase 2 Exit Criteria ALL met
- [ ] Products display correctly in the app (125 products from catalog)
- [ ] Auth token is sent with all Dio requests (interceptor working)

### Tasks
1. **Express: Cart endpoints**
   - `GET /cart` — get user's cart with product details
   - `POST /cart` — add item (upsert: if product already in cart, increment qty)
   - `PATCH /cart/:id` — update quantity
   - `DELETE /cart/:id` — remove item
   - `DELETE /cart` — clear entire cart
   - All with `requireAuth` + ownership validation
   - Zod schemas for POST and PATCH
2. **Flutter: Cart model**
   - `CartItem` data class with nested `Product`
3. **Flutter: Cart repository**
   - All CRUD operations matching Express endpoints
4. **Flutter: Cart provider (Riverpod)**
   - Cart items state
   - Add to cart action
   - Update quantity action
   - Remove item action
   - Computed: total items count (for badge), total price
5. **Flutter: Cart screen (dedicated tab)**
   - Dedicated cart screen accessible from the Keranjang tab in bottom navigation
   - List of cart items with product image, name, price, quantity
   - Quantity controls (+/-)
   - Remove item (swipe or button)
   - Cart summary: subtotal
   - "Proceed to Checkout" button
   - Empty cart state
   - Reference: `ui-otomasiku-marketplace/checkout.html` (items section)
6. **Flutter: Wire up "Add to Cart"**
   - Product detail screen → Add to Cart button now functional
   - Cart badge on Keranjang tab in bottom nav shows item count
7. **Flutter: Cart badge on bottom nav**
   - Show count of items in cart on the Keranjang (cart) tab icon

### Exit Criteria
- [ ] Cart screen is a dedicated tab (Keranjang) in bottom nav
- [ ] User can add product to cart from product detail
- [ ] Cart screen shows all items with correct prices
- [ ] Quantity can be updated (+/-), total recalculates
- [ ] Items can be removed from cart
- [ ] Cart badge shows correct count
- [ ] Empty cart shows appropriate empty state
- [ ] Cart persists across app restarts (server-side)
- [ ] User A cannot see User B's cart (ownership enforced)

---

## Phase 4: Checkout & Order Creation
**Depends On:** Phase 3 ✅
**Milestone:** 2 | **Sprint:** 2

### Entry Criteria
- [ ] Phase 3 Exit Criteria ALL met
- [ ] Cart is fully functional
- [ ] User can add, update, remove cart items

### Tasks
1. **Express: Address endpoints**
   - `GET /addresses` — list user's addresses
   - `POST /addresses` — add new address
   - `PUT /addresses/:id` — update address
   - `DELETE /addresses/:id` — delete address
   - All with `requireAuth` + ownership validation
   - Zod schemas for POST and PUT
2. **Express: Order creation (CRITICAL)**
   - `POST /orders` — the transactional order creation from ARCHITECTURE.md
   - Atomic: validate stock → create order → deduct stock → clear cart
   - All inside `prisma.$transaction`
   - Test edge cases: empty cart, insufficient stock, unpublished product, concurrent orders
3. **Express: Order read endpoints**
   - `GET /orders` — list user's orders
   - `GET /orders/:id` — order detail with items, address, payment proofs
   - Ownership enforced: user can only see their own orders
4. **Flutter: Address management**
   - Address model, repository, provider
   - Address list screen (from profile)
   - Add/edit address form
   - Reference: `ui-otomasiku-marketplace/shipping.html`
5. **Flutter: Checkout screen**
   - Select delivery address (from saved addresses or add new)
   - Order summary: items, subtotal, shipping (free for v1), total
   - Notes field (optional)
   - Terms checkbox
   - "Place Order" button → calls `POST /orders`
   - Loading state while creating order
   - Reference: `ui-otomasiku-marketplace/checkout.html`
6. **Flutter: Order success → BCA VA Payment screen**
   - After successful order creation, navigate to payment screen
   - Show BCA Virtual Account number (from API response)
   - Show order total amount to transfer
   - Show payment expiry countdown (24 hours)
   - Copy VA number button
   - "Payment instructions" section
   - Reference: `ui-otomasiku-marketplace/payment.html`

### Exit Criteria
- [ ] User can manage addresses (CRUD)
- [ ] Checkout screen shows correct address, items, total
- [ ] Place Order creates order, deducts stock, clears cart (atomic)
- [ ] Place Order also generates a BCA Virtual Account number
- [ ] Insufficient stock shows clear error message
- [ ] After order, cart is empty
- [ ] After order, product stock is reduced
- [ ] Payment screen shows BCA VA number, total amount, and expiry countdown
- [ ] User can copy VA number to clipboard
- [ ] User can see order in their order list
- [ ] User can see order detail with all items

---

## Phase 5: BCA Virtual Account Payment & Order Tracking
**Depends On:** Phase 4 ✅
**Milestone:** 2 | **Sprint:** 2

### Entry Criteria
- [ ] Phase 4 Exit Criteria ALL met
- [ ] Orders can be created successfully
- [ ] BCA VA number is generated and displayed after order creation
- [ ] BCA Developer API credentials are configured in `.env`

### Tasks
1. **Express: BCA Developer API integration**
   - Implement `bca.ts` config — BCA API client with OAuth token management
   - Implement `payment.service.ts` — BCA VA creation, callback handling, status checking
   - VA creation: call BCA API to generate VA number on order creation
   - VA expiry: 24 hours from creation
   - Handle BCA API errors gracefully (retry on transient, fail on permanent)
2. **Express: BCA callback webhook**
   - `POST /payments/bca/callback` — receive payment confirmation from BCA
   - Implement `bca-signature.ts` middleware — validate HMAC-SHA256 signature from BCA
   - On valid callback: update order `payment_status` to `'paid'`, record payment timestamp
   - On valid callback: trigger email notification to company
   - Zod schema: `bcaCallbackSchema` for payload validation
   - This endpoint is PUBLIC (no JWT auth) but protected by BCA signature verification
3. **Express: Payment status endpoint**
   - `GET /orders/:id/payment-status` — return current payment status + VA number + expiry
   - With `requireAuth` + ownership validation
4. **Express: Email notification service**
   - Implement `email.service.ts` using Nodemailer (or SendGrid)
   - After BCA callback confirms payment: send email to `COMPANY_EMAIL`
   - Email content: order number, customer name, items, shipping address, total amount
   - Company receives email → manually ships the order
5. **Express: Payment expiry handling**
   - Cron job or scheduled check: mark orders as `'expired'` if unpaid after 24 hours
   - Restore stock for expired orders
6. **Flutter: Payment status polling**
   - After order creation, poll `GET /orders/:id/payment-status` every 10 seconds
   - When status changes to `'paid'` → navigate to payment success screen
   - Show real-time status: "Menunggu Pembayaran" → "Pembayaran Diterima"
7. **Flutter: Payment success screen**
   - Confirmation display after payment verified by BCA callback
   - Order summary
   - "Lihat Pesanan" button → navigate to order detail
   - Reference: `ui-otomasiku-marketplace/payment-success.html`
8. **Flutter: Order list screen**
   - List all orders with: order number, date, status badge, total amount
   - Filter by status (optional)
   - Reference: `ui-otomasiku-marketplace/profile.html` (orders section)
9. **Flutter: Order detail screen**
   - Order info: number, date, status
   - Status timeline (visual stepper): Unpaid → Paid → Shipped → Completed
   - Items list
   - Delivery address
   - Payment status + VA number (if still unpaid)
   - Reference: `ui-otomasiku-marketplace/order-detail.html`

### Exit Criteria
- [ ] BCA VA is generated on order creation and displayed to user
- [ ] BCA callback webhook validates signature and updates payment status
- [ ] After customer pays via BCA (bank transfer to VA), order auto-updates to 'paid'
- [ ] Email is sent to company after payment confirmed (with order + shipping details)
- [ ] Payment expiry works: orders unpaid after 24h marked as 'expired', stock restored
- [ ] Flutter polls payment status and auto-navigates on success
- [ ] Order list shows all orders with correct statuses
- [ ] Order detail shows timeline, items, address, payment info
- [ ] No manual payment verification needed — fully automated via BCA callback

---

## Phase 6: Profile & Address Management
**Depends On:** Phase 5 ✅
**Milestone:** 2 | **Sprint:** 2

### Entry Criteria
- [ ] Phase 5 Exit Criteria ALL met

### Tasks
1. **Flutter: Profile screen**
   - Display: name, email, company, phone, avatar
   - Edit profile (name, phone, company)
   - Change password (via Supabase Auth)
   - Order count summary
   - Reference: `ui-otomasiku-marketplace/profile.html`
2. **Flutter: Complete address management**
   - Ensure add/edit/delete/set-default all work from profile
   - Address used in checkout is selectable
3. **Flutter: Bottom navigation**
   - Wire up all 5 tabs: Beranda, Cari, Proyek, Keranjang, Profil
   - Keranjang tab navigates to the dedicated Cart screen (from Phase 3)
   - Cart badge on Keranjang tab icon shows item count
   - Correct active states (Mitsubishi Red `#E7192D`)

### Exit Criteria
- [ ] Profile displays all user info correctly
- [ ] User can edit profile info
- [ ] User can change password
- [ ] Address management is complete and works from both profile and checkout
- [ ] Bottom navigation works correctly across all tabs
- [ ] All customer-facing screens are complete and navigable

---

## 🎯 MILESTONE 2 DEMO CHECKPOINT
> **Before proceeding to Phase 7, present to client:**
> - Working app on physical Android device
> - Complete flow: browse → cart → checkout → BCA VA payment → auto-verify → order tracking
> - All customer screens functional

---

## Phase 7: Admin Dashboard
**Depends On:** Phase 6 ✅
**Milestone:** 3 | **Sprint:** 3

### Entry Criteria
- [ ] Phase 6 Exit Criteria ALL met
- [ ] All customer-facing features complete
- [ ] At least 1 admin account exists in database

### Tasks
1. **Express: Admin endpoints**
   - `GET /admin/dashboard` — summary stats (order count, revenue, paid orders, low stock)
   - `GET /admin/orders` — list all orders with filters (status, date range, search)
   - `GET /admin/orders/:id` — any order detail (no ownership check, admin sees all)
   - `PATCH /admin/orders/:id/status` — update order status (processing → shipped → completed)
   - All with `requireAuth` + `requireAdmin`
   - Note: Payment verification is automated via BCA callback — no manual verify endpoint needed
2. **Express: Admin product management**
   - `POST /products` — create new product (with image upload)
   - `PUT /products/:id` — update product
   - `DELETE /products/:id` — soft delete (`is_published = false`)
   - `PATCH /products/:id/stock` — update stock
   - `POST /products/:id/images` — upload product images
   - All with `requireAuth` + `requireAdmin`
3. **Express: CSV Export**
   - `GET /admin/orders/export` — export orders as CSV
   - Filter by date range
   - Use `json2csv` library
4. **Supabase: Product images storage**
   - Create `product-images` bucket (public read, admin write)
5. **Flutter Web: Admin shell**
   - Admin login (role-based redirect)
   - Admin layout with sidebar navigation
   - Dashboard overview (stats cards)
6. **Flutter Web: Product management**
   - Product list table with search/filter
   - Add product form with image upload
   - Edit product form
   - Delete product (with confirmation)
   - Stock update
7. **Flutter Web: Order management**
   - Order list table with status filter
   - Order detail view
   - Payment status display (auto-verified by BCA callback: Unpaid / Paid / Expired)
   - Update order status dropdown (processing → shipped → completed)
   - Admin notes field
8. **Flutter Web: Export**
   - Export button → download CSV

### Exit Criteria
- [ ] Admin can login and see dashboard with stats
- [ ] Admin can CRUD products with image upload
- [ ] Admin can view all orders with filters
- [ ] Admin can see payment status (auto-verified by BCA callback)
- [ ] Admin can update order status through the lifecycle (processing → shipped → completed)
- [ ] Admin can export orders to CSV
- [ ] Non-admin users cannot access admin endpoints (403)

---

## Phase 8: Testing & QA
**Depends On:** Phase 7 ✅
**Milestone:** 3 | **Sprint:** 3

### Entry Criteria
- [ ] Phase 7 Exit Criteria ALL met
- [ ] All features (customer + admin) are complete

### Tasks
1. **End-to-end test: Customer flow**
   - Register → browse → search → filter → detail → add to cart → checkout → place order → receive BCA VA → pay (simulated callback) → payment auto-verified → track order
   - Test with real Supabase (staging environment)
2. **End-to-end test: Admin flow**
   - Login → dashboard → view orders → see auto-verified payments → update status → manage products → export CSV
3. **Edge case testing**
   - Empty cart checkout attempt
   - Insufficient stock (concurrent purchases)
   - Invalid file upload (wrong type, too large)
   - Expired auth token → re-login flow
   - Network error handling (offline scenarios)
   - Large product catalog (125 products) performance
4. **Security testing**
   - Attempt to access other user's orders via API
   - Attempt to access admin endpoints as customer
   - Attempt to send fake BCA callback without valid HMAC-SHA256 signature
   - Verify BCA callback endpoint rejects tampered payloads
   - Verify RLS policies block direct SDK access to other users' data
5. **Bug fixes**
   - Triage all bugs: critical → major → minor
   - Fix ALL critical and major bugs
   - Document minor bugs as known issues
6. **Performance check**
   - API response times < 500ms
   - App cold start < 3 seconds
   - Image loading with caching works

### Exit Criteria
- [ ] Full customer flow works end-to-end without errors
- [ ] Full admin flow works end-to-end without errors
- [ ] All critical and major bugs fixed
- [ ] Security tests pass (no unauthorized access possible)
- [ ] Performance targets met
- [ ] No crash on normal usage patterns

---

## Phase 9: Production Preparation
**Depends On:** Phase 8 ✅
**Milestone:** 3 | **Sprint:** 3

### Entry Criteria
- [ ] Phase 8 Exit Criteria ALL met
- [ ] All bugs fixed, QA passed

### Tasks
1. **Express: Production config**
   - Set `NODE_ENV=production`
   - Verify all environment variables set on Railway
   - Enable `helmet` security headers
   - Verify CORS configured for production domains only
   - Verify rate limiting is active
   - Health check endpoint working
2. **Supabase: Production hardening**
   - Verify all RLS policies are active
   - Verify storage bucket policies are correct
   - Verify no test data in production
   - Enable Supabase backups
3. **Flutter: Release build**
   - `flutter build appbundle --release`
   - Code obfuscation enabled
   - ProGuard rules configured
   - Firebase Crashlytics SDK integrated
   - Verify release build works on physical device
4. **Seed production data**
   - Input **125 real products** from `DUMMY_PRODUCT_MAPPING_PLAN.md` catalog (already mapped with real images)
   - Upload real product images (1,323 files from `ALL_FOTO_PRODUK_OTOMASIKU` — primary images already organized per `DUMMY_PRODUCT_MAPPING_PLAN.md` § 5)
   - Create admin account(s)
   - Verify BCA Developer API credentials are set for production
   - Verify company email is configured for order notifications
5. **Prepare Play Store assets**
   - App icon (512x512)
   - Feature graphic (1024x500)
   - Screenshots (portrait, at least 4)
   - Short description (Bahasa Indonesia)
   - Full description (Bahasa Indonesia)
   - Privacy policy URL

### Exit Criteria
- [ ] Release APK/AAB runs without errors on physical device
- [ ] Firebase Crashlytics receives test crash
- [ ] Express production environment is secured and stable
- [ ] 125 real products loaded with images (from DUMMY_PRODUCT_MAPPING_PLAN.md catalog)
- [ ] All Play Store assets ready
- [ ] Privacy policy published

---

## 🎯 MILESTONE 3 DEMO CHECKPOINT
> **Before proceeding to Phase 10, present to client:**
> - Final version with all features
> - Real product data (125 products with real images)
> - Admin dashboard live
> - Ready for Play Store submission

---

## Phase 10: Play Store Release
**Depends On:** Phase 9 ✅
**Milestone:** 4 | **Sprint:** 4

### Entry Criteria
- [ ] Phase 9 Exit Criteria ALL met
- [ ] Client has approved the final demo
- [ ] All Play Store assets are ready
- [ ] Google Play Console access is set up

### Tasks
1. Upload signed AAB to Play Console
2. Fill all store listing metadata
3. Submit to Closed Testing (alpha track)
4. Invite testers (client + team)
5. Fix any issues from alpha testing
6. Submit to Production track with 20% staged rollout
7. Monitor for crashes and rejections

### Exit Criteria
- [ ] App is live on Google Play Store
- [ ] Staged rollout at 20% — no critical crashes
- [ ] Play Console shows no policy violations

---

## Phase 11: Post-Launch & Handover
**Depends On:** Phase 10 ✅
**Milestone:** 4 | **Sprint:** 4

### Entry Criteria
- [ ] Phase 10 Exit Criteria ALL met
- [ ] App is live on Play Store

### Tasks
1. Monitor crash rate via Firebase Crashlytics (target: >99% crash-free)
2. Monitor Play Store reviews and ratings
3. Increase rollout: 20% → 50% → 100%
4. Hotfix any critical issues
5. Prepare handover documentation:
   - API documentation
   - Environment variables guide
   - How to deploy updates
   - How to manage products/orders
   - All account credentials
6. Handover meeting with client
   - Transfer all access: Git repo, Supabase, Railway, Play Console, domain
   - Sign BAP (Berita Acara Penyerahan)

### Exit Criteria
- [ ] App at 100% rollout with crash rate < 1%
- [ ] All documentation complete
- [ ] All access transferred to client
- [ ] BAP signed

---

## 🎯 MILESTONE 4 — PROJECT COMPLETE ✅