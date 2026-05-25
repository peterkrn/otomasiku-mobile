# 📋 Product Requirements Document (PRD)
# Otomasiku Marketplace Mobile App

---

## 📌 Project Overview

| Field              | Detail                                                         |
| ------------------ | -------------------------------------------------------------- |
| **Project Name**   | Otomasiku Marketplace Mobile App                               |
| **Platform**       | Android (Flutter) + Admin Web (Flutter Web)                    |
| **Target Segment** | B2B — Perusahaan industri, kontraktor, procurement managers    |
| **Project Owner**  | John Doe (Project Manager)                                      |
| **CTO**            | -                                                              |
| **Developer**      | -                                                              |
| **Start Date**     | 6 Maret 2026                                                   |
| **Target Release** | Mei 2026                                                       |
| **Live Domain**    | [otomasiku.com](https://otomasiku.com)                         |
| **Architecture**   | Hybrid: Supabase (Auth/DB/Storage) + Express.js API (Railway)  |

---

## 🎯 Objectives

1. Membangun aplikasi marketplace Android berbasis Flutter untuk produk industri Otomasiku.
2. Menyediakan katalog produk digital yang informatif dan mudah diakses.
3. Menyediakan alur pembelian sederhana dengan sistem pembayaran BCA Virtual Account (terintegrasi BCA Developer API).
4. Menyediakan dashboard admin (Flutter Web) untuk mengelola produk, pesanan, dan data operasional.
5. Merilis aplikasi ke Google Play Store dan memastikan kesiapan produksi.

---

## 👥 Target Users

### Customer (End User)

- Procurement manager / purchasing staff di perusahaan industri
- Kontraktor proyek yang membutuhkan parts & peralatan
- Teknisi / engineer yang mencari spareparts spesifik

### Admin (Internal)

- Tim Otomasiku yang mengelola katalog produk, stok, pesanan, dan laporan

---

## 🧱 Tech Stack

### Architecture Overview

> **CTO Note — Hybrid Architecture:**
> Otomasiku menggunakan arsitektur hybrid: **Supabase** sebagai managed infrastructure layer (auth, database, storage, realtime) dan **Express.js (TypeScript)** sebagai custom API layer untuk business logic yang memerlukan server-side control.
>
> **Mengapa hybrid, bukan pure Supabase?**
> - Supabase Edge Functions (Deno) memiliki cold start, limited debugging, dan vendor lock-in pada business logic
> - Express memberi kita **full control** atas order flow, payment verification, stock management, dan admin operations
> - Supabase tetap unggul untuk auth, RLS, storage policies, dan realtime — kita tidak perlu rebuild itu
> - Jika suatu hari kita pindah dari Supabase, business logic kita tetap utuh di Express server
>
> **Aturan pembagian tanggung jawab:**
> | Concern | Handled By | Reasoning |
> |---------|-----------|-----------|
> | Authentication & session | Supabase Auth | Battle-tested, JWT auto-refresh, RLS integration |
> | Database & RLS policies | Supabase PostgreSQL | Row-level security enforced at DB level — safety net even if API has bugs |
> | File storage & CDN | Supabase Storage | Managed, with access policies, built-in CDN |
> | Business logic (orders, payments, stock) | Express.js API | Needs transaction control, custom validation, complex multi-step flows |
> | Admin operations (CRUD, export) | Express.js API | Needs role verification, audit logging, data transformation |
> | Realtime (future) | Supabase Realtime | WebSocket order status updates without custom infra |

### Frontend (Mobile & Admin)

| Layer            | Technology                   | Justification                                                                          |
| ---------------- | ---------------------------- | -------------------------------------------------------------------------------------- |
| Framework        | Flutter (Dart)               | Single codebase untuk Android app + Admin web panel                                    |
| State Management | Riverpod                     | Type-safe, testable, scalable — recommended untuk production Flutter apps               |
| Navigation       | GoRouter                     | Declarative routing yang mendukung deep linking & guard-based auth redirect             |
| API Client (Supabase) | Supabase Flutter SDK   | Direct integration untuk auth, storage, dan realtime subscriptions                     |
| API Client (Express) | Dio + Retrofit           | Type-safe HTTP client untuk custom API calls ke Express server                         |
| Secure Storage   | flutter_secure_storage       | Token & credential tersimpan di Android Keystore (hardware-encrypted)                  |
| Image Caching    | cached_network_image         | Offline-capable image loading dari Supabase Storage CDN                                |
| Forms            | flutter_form_builder         | Opsi reusable form widget untuk checkout & admin input                                 |

> **CTO Note — Dual API client pattern:**
> Flutter app berkomunikasi dengan **dua backend**:
> 1. **Supabase SDK** — untuk auth (login/register/logout), storage (upload foto), dan read-only queries sederhana (product catalog)
> 2. **Dio → Express API** — untuk semua write operations dan business logic (create order, verify payment, update stock, admin actions)
>
> Supabase Auth JWT token digunakan untuk **kedua** koneksi. Express memverifikasi token yang sama via Supabase Admin SDK.
>
> ```
> Flutter App
>   ├── Supabase SDK ──→ Supabase (Auth, Storage, simple reads)
>   └── Dio/Retrofit ──→ Express API ──→ Supabase DB (via Supabase Admin SDK)
> ```

### Backend — Express.js (Custom API)

| Layer            | Technology                   | Justification                                                                          |
| ---------------- | ---------------------------- | -------------------------------------------------------------------------------------- |
| Runtime          | Node.js 20 LTS              | Stable, long-term support, mature ecosystem                                            |
| Framework        | Express.js                   | Minimal, well-documented, 15+ years of battle-testing. We don't need NestJS complexity for ~20 endpoints |
| Language         | TypeScript (strict mode)     | Catches bugs at compile time — critical when handling payment amounts & order states. Self-documenting code. |
| ORM              | Prisma                       | Type-safe DB queries auto-generated from schema, migration tracking, protection against SQL injection |
| Validation       | Zod                          | Runtime request validation with TypeScript type inference — one schema for validation AND types |
| Auth Middleware   | Supabase Admin SDK (@supabase/supabase-js) | Verify JWT tokens issued by Supabase Auth. Single source of truth for auth. |
| File Upload      | Multer + Supabase Storage SDK | Multer handles multipart parsing, then we upload to Supabase Storage server-side for validation |
| Logging          | Pino                         | Structured JSON logging — searchable, parseable, fast. Critical for debugging payment issues |
| Error Handling   | Custom middleware             | Centralized error handler with proper HTTP status codes and client-safe error messages |
| Rate Limiting    | express-rate-limit            | Prevent brute-force and abuse on payment & auth-adjacent endpoints |
| CORS             | cors                         | Configured for Flutter app and admin web panel origins only |
| Environment      | dotenv                       | Environment-specific config (dev/staging/prod) without hardcoded secrets |
| Deployment       | Railway                      | One-click deploy from Git, auto-HTTPS, auto-scaling, $5/month starting |

> **CTO Note — Why Prisma connects to the same Supabase PostgreSQL:**
> We are NOT running two databases. Prisma connects directly to the Supabase PostgreSQL instance using the `DATABASE_URL` connection string from Supabase dashboard. This means:
> - One source of truth for all data
> - Prisma handles complex transactions (order creation + stock deduction in one atomic operation)
> - Supabase RLS still works as a safety net on direct SDK access
> - Prisma migrations and Supabase migrations coexist — but we use **Prisma as the single migration tool** to avoid conflicts
>
> ```
> Flutter App
>   ├── Supabase SDK ──→ Supabase Auth / Storage / PostgREST (with RLS)
>   │
>   └── Dio ──→ Express API (Railway)
>                  ├── Supabase Admin SDK (verify JWT, manage auth)
>                  └── Prisma ORM ──→ Supabase PostgreSQL (same DB, bypasses RLS with service role)
> ```
>
> **Important:** Express uses the Supabase `service_role` key via Prisma, which **bypasses RLS**. This is intentional — our Express API enforces authorization in middleware, and needs full DB access for transactions. The service_role key is NEVER exposed to the client.

### Backend — Supabase (Managed Infrastructure)

| Layer        | Technology                        | Justification                                                                                                     |
| ------------ | --------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Database     | PostgreSQL (via Supabase)         | ACID-compliant relational DB — critical untuk transactional data (orders, payments, stock). Industry standard.     |
| Auth         | Supabase Auth                     | Email/password auth, JWT with auto-refresh, Row-Level Security (RLS) — users cannot access each other's data even if Express API has bugs |
| Storage      | Supabase Storage                  | Image storage with built-in CDN, access policies, dan direct upload dari Flutter SDK                              |
| Realtime     | Supabase Realtime (future v2)     | WebSocket-based live updates untuk order status tanpa polling                                                     |
| Deployment   | Supabase Cloud (managed)          | Zero infrastructure management, auto-scaling, built-in backups, SOC2 compliant                                    |

### Payment

| Layer   | Technology                        | Justification                                                                              |
| ------- | --------------------------------- | ------------------------------------------------------------------------------------------ |
| Payment | BCA Virtual Account (BCA Developer API) | Integrated with BCA Developer API for automatic VA number generation and real-time payment callback verification. Customer pays via BCA transfer (Mobile Banking/ATM/Internet Banking) to a generated VA number. BCA sends callback to our Express API upon successful payment. Appropriate for B2B with high-value orders where bank transfer is industry standard. |
| Email   | Nodemailer (or SendGrid)         | After payment confirmed via BCA callback, Express sends email notification to company (Otomasiku internal) with order details. Company then manually processes and ships the order to the customer's address. |

> **CTO Note — Payment Flow (BCA Virtual Account):**

**Milestone 2 Exception — BCA Sandbox Only:**
For Milestone 2 (UI-only phase), a mini Express backend is deployed solely for BCA Developer API Sandbox integration. This mini backend has exactly 2 endpoints:
1. `POST /payment/create-va` — Creates BCA Virtual Account number
2. `POST /payment/callback` — Receives BCA payment callback with HMAC-SHA256 validation

All other features (auth, products, cart, orders, profile) use hardcoded dummy data in Flutter during Milestone 2. The full Express API backend is implemented in Milestone 3.
> Payment flow is fully automated via BCA Developer API callback — no manual verification needed:
> 1. Customer places order → Express calls **BCA Developer API** to create a Virtual Account number
> 2. Express stores the VA number + expiry time in the `orders` table
> 3. Flutter displays the VA number + payment deadline to the customer
> 4. Customer transfers to the VA number via BCA Mobile/ATM/Internet Banking (outside our app)
> 5. BCA sends **HTTP callback** to our Express API webhook endpoint confirming payment
> 6. Express webhook handler validates the callback signature (using BCA API secret), updates `payment_status` to `paid` and `order status` to `confirmed` in a single Prisma transaction
> 7. Express sends **email to company** (Otomasiku internal) with order details + customer address
> 8. Company manually prepares and ships the order to the customer's given address
>
> **Why BCA VA instead of manual transfer?**
> - Automatic payment verification — no admin bottleneck for verifying transfer proofs
> - Unique VA per order — no ambiguity about which payment belongs to which order
> - BCA is the most widely used bank for B2B transactions in Indonesia
> - Real-time callback — order status updates instantly upon payment
>
> **Security:** BCA callback endpoint MUST validate the `X-BCA-Signature` header using HMAC-SHA256 with our BCA API secret. Replay attacks are prevented by checking the transaction ID hasn't been processed before.

### Monitoring & Observability

| Layer              | Technology             | Justification                                                        |
| ------------------ | ---------------------- | -------------------------------------------------------------------- |
| Crash Reporting    | Firebase Crashlytics   | Real-time crash reporting di production, ANR tracking                |
| API Logging        | Pino (Express)         | Structured JSON logs — every order creation, payment verification logged |
| Uptime Monitoring  | Railway built-in       | Auto-restart on crash, health check endpoint                         |

### Future Considerations (Post-v1)

| Technology        | Use Case                                                                 |
| ----------------- | ------------------------------------------------------------------------ |
| Redis             | Caching layer jika API response times perlu optimization (>10K daily users) |
| Supabase Realtime | Live order status updates tanpa polling (WebSocket-based)                |
| Push Notifications (FCM) | Notify customer saat status pesanan berubah, notify admin saat ada order baru |
| Sentry            | Error tracking di Express API (lebih detail dari logs saja)              |
| Additional Banks  | Mandiri VA, BNI VA, BRI VA — jika customer base membutuhkan opsi bank lain |
| PPN / Volume Discount | Tax calculation dan tiered pricing — to be discussed                 |

---

## 🏗️ Express API Design

### Base URL

| Environment | URL |
|-------------|-----|
| Development | `http://localhost:3000/api/v1` |
| Staging     | `https://otomasiku-api-staging.up.railway.app/api/v1` |
| Production  | `https://api.otomasiku.com/api/v1` (custom domain via Railway) |

### Authentication Middleware

Every request to Express API includes the Supabase JWT token in the `Authorization` header. Express verifies it:

```typescript
// middleware/auth.ts
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export const requireAuth = async (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'Missing auth token' });

  const { data: { user }, error } = await supabase.auth.getUser(token);
  if (error || !user) return res.status(401).json({ error: 'Invalid or expired token' });

  req.user = user;
  next();
};

export const requireAdmin = async (req: Request, res: Response, next: NextFunction) => {
  const profile = await prisma.profile.findUnique({ where: { id: req.user.id } });
  if (profile?.role !== 'admin') return res.status(403).json({ error: 'Admin access required' });
  next();
};
```

### API Endpoints

#### Products (Public Read, Admin Write)

| Method | Endpoint                  | Auth     | Description                          |
| ------ | ------------------------- | -------- | ------------------------------------ |
| GET    | `/products`               | Public   | List products (paginated, filterable) |
| GET    | `/products/:id`           | Public   | Get product detail by ID              |
| POST   | `/products`               | Admin    | Create new product                    |
| PUT    | `/products/:id`           | Admin    | Update product                        |
| DELETE | `/products/:id`           | Admin    | Soft-delete product                   |
| PATCH  | `/products/:id/stock`     | Admin    | Update stock only                     |
| POST   | `/products/:id/images`    | Admin    | Upload product images                 |

**Query parameters for `GET /products`:**
```
?search=valve&category=automation&sort=price_asc&page=1&limit=20
```

#### Cart (Authenticated)

| Method | Endpoint                  | Auth     | Description                          |
| ------ | ------------------------- | -------- | ------------------------------------ |
| GET    | `/cart`                   | Customer | Get user's cart items                 |
| POST   | `/cart`                   | Customer | Add item to cart                      |
| PATCH  | `/cart/:id`               | Customer | Update quantity                       |
| DELETE | `/cart/:id`               | Customer | Remove item from cart                 |
| DELETE | `/cart`                   | Customer | Clear entire cart                     |

#### Orders (Authenticated)

| Method | Endpoint                      | Auth     | Description                          |
| ------ | ----------------------------- | -------- | ------------------------------------ |
| POST   | `/orders`                     | Customer | Create order from cart (transactional: validate stock → create order → deduct stock → clear cart → create BCA VA) |
| GET    | `/orders`                     | Customer | List user's orders                    |
| GET    | `/orders/:id`                 | Customer | Get order detail (ownership verified) |
| GET    | `/admin/orders`               | Admin    | List all orders (filterable)          |
| GET    | `/admin/orders/:id`           | Admin    | Get any order detail                  |
| PATCH  | `/admin/orders/:id/status`    | Admin    | Update order status                   |
| GET    | `/admin/orders/export`        | Admin    | Export orders to CSV                  |

#### Payment — BCA Virtual Account (Webhook)

| Method | Endpoint                      | Auth          | Description                          |
| ------ | ----------------------------- | ------------- | ------------------------------------ |
| POST   | `/payments/bca/callback`      | BCA Signature | BCA payment callback webhook — validates signature, updates payment_status & order_status |
| GET    | `/orders/:id/payment-status`  | Customer      | Check payment status for an order     |

#### Addresses (Authenticated)

| Method | Endpoint              | Auth     | Description                          |
| ------ | --------------------- | -------- | ------------------------------------ |
| GET    | `/addresses`          | Customer | List user's addresses                 |
| POST   | `/addresses`          | Customer | Add new address                       |
| PUT    | `/addresses/:id`      | Customer | Update address                        |
| DELETE | `/addresses/:id`      | Customer | Delete address                        |

#### Profile (Authenticated)

| Method | Endpoint              | Auth     | Description                          |
| ------ | --------------------- | -------- | ------------------------------------ |
| GET    | `/profile`            | Customer | Get own profile                       |
| PATCH  | `/profile`            | Customer | Update own profile                    |

#### Admin Dashboard (Admin only)

| Method | Endpoint                  | Auth     | Description                          |
| ------ | ------------------------- | -------- | ------------------------------------ |
| GET    | `/admin/dashboard`        | Admin    | Summary stats (order count, revenue, pending payments, low stock) |

#### Health Check

| Method | Endpoint    | Auth   | Description                          |
| ------ | ----------- | ------ | ------------------------------------ |
| GET    | `/health`   | Public | API health check for Railway monitoring |

### Request Validation (Zod)

```typescript
// schemas/order.schema.ts
import { z } from 'zod';

export const createOrderSchema = z.object({
  address_id: z.string().uuid(),
  notes: z.string().max(500).optional(),
});

// schemas/payment.schema.ts
// BCA callback payload validation
export const bcaCallbackSchema = z.object({
  transaction_id: z.string(),
  virtual_account: z.string(),
  customer_number: z.string(),
  payment_amount: z.string(),
  transaction_date: z.string(),
  paid_amount: z.string(),
});
```

### Critical Transaction: Order Creation

```typescript
// services/order.service.ts
// This is WHY we need Express — Supabase PostgREST cannot do multi-step transactions

export const createOrder = async (userId: string, addressId: string, notes?: string) => {
  return await prisma.$transaction(async (tx) => {
    // 1. Get cart items with product details
    const cartItems = await tx.cartItem.findMany({
      where: { user_id: userId },
      include: { product: true },
    });

    if (cartItems.length === 0) throw new AppError(400, 'Cart is empty');

    // 2. Validate stock for ALL items before proceeding
    for (const item of cartItems) {
      if (item.product.stock < item.quantity) {
        throw new AppError(409, `Insufficient stock for ${item.product.name}. Available: ${item.product.stock}`);
      }
      if (!item.product.is_published) {
        throw new AppError(410, `Product ${item.product.name} is no longer available`);
      }
    }

    // 3. Calculate totals
    const subtotal = cartItems.reduce(
      (sum, item) => sum + item.product.price * BigInt(item.quantity), BigInt(0)
    );

    // 4. Create order
    const order = await tx.order.create({
      data: {
        user_id: userId,
        address_id: addressId,
        subtotal: subtotal,
        shipping_cost: BigInt(0), // Admin sets this later or flat rate
        total_amount: subtotal,   // + shipping_cost when applicable
        notes: notes,
        order_items: {
          create: cartItems.map((item) => ({
            product_id: item.product_id,
            quantity: item.quantity,
            unit_price: item.product.price,
            subtotal: item.product.price * BigInt(item.quantity),
          })),
        },
      },
    });

    // 5. Deduct stock for ALL items
    for (const item of cartItems) {
      await tx.product.update({
        where: { id: item.product_id },
        data: { stock: { decrement: item.quantity } },
      });
    }

    // 6. Clear cart
    await tx.cartItem.deleteMany({ where: { user_id: userId } });

    return order;
  });
};
```

> **CTO Note:** This is the single most important piece of code in the entire application. The `$transaction` block ensures that if ANY step fails (stock check, order creation, stock deduction, cart clearing), EVERYTHING rolls back. No orphaned orders, no phantom stock deductions. This is impossible to achieve safely with Supabase PostgREST alone.

---

## 🔐 Security Architecture

> **CTO Note:** Kita memiliki defense in depth — dua lapis keamanan:
> 1. **Express middleware** — validates JWT, checks role, validates request body, enforces business rules
> 2. **Supabase RLS** — safety net di database level. Bahkan jika Express API punya bug, RLS mencegah data leak
>
> Untuk operasi via Express (yang menggunakan service_role key dan bypasses RLS), keamanan 100% bergantung pada middleware kita. Maka setiap endpoint WAJIB memiliki auth middleware.

### Authentication Flow

```
┌──────────────┐     ┌──────────────────┐     ┌─────────────────┐
│ Flutter App   │     │ Supabase Auth     │     │ Express API      │
│              │     │                  │     │ (Railway)        │
└──────┬───────┘     └────────┬─────────┘     └────────┬────────┘
       │                      │                         │
       │  1. Login (email/pw) │                         │
       │─────────────────────>│                         │
       │                      │                         │
       │  2. JWT token        │                         │
       │<─────────────────────│                         │
       │                      │                         │
       │  3. Store in flutter_secure_storage             │
       │                      │                         │
       │  4. API call + Bearer token                    │
       │───────────────────────────────────────────────>│
       │                      │                         │
       │                      │  5. Verify token        │
       │                      │<────────────────────────│
       │                      │                         │
       │                      │  6. User data           │
       │                      │────────────────────────>│
       │                      │                         │
       │  7. Response                                   │
       │<───────────────────────────────────────────────│
```

### Authorization Layers

| Layer | Implementation | Scope |
|-------|---------------|-------|
| Supabase Auth | JWT token issuance & verification | Identity: "who is this user?" |
| Express Middleware (`requireAuth`) | Token verification via Supabase Admin SDK | Authentication: "is this user logged in?" |
| Express Middleware (`requireAdmin`) | Role check against `profiles` table | Authorization: "can this user do this?" |
| Express Business Logic | Ownership checks (e.g., `order.user_id === req.user.id`) | Data access: "does this data belong to this user?" |
| Supabase RLS | Database-level policies | Safety net: prevents data leak even if API code has bugs (for direct SDK access from Flutter) |

### Row-Level Security (RLS) Policies

> **CTO Note:** RLS policies protect data accessed **directly via Supabase SDK from Flutter** (e.g., product catalog reads). Express API uses `service_role` which bypasses RLS — authorization for those paths is handled in Express middleware.

```sql
-- Customers can only see their own orders (via Supabase SDK)
CREATE POLICY "Users view own orders" ON orders
  FOR SELECT USING (auth.uid() = user_id);

-- Anyone can view published products
CREATE POLICY "Public read products" ON products
  FOR SELECT USING (is_published = true);

-- Only admins can modify products (via Supabase SDK — backup policy)
CREATE POLICY "Admins manage products" ON products
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Cart items: users can only access their own
CREATE POLICY "Users manage own cart" ON cart_items
  FOR ALL USING (auth.uid() = user_id);
```

### Data Protection

| Concern | Mitigation |
|---------|-----------|
| SQL Injection | Prisma uses parameterized queries; Supabase SDK uses PostgREST — both safe by default |
| Request Tampering | Zod validation on every Express endpoint — invalid data rejected before hitting DB |
| XSS | Flutter renders UI natively, not in a WebView — XSS not applicable |
| CSRF | JWT-based auth, no cookies — CSRF not applicable |
| File Upload Abuse | Express validates MIME type + file size BEFORE uploading to Supabase Storage |
| Data Exposure | Express ownership checks + Supabase RLS as safety net |
| Secrets Management | `.env` for all keys. Supabase `anon` key safe to expose (RLS protects). `service_role` key ONLY on Express server, NEVER in client. |
| Rate Limiting | `express-rate-limit` on sensitive endpoints (order creation, payment upload) |
| CORS | Only Flutter app domain and admin panel origin allowed |

### Environment Variables (Express)

```env
# .env (NEVER committed to Git)
NODE_ENV=production
PORT=3000

# Supabase
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...  # DANGEROUS — full DB access, server-only
SUPABASE_ANON_KEY=eyJ...          # Safe — used for auth verification

# Database (Supabase PostgreSQL direct connection)
DATABASE_URL=postgresql://postgres:xxxxx@db.xxxx.supabase.co:5432/postgres

# BCA Developer API
BCA_API_KEY=xxxxx                  # BCA Developer API Key
BCA_API_SECRET=xxxxx               # BCA Developer API Secret — NEVER expose to client
BCA_CLIENT_ID=xxxxx                # BCA OAuth Client ID
BCA_CLIENT_SECRET=xxxxx            # BCA OAuth Client Secret
BCA_VA_PREFIX=xxxxx                # Company VA prefix assigned by BCA
BCA_API_BASE_URL=https://sandbox.bca.co.id  # sandbox for dev, https://api.bca.co.id for prod
BCA_CALLBACK_SECRET=xxxxx          # Secret for validating BCA callback signatures

# Email (for sending order notifications to company)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=xxxxx
SMTP_PASS=xxxxx
COMPANY_EMAIL=orders@otomasiku.com  # Internal email that receives order notifications

# App
API_VERSION=v1
ALLOWED_ORIGINS=https://otomasiku.com,https://admin.otomasiku.com
```

---

## 🗄️ Database Schema

> **CTO Note:** All monetary values use `BigInt` storing values in the smallest currency unit (Rupiah, no decimals). This avoids floating-point precision errors. `Rp 19.800.000` is stored as `19800000`. Formatting is handled in the UI layer.

### Prisma Schema

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Profile {
  id           String    @id @db.Uuid  // matches auth.users.id
  full_name    String
  phone        String?
  company_name String?
  role         String    @default("customer")  // "customer" | "admin"
  avatar_url   String?
  created_at   DateTime  @default(now())
  updated_at   DateTime  @updatedAt

  addresses      Address[]
  orders         Order[]
  cart_items     CartItem[]
  payment_proofs PaymentProof[]  @relation("UploadedProofs")
  verified_proofs PaymentProof[] @relation("VerifiedProofs")

  @@map("profiles")
}

model Product {
  id             String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  name           String
  slug           String   @unique
  sku            String?  @unique
  description    String?
  brand          String                        // "Mitsubishi" | "Danfoss"
  series         String?                       // e.g. "FR-A800", "FC300", "MR-J4"
  sub_series     String?                       // e.g. "FR-A840", "FC 302"
  variant        String?                       // e.g. "2.2kW / 400V"
  price          BigInt
  original_price BigInt?
  stock          Int      @default(0)
  category       String                        // "Inverter" | "PLC" | "HMI" | "Servo" | "Module"
  unit           String   @default("pcs")
  min_order      Int      @default(1)
  images         String[]                      // primary image first, then gallery
  is_published   Boolean  @default(true)
  created_at     DateTime @default(now())
  updated_at     DateTime @updatedAt

  order_items OrderItem[]
  cart_items  CartItem[]

  @@map("products")
}

model Address {
  id          String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  user_id     String   @db.Uuid
  label       String
  recipient   String
  phone       String
  street      String
  city        String
  province    String
  postal_code String
  is_default  Boolean  @default(false)
  created_at  DateTime @default(now())

  user   Profile @relation(fields: [user_id], references: [id], onDelete: Cascade)
  orders Order[]

  @@map("addresses")
}

model Order {
  id             String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  order_number   String   @unique
  user_id        String   @db.Uuid
  address_id     String   @db.Uuid
  subtotal       BigInt
  shipping_cost  BigInt   @default(0)
  total_amount   BigInt
  status         String   @default("pending")
  payment_status String   @default("unpaid")
  notes          String?
  admin_notes    String?
  created_at     DateTime @default(now())
  updated_at     DateTime @updatedAt

  user           Profile        @relation(fields: [user_id], references: [id])
  address        Address        @relation(fields: [address_id], references: [id])
  order_items    OrderItem[]
  payment_proofs PaymentProof[]

  @@map("orders")
}

model OrderItem {
  id         String @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  order_id   String @db.Uuid
  product_id String @db.Uuid
  quantity   Int
  unit_price BigInt
  subtotal   BigInt

  order   Order   @relation(fields: [order_id], references: [id], onDelete: Cascade)
  product Product @relation(fields: [product_id], references: [id])

  @@map("order_items")
}

model PaymentProof {
  id            String    @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  order_id      String    @db.Uuid
  user_id       String    @db.Uuid
  image_url     String
  bank_name     String
  account_name  String
  amount        BigInt
  status        String    @default("pending")  // "pending" | "approved" | "rejected"
  reject_reason String?
  uploaded_at   DateTime  @default(now())
  verified_at   DateTime?
  verified_by   String?   @db.Uuid

  order    Order    @relation(fields: [order_id], references: [id])
  user     Profile  @relation("UploadedProofs", fields: [user_id], references: [id])
  verifier Profile? @relation("VerifiedProofs", fields: [verified_by], references: [id])

  @@map("payment_proofs")
}

model CartItem {
  id         String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  user_id    String   @db.Uuid
  product_id String   @db.Uuid
  quantity   Int      @default(1)
  created_at DateTime @default(now())
  updated_at DateTime @updatedAt

  user    Profile @relation(fields: [user_id], references: [id], onDelete: Cascade)
  product Product @relation(fields: [product_id], references: [id], onDelete: Cascade)

  @@unique([user_id, product_id])
  @@map("cart_items")
}
```

### Entity Relationship Diagram

```
profiles (1) ──── (N) addresses
    │                     │
    │ (1)                 │ (1)
    ├──── (N) orders ─────┘
    │           │
    │           ├──── (N) order_items ──── (1) products
    │           │
    │           └──── (N) payment_proofs
    │
    └──── (N) cart_items ──── (1) products
```

### Database Functions

```sql
-- Auto-generate order number (PostgreSQL trigger — runs regardless of whether
-- the INSERT comes from Express/Prisma or Supabase SDK)
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
DECLARE
  today_count INTEGER;
  date_str TEXT;
BEGIN
  date_str := TO_CHAR(NOW(), 'YYYYMMDD');
  SELECT COUNT(*) + 1 INTO today_count
  FROM orders
  WHERE created_at::date = NOW()::date;
  NEW.order_number := 'OMA-' || date_str || '-' || LPAD(today_count::text, 3, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_order_number
  BEFORE INSERT ON orders
  FOR EACH ROW EXECUTE FUNCTION generate_order_number();

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

---

## 📱 Feature Specifications

### Module 1: Authentication

| Feature           | Deskripsi                                       | Handled By   | Priority |
| ----------------- | ----------------------------------------------- | ------------ | -------- |
| Register          | Daftar akun baru dengan email, password, nama lengkap, nama perusahaan | Supabase Auth + Express (create profile) | High |
| Login             | Masuk ke akun dengan email & password           | Supabase Auth SDK | High |
| Logout            | Keluar dari akun, clear secure storage          | Supabase Auth SDK | High |
| Session Persist   | User tetap login setelah tutup app (auto-refresh token) | Supabase Auth SDK | High |
| Forgot Password   | Reset password via email                        | Supabase Auth built-in | Medium |

> **CTO Note — Registration flow:**
> 1. Flutter calls `supabase.auth.signUp()` → creates auth.users record
> 2. Supabase triggers a database function (or Flutter immediately calls Express) to create the `profiles` record
> 3. We use a Supabase database trigger `on auth.users INSERT → create profiles row` as the most reliable approach

### Module 2: Katalog Produk

> **Catalog size:** 125 products (2 brands, 4 categories, 16 series). Full catalog in `DUMMY_PRODUCT_MAPPING_PLAN.md`.

| Feature              | Deskripsi                                              | Handled By   | Priority |
| -------------------- | ------------------------------------------------------ | ------------ | -------- |
| Product Grid/List    | Tampilan katalog produk dengan foto, nama, harga       | Express API  | High     |
| Search               | Cari produk berdasarkan nama, SKU, series (debounced input) | Express API  | High     |
| Filter by Category   | Filter produk berdasarkan kategori (Inverter, PLC, HMI, Servo) | Express API  | High     |
| Filter by Brand      | Filter produk berdasarkan brand (Mitsubishi, Danfoss)  | Express API  | High     |
| Sort                 | Urutkan berdasarkan harga / terbaru                    | Express API  | Medium   |
| Infinite Scroll      | Load lebih banyak produk saat scroll ke bawah          | Express API  | High     |

### Module 3: Detail Produk

| Feature              | Deskripsi                                               | Handled By   | Priority |
| -------------------- | ------------------------------------------------------- | ------------ | -------- |
| Image Gallery        | Carousel foto produk (swipe), tap untuk zoom. Primary image + gallery images per product (mapped in `DUMMY_PRODUCT_MAPPING_PLAN.md`). | Flutter + Supabase Storage CDN | High |
| Product Info         | Nama, SKU, brand, series, variant, harga, harga coret, deskripsi, stok, kategori, satuan, min. order | Express API | High |
| Add to Cart          | Tombol tambah ke keranjang dengan quantity selector      | Express API  | High     |
| Stock Indicator      | Tampilkan status stok (tersedia / sisa sedikit / habis) | Express API  | Medium   |

### Module 4: Keranjang Belanja

| Feature              | Deskripsi                                               | Handled By   | Priority |
| -------------------- | ------------------------------------------------------- | ------------ | -------- |
| Cart List            | Daftar item di keranjang dengan foto, nama, harga, qty  | Express API  | High     |
| Update Quantity      | Ubah jumlah item (+ / - / input manual)                 | Express API  | High     |
| Remove Item          | Hapus item dari keranjang                               | Express API  | High     |
| Cart Summary         | Total harga otomatis terhitung                          | Express API  | High     |
| Cart Badge           | Jumlah item tampil di icon keranjang (app bar)          | Express API  | Medium   |
| Empty Cart State     | Tampilan khusus jika keranjang kosong                   | Flutter UI   | Low      |

### Module 5: Checkout

| Feature               | Deskripsi                                              | Handled By   | Priority |
| --------------------- | ------------------------------------------------------ | ------------ | -------- |
| Select Address        | Pilih dari alamat tersimpan atau tambah alamat baru     | Express API  | High     |
| Order Summary         | Ringkasan pesanan: items, subtotal, ongkir, total      | Express API  | High     |
| Notes                 | Input catatan tambahan untuk pesanan                    | Express API  | Low      |
| Place Order           | Buat pesanan → transactional (validate → create → deduct → clear cart) | Express API (Prisma $transaction) | High |
| Stock Validation      | Validasi stok saat place order (server-side)            | Express API  | High     |

### Module 6: Pembayaran (BCA Virtual Account)

| Feature                  | Deskripsi                                           | Handled By   | Priority |
| ------------------------ | --------------------------------------------------- | ------------ | -------- |
| VA Number Display        | Tampilkan nomor Virtual Account BCA yang di-generate per order | Express API (BCA Developer API) | High |
| Payment Countdown        | Tampilkan batas waktu pembayaran (24 jam) dengan countdown timer | Flutter UI | High |
| Payment Instructions     | Tampilkan panduan transfer via BCA Mobile/ATM/Internet Banking | Flutter UI (hardcoded) | High |
| Auto-Verification        | BCA callback otomatis mengubah status pembayaran setelah customer transfer | Express API (BCA webhook) | High |
| Payment Status Check     | Customer bisa cek status pembayaran secara manual    | Express API  | Medium   |
| Email to Company         | Setelah pembayaran sukses, kirim email ke Otomasiku dengan detail order + alamat pengiriman | Express API (Nodemailer) | High |
| Payment Success Screen   | Tampilan konfirmasi setelah pembayaran berhasil terverifikasi | Flutter UI | High |

### Module 7: Riwayat & Detail Pesanan

| Feature              | Deskripsi                                              | Handled By   | Priority |
| -------------------- | ------------------------------------------------------ | ------------ | -------- |
| Order History List   | Daftar semua pesanan user, diurutkan terbaru           | Express API  | High     |
| Order Detail         | Detail lengkap pesanan: items, alamat, status, payment | Express API  | High     |
| Order Status Tracker | Visual stepper status pesanan (pending → delivered)    | Flutter UI   | High     |
| Filter by Status     | Filter pesanan berdasarkan status                      | Express API  | Medium   |

### Module 8: Profil Pengguna

| Feature              | Deskripsi                                              | Handled By   | Priority |
| -------------------- | ------------------------------------------------------ | ------------ | -------- |
| View Profile         | Tampilkan nama, email, perusahaan, telepon             | Express API  | High     |
| Edit Profile         | Edit nama, telepon, nama perusahaan                    | Express API  | High     |
| Manage Addresses     | CRUD alamat pengiriman                                 | Express API  | High     |
| Change Password      | Ubah password                                          | Supabase Auth SDK | Medium |
| Upload Avatar        | Upload foto profil                                     | Express API → Supabase Storage | Low |

### Module 9: Admin — Dashboard (Flutter Web)

| Feature               | Deskripsi                                             | Handled By   | Priority |
| --------------------- | ----------------------------------------------------- | ------------ | -------- |
| Admin Login           | Login terpisah atau role-based redirect                | Supabase Auth + Express role check | High |
| Dashboard Overview    | Summary: total orders, pending payments, low stock     | Express API  | Medium   |

### Module 10: Admin — Manajemen Produk

| Feature              | Deskripsi                                               | Handled By   | Priority |
| -------------------- | ------------------------------------------------------- | ------------ | -------- |
| Product List         | Tabel semua produk dengan search & filter               | Express API  | High     |
| Add Product          | Form + upload foto                                      | Express API → Supabase Storage | High |
| Edit Product         | Edit semua field produk                                 | Express API  | High |
| Delete Product       | Soft-delete (`is_published = false`)                    | Express API  | High |
| Bulk Stock Update    | Update stok multiple produk sekaligus                   | Express API  | Medium   |

### Module 11: Admin — Manajemen Pesanan

| Feature                  | Deskripsi                                           | Handled By   | Priority |
| ------------------------ | --------------------------------------------------- | ------------ | -------- |
| Order List               | Tabel semua pesanan dengan filter status & tanggal  | Express API  | High     |
| Order Detail             | Detail pesanan lengkap + info customer + alamat     | Express API  | High     |
| Update Order Status      | Ubah status pesanan (confirmed → processing → shipped → delivered) | Express API  | High     |
| View Payment Status      | Lihat status pembayaran BCA VA (auto-verified via callback) | Express API  | High     |
| Admin Notes              | Tambah catatan internal di pesanan                  | Express API  | Medium   |

### Module 12: Admin — Export Data

| Feature          | Deskripsi                                                | Handled By   | Priority |
| ---------------- | -------------------------------------------------------- | ------------ | -------- |
| Export Orders CSV | Download data pesanan dalam format CSV                   | Express API (json2csv library) | Medium |
| Date Range Filter | Filter export berdasarkan range tanggal                 | Express API  | Medium   |

---

## 🔄 User Flows

### Flow 1: Customer — Browse & Purchase

```
Open App
  → [Not logged in?] → Login / Register (Supabase Auth)
  → Home (Katalog Produk) [GET /products via Express]
  → Search / Filter produk
  → Tap produk → Product Detail [GET /products/:id via Express]
  → Set quantity → Add to Cart [POST /cart via Express]
  → (continue shopping or...)
  → Cart (dedicated screen) → Review items [GET /cart via Express]
  → Proceed to Checkout → Select/add address → Review summary
  → Place Order [POST /orders via Express — transactional + BCA VA creation]
  → Payment page → View BCA Virtual Account number + payment deadline
  → Transfer to VA number via BCA Mobile/ATM/Internet Banking (outside our app)
  → BCA sends callback to Express [POST /payments/bca/callback]
  → Express auto-verifies payment → updates order status to "confirmed"
  → Express sends email to company (Otomasiku) with order + shipping address
  → Company manually processes & ships the order
  → Customer tracks order status in app
```

### Flow 2: Admin — Manage Order & Ship

```
Login (admin account, Supabase Auth)
  → Dashboard [GET /admin/dashboard via Express]
  → Receive email notification for new paid orders
  → See orders list → filter by status [GET /admin/orders via Express]
  → Tap order → View detail [GET /admin/orders/:id via Express]
  → Payment already verified automatically (BCA VA callback)
  → Update order status as it progresses: confirmed → processing → shipped → delivered [PATCH /admin/orders/:id/status via Express]
  → (Optional) Export order data [GET /admin/orders/export via Express]
```

### Flow 3: Admin — Manage Products

```
Login (admin account)
  → Products [GET /products via Express with admin flag]
  → Add new product → Fill form + upload photos [POST /products via Express]
  → Edit existing product [PUT /products/:id via Express]
  → Delete product [DELETE /products/:id via Express]
```

---

## 📐 Non-Functional Requirements

| Requirement     | Target                                                                   |
| --------------- | ------------------------------------------------------------------------ |
| Performance     | App cold start < 3 seconds, API response < 500ms (p95)                  |
| Scalability     | Architecture supports 500 → 50,000 users tanpa re-architecture          |
| Security        | RLS on all tables, auth middleware on all Express endpoints, private storage |
| Availability    | Supabase: 99.9% uptime SLA. Railway: auto-restart on crash              |
| Data Integrity  | Prisma `$transaction` untuk order creation & stock deduction             |
| Offline Support | Cached product images, graceful error handling when offline              |
| Accessibility   | Minimum font size 14sp, sufficient color contrast, semantic labels       |
| Localization    | Bahasa Indonesia (primary) via `AppLocalizations`, English (secondary) via i18n ARB files |
| Logging         | All order & payment operations logged with Pino (structured JSON)        |

---

## 📊 Cost Projection

| Service              | Free Tier                          | Estimated at Scale (5K-50K users) |
| -------------------- | ---------------------------------- | --------------------------------- |
| Supabase             | 500MB DB, 1GB storage, 50K auth    | $25/month (Pro plan)              |
| Railway (Express)    | 500 hours/month free               | $5-20/month                       |
| BCA Developer API    | Sandbox free, production per-txn   | ~Rp 3.000-5.000/transaksi        |
| Email (SMTP/SendGrid)| Free tier available                | $0-15/month                       |
| Firebase Crashlytics | Free                               | Free                              |
| Google Play Console  | $25 one-time                       | $25 one-time                      |
| Domain               | Already owned                      | ~$12/year                         |
| **Total Monthly**    | **~$0**                            | **~$40-65/month + BCA per-txn**   |

> **CTO Note:** BCA Developer API charges per-transaction fees for Virtual Account payments. The exact fee depends on the agreement with BCA. For B2B with high-value orders, the per-transaction fee is negligible compared to order values. The elimination of manual payment verification saves significant admin time.

---

## 📅 Milestones & Delivery (Summary)

| Milestone   | Deliverables                                                                | Target Date |
| ----------- | --------------------------------------------------------------------------- | ----------- |
| Milestone 1 | Project setup, design system, Figma final                                   | 4 Mar 2026  |
| Milestone 2 | Flutter UI slicing (10 dummy products dengan images), BCA Sandbox payment flow (mini Express backend), demo di HP | 10 Apr 2026 |
| Milestone 3 | Full backend (Express + Supabase), 125 produk production, Admin dashboard, full QA | 24 Apr 2026 |
| Milestone 4 | Play Store release, monitoring, documentation, handover                     | 8 Mei 2026  |

> **Supporting Plans:**
> - `PLAN_MILESTONE_2.md` — Flutter UI-only milestone execution plan (15 screens, 10 phases, ~7.5 days)
> - `DUMMY_PRODUCT_MAPPING_PLAN.md` — 125-product catalog mapped from OTOMASIKU_EXCEL with real image file paths
>
> Detailed task breakdown available in JIRA: `Project_Otomasiku_Mobile_App_2026 - JIRA_DRAFT.csv`

---

## 📝 Assumptions & Constraints

### Assumptions
1. Klien menyediakan data dan foto produk awal. **Status: ✅ Diterima — 125 produk dari Excel + 1.323 foto produk dari folder `ALL_FOTO_PRODUK_OTOMASIKU`.** Mapping lengkap di `DUMMY_PRODUCT_MAPPING_PLAN.md`.
2. Klien sudah memiliki akun BCA Developer API (atau akan mendaftar) dan rekening BCA perusahaan untuk menerima pembayaran via Virtual Account.
3. Domain otomasiku.com sudah aktif dan DNS dapat dikonfigurasi jika diperlukan.
4. Akun Google Play Console sudah terdaftar dan terbayar ($25).

### Constraints
1. **Platform:** Android only (v1). iOS bisa ditambahkan setelah validasi pasar.
2. **Payment:** BCA Virtual Account only (v1). Bank lain (Mandiri, BNI, BRI) di roadmap v2 berdasarkan kebutuhan customer.
3. **Shipping:** Pengiriman dilakukan manual oleh Otomasiku setelah menerima email notifikasi pembayaran. Belum integrasi API ekspedisi.
4. **Admin Panel:** Flutter Web — shared codebase dengan mobile app, bukan web framework terpisah.
5. **Timeline:** 10 minggu dari kickoff ke Play Store release.
6. **Team Size:** 1 developer, 1 PM. No dedicated QA or designer.
7. **PPN / Volume Discount:** Belum diimplementasikan di v1. Akan dibahas kemudian.

---

## 📎 Appendices

### A. HTML Mockup Feature Inventory

**Location:** `ui-otomasiku-marketplace/` folder — 18 HTML mockup files

**Purpose:** Reference designs for Flutter UI implementation. All Flutter screens must match these mockups with pixel-perfect fidelity.

**Complete feature breakdown by page:**
- See `PLAN_MILESTONE_2.md` § "HTML Mockup Feature Inventory" for detailed feature list per screen

**Screen Inventory:**

| # | Screen | HTML File | Key Features |
|---|--------|-----------|--------------|
| 1 | Splash | `index.html` | Dark gradient, Mitsubishi logo, "Mulai Sekarang" CTA |
| 2 | Login | `login.html` | Glass morphism inputs, "Selamat Datang", social login |
| 3 | Register | — | Follows login.html style, form validation |
| 4 | Home | `home.html` | Product grid (10 items), category chips, hero banner, cart badge |
| 5 | Search Results | `search-results.html` | Vertical list, filter chips, sort dropdown, bottom sheet filters |
| 6 | Product Detail | `product-detail.html` | Image gallery, tiered pricing (B2B), tabs (Specs/Docs/Compatible), RFQ modal |
| 7 | Cart | `cart.html` | Quantity controls, remove items, subtotal, empty state, recommendations |
| 8 | Checkout | `checkout.html` | Address display, PO input, BCA VA payment, summary breakdown |
| 9 | Shipping | `shipping.html` | Address list with radio select, add new address form |
| 10 | Edit Address | `edit-address.html` | Address form fields (name, phone, address, city, postal code) |
| 11 | Payment | `payment.html` | Invoice card, 24h countdown timer, BCA VA number, instructions |
| 12 | Payment Success | `payment-success.html` | Success animation, summary card, status timeline |
| 13 | Payment Methods | `payment-methods.html` | List of saved payment methods, add new method |
| 14 | Order Detail | `order-detail.html` | Status banner, timeline history, item list, shipping info |
| 15 | Orders List | `orders.html` | Status tabs (All/Processing/Completed), order cards |
| 16 | Profile | `profile.html` | User card, stats grid, menu list, logout |
| 17 | Projects | `projects.html` | Project cards with item lists, checkout project, RFQ |
| 18 | Compare | `compare.html` | Side-by-side grid, spec comparison, remove/add products |

**Brand Colors (from HTML mockups):**
- Mitsubishi Red: `#E7192D` (primary action color)
- Background: `#F9FAFB` (scaffold default)
- Danfoss Blue: `#005A8C` (secondary brand color)
- BCA Blue: `#0066AE` (payment method)

---

### B. BCA Virtual Account Configuration (to be confirmed by client)

| Config              | Value          |
| ------------------- | -------------- |
| BCA Company Code    | TBD            |
| VA Prefix           | TBD            |
| BCA Developer API   | Sandbox → Production (after testing) |
| Receiving Account   | TBD (BCA corporate account) |

> Note: BCA VA numbers are auto-generated per order. No manual bank account info needed in the app. The company's BCA corporate account receives all VA payments automatically.

### B. Product Categories & Catalog (confirmed)

Based on real product data from OTOMASIKU_EXCEL (125 products mapped in `DUMMY_PRODUCT_MAPPING_PLAN.md`):

| Category | Brand | Count | Series |
|----------|-------|-------|--------|
| Inverter | Mitsubishi | 33 | FR-A800, FR-D700, FR-D800, FR-CS80, FR-E800, FR-E700 |
| Inverter | Danfoss | 29 | FC 302, FC 360, FC 102, FC 280, FC 051, IC2 |
| PLC | Mitsubishi | 32 | FX3 (FX3G, FX3U), FX5 (FX5U, FX5UC, FX5S), Q Series, iQ-R |
| HMI | Mitsubishi | 11 | GT2000 (GT2103–GT2715), GS Series |
| Servo | Mitsubishi | 20 | MR-J4, MR-J5, MR-JE, Servo Motors (HG-KN, HG-KR) |
| **Total** | | **125** | |

> **Note:** Product images (1,323 files) sourced from `ALL_FOTO_PRODUK_OTOMASIKU` folder. Full image-to-product mapping in `DUMMY_PRODUCT_MAPPING_PLAN.md` § 3.

### C. Order Status State Machine

```
PENDING ──→ CONFIRMED ──→ PROCESSING ──→ SHIPPED ──→ DELIVERED ──→ COMPLETED
   │             │              │             │            │
   └── CANCELLED └── CANCELLED  └── CANCELLED  │            │
                                               └── RETURNED  └── RETURNED
```

### D. Payment Status State Machine

```
UNPAID (VA generated, awaiting transfer)
   │
   ├──→ PAID (BCA callback received & verified)
   │       → Express sends email to company
   │       → Order status auto-updates to CONFIRMED
   │
   └──→ EXPIRED (payment deadline passed, VA expired)
           → Order auto-cancelled, stock restored
```

### E. Express Project Structure

```
otomasiku-api/
├── src/
│   ├── index.ts                  # Entry point
│   ├── app.ts                    # Express app setup (cors, middleware, routes)
│   ├── config/
│   │   ├── env.ts                # Environment variables (typed)
│   │   ├── supabase.ts           # Supabase Admin client singleton
│   │   └── bca.ts                # BCA Developer API config & client
│   ├── middleware/
│   │   ├── auth.ts               # requireAuth, requireAdmin
│   │   ├── validate.ts           # Zod validation middleware
│   │   ├── error-handler.ts      # Centralized error handling
│   │   ├── rate-limit.ts         # Rate limiting config
│   │   └── bca-signature.ts      # BCA callback signature verification middleware
│   ├── routes/
│   │   ├── product.routes.ts
│   │   ├── cart.routes.ts
│   │   ├── order.routes.ts
│   │   ├── payment.routes.ts     # BCA VA callback webhook
│   │   ├── address.routes.ts
│   │   ├── profile.routes.ts
│   │   └── admin.routes.ts
│   ├── services/
│   │   ├── product.service.ts    # Business logic
│   │   ├── cart.service.ts
│   │   ├── order.service.ts      # Critical: transactional order creation + BCA VA generation
│   │   ├── payment.service.ts    # BCA VA creation, callback handling, payment verification
│   │   ├── email.service.ts      # Send order notification emails to company
│   │   └── export.service.ts     # CSV export
│   ├── schemas/
│   │   ├── product.schema.ts     # Zod validation schemas
│   │   ├── order.schema.ts
│   │   ├── cart.schema.ts
│   │   ├── address.schema.ts
│   │   └── payment.schema.ts     # BCA callback payload schema
│   ├── utils/
│   │   ├── logger.ts             # Pino logger setup
│   │   ├── errors.ts             # Custom AppError class
│   │   └── storage.ts            # Supabase Storage upload helpers
│   └── types/
│       └── express.d.ts          # Extend Express Request with user
├── prisma/
│   └── schema.prisma
├── .env
├── .env.example
├── tsconfig.json
├── package.json
└── README.md
```
