# 🏗️ Architecture Document
# Otomasiku Marketplace Mobile App

---

## Architecture Overview

Otomasiku menggunakan arsitektur **hybrid**: **Supabase** sebagai managed infrastructure layer (auth, database, storage) dan **Express.js (TypeScript)** sebagai custom API layer untuk business logic.

```
Flutter App (Android + Admin Web)
  ├── Supabase SDK ──→ Supabase Auth / Storage / simple reads (with RLS)
  │
  └── Dio/Retrofit ──→ Express API (Railway)
                         ├── Supabase Admin SDK (verify JWT, manage auth)
                         └── Prisma ORM ──→ Supabase PostgreSQL (same DB, bypasses RLS)
```

### Responsibility Split

| Concern                                  | Handled By            | Reasoning                                                      |
| ---------------------------------------- | --------------------- | -------------------------------------------------------------- |
| Authentication & session                 | Supabase Auth         | Battle-tested, JWT auto-refresh, RLS integration               |
| Database & RLS policies                  | Supabase PostgreSQL   | Row-level security enforced at DB level — safety net            |
| File storage & CDN                       | Supabase Storage      | Managed, with access policies, built-in CDN                    |
| Business logic (orders, payments, stock) | Express.js API        | Needs transaction control, custom validation, multi-step flows |
| Admin operations (CRUD, export)          | Express.js API        | Needs role verification, audit logging, data transformation    |
| Realtime (future v2)                     | Supabase Realtime     | WebSocket order status updates without custom infra            |

### Dual API Client Pattern

Flutter app communicates with **two backends**:
1. **Supabase SDK** — for auth (login/register/logout), storage (upload foto), and read-only queries
2. **Dio → Express API** — for all write operations and business logic

Supabase Auth JWT token is used for **both** connections. Express verifies the same token via Supabase Admin SDK.

---

## Tech Stack

### Frontend (Mobile & Admin)

| Layer                  | Technology                   | Justification                                                          |
| ---------------------- | ---------------------------- | ---------------------------------------------------------------------- |
| Framework              | Flutter (Dart)               | Single codebase for Android app + Admin web panel                      |
| State Management       | Riverpod                     | Type-safe, testable, scalable                                          |
| Navigation             | GoRouter                     | Declarative routing with deep linking & auth guards                    |
| API Client (Supabase)  | Supabase Flutter SDK         | Direct integration for auth, storage, realtime                         |
| API Client (Express)   | Dio + Retrofit               | Type-safe HTTP client for custom API calls                             |
| Secure Storage         | flutter_secure_storage       | Token stored in Android Keystore (hardware-encrypted)                  |
| Image Caching          | cached_network_image         | Offline-capable image loading from Supabase Storage CDN                |
| Forms                  | flutter_form_builder         | Reusable form widgets for checkout & admin input                       |
| Crash Reporting        | firebase_crashlytics         | Real-time crash + ANR reporting in production                          |
| Performance Monitoring | firebase_performance         | Screen load time, API response time, network latency tracking          |
| Offline Detection      | connectivity_plus            | Detect no-network state and show offline banner before API calls       |
| Internasionalisasi     | flutter_localizations (SDK) + intl | ARB-based i18n — Indonesian default, English supported. Zero runtime cost, compile-time safety. |

### Backend — Express.js (Custom API)

| Layer            | Technology                         | Justification                                                          |
| ---------------- | ---------------------------------- | ---------------------------------------------------------------------- |
| Runtime          | Node.js 20 LTS                    | Stable, long-term support, mature ecosystem                            |
| Framework        | Express.js                         | Minimal, well-documented, battle-tested for ~20 endpoints              |
| Language         | TypeScript (strict mode)           | Catches bugs at compile time — critical for payment amounts            |
| ORM              | Prisma                             | Type-safe queries, migration tracking, SQL injection protection        |
| Validation       | Zod                                | Runtime request validation with TypeScript type inference               |
| Auth Middleware   | Supabase Admin SDK                | Verify JWT tokens issued by Supabase Auth                              |
| File Upload      | Multer + Supabase Storage SDK      | Multer parses multipart, then uploads to Supabase Storage server-side  |
| Logging          | Pino                               | Structured JSON logging — critical for debugging payment issues        |
| Error Handling   | Custom middleware                   | Centralized error handler with standardized response shape             |
| Rate Limiting    | express-rate-limit                  | Prevent brute-force and abuse on sensitive endpoints                   |
| CORS             | cors                                | Configured for Flutter app and admin web panel origins only            |
| Environment      | dotenv                              | Environment-specific config (dev/staging/prod)                        |
| Input Sanitization | sanitize-html                    | Strip HTML from all user-generated string inputs before persisting     |
| Deployment       | Railway                             | One-click deploy from Git, auto-HTTPS, auto-scaling                   |

### Backend — Supabase (Managed Infrastructure)

| Layer        | Technology                        | Justification                                                          |
| ------------ | --------------------------------- | ---------------------------------------------------------------------- |
| Database     | PostgreSQL (via Supabase)         | ACID-compliant relational DB — critical for transactional data         |
| Auth         | Supabase Auth                     | Email/password auth, JWT auto-refresh, RLS integration                 |
| Storage      | Supabase Storage                  | Image storage with built-in CDN, access policies                      |
| Deployment   | Supabase Cloud (managed)          | Zero infra management, auto-scaling, built-in backups, SOC2 compliant |

### Payment

| Layer   | Technology                        | Justification                                                          |
| ------- | --------------------------------- | ---------------------------------------------------------------------- |
| Payment | BCA Virtual Account (BCA Developer API) | Auto VA generation and real-time callback. Customer pays to generated VA number via BCA Mobile/ATM. BCA sends callback to verify payment automatically. |
| Email   | Nodemailer (or SendGrid)         | After payment verified via BCA callback, Express sends email notification to company (Otomasiku) with order details + shipping address. |

### Monitoring & Observability

| Layer               | Technology              | Justification                                                         |
| ------------------- | ----------------------- | --------------------------------------------------------------------- |
| Crash Reporting     | Firebase Crashlytics    | Real-time crash reporting in production, ANR tracking                 |
| Performance (Mobile)| Firebase Performance    | Screen load time, API response time, HTTP request latency             |
| API Logging         | Pino (Express)          | Structured JSON logs for every request — includes correlationId       |
| Request Tracing     | Correlation ID (custom) | Every request gets a UUID; returned in `x-correlation-id` header      |
| Uptime Monitoring   | Railway built-in        | Auto-restart on crash, health check via `/health` and `/health/ready` |
| Slow Query Logging  | Pino (Express)          | Log any request with response time > 1000ms as `warn` level           |

> **Backup Strategy:**
> - Supabase Cloud enables **Point-in-Time Recovery (PITR)** — enable this in the Supabase dashboard immediately after project creation
> - Retention: minimum 7 days of PITR
> - Monthly: export a full database dump and store in a separate cloud storage bucket
> - Restore procedure must be documented and tested at least once before production launch
> - Responsibility: CTO must verify backup is active before Milestone 4 (Play Store release)

---

## Database Schema

> All monetary values use `BigInt` storing values in the smallest currency unit (Rupiah, no decimals). `Rp 19.800.000` is stored as `19800000`. Formatting is handled in the UI layer.
>
> **Why BigInt and not Int for monetary fields:** JavaScript's `Number` type is only safe for integers up to `2^53 - 1`. While current order amounts are well within range, using `BigInt` future-proofs against large B2B invoice aggregations and is the industry standard for financial data.

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
  id              String    @id @db.Uuid  // matches auth.users.id
  full_name       String
  phone           String?
  company_name    String?
  role            String    @default("customer")  // "customer" | "admin"
  avatar_url      String?
  created_at      DateTime  @default(now())
  updated_at      DateTime  @updatedAt

  addresses            Address[]
  orders               Order[]
  cart_items           CartItem[]
  payment_proofs       PaymentProof[]  @relation("UploadedProofs")
  verified_proofs      PaymentProof[]  @relation("VerifiedProofs")
  order_status_changes OrderStatusHistory[]

  @@map("profiles")
}

model Product {
  id             String    @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  name           String
  slug           String    @unique
  sku            String?   @unique
  description_id  String?                       // Deskripsi produk — Bahasa Indonesia
  description_en  String?                       // Product description — English
  // Note: do NOT use a single `description` field — bilingual content needs separate columns
  //       so the API can return the correct language based on Accept-Language header
  brand          String                        // "Mitsubishi" | "Danfoss"
  series         String?                       // e.g. "FR-A800", "FC300", "MR-J4"
  sub_series     String?                       // e.g. "FR-A840", "FC 302"
  variant        String?                       // e.g. "2.2kW / 400V"
  price          BigInt
  original_price BigInt?
  stock          Int       @default(0)
  version        Int       @default(0)         // Optimistic locking — increment on every stock update
  category       String                        // "Inverter" | "PLC" | "HMI" | "Servo" | "Module"
  unit           String    @default("pcs")
  min_order      Int       @default(1)
  images         String[]                      // primary image first, then gallery
  is_published   Boolean   @default(true)
  deleted_at     DateTime?                     // Soft delete — NEVER hard delete products referenced by orders
  created_at     DateTime  @default(now())
  updated_at     DateTime  @updatedAt

  order_items OrderItem[]
  cart_items  CartItem[]

  // Indexes for common query patterns
  @@index([category])                          // filter by category
  @@index([brand])                             // filter by brand
  @@index([category, brand])                   // combined category + brand filter
  @@index([is_published, deleted_at])          // active product listing
  @@map("products")
}

model Address {
  id          String    @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  user_id     String    @db.Uuid
  label       String
  recipient   String
  phone       String
  street      String
  city        String
  province    String
  postal_code String
  is_default  Boolean   @default(false)
  deleted_at  DateTime?                        // Soft delete — preserve for historical order records
  created_at  DateTime  @default(now())

  user   Profile @relation(fields: [user_id], references: [id], onDelete: Cascade)
  orders Order[]

  @@index([user_id, deleted_at])              // user's active addresses
  @@map("addresses")
}

model Order {
  id             String    @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  order_number   String    @unique
  user_id        String    @db.Uuid
  address_id     String    @db.Uuid
  subtotal       BigInt
  shipping_cost  BigInt    @default(0)
  total_amount   BigInt
  status         String    @default("pending")   // pending | confirmed | processing | shipped | delivered | completed | cancelled | returned
  payment_status String    @default("unpaid")    // unpaid | paid | expired
  notes          String?
  admin_notes    String?
  created_at     DateTime  @default(now())
  updated_at     DateTime  @updatedAt

  user               Profile              @relation(fields: [user_id], references: [id])
  address            Address              @relation(fields: [address_id], references: [id])
  order_items        OrderItem[]
  payment_proofs     PaymentProof[]
  status_history     OrderStatusHistory[]

  // Indexes for common query patterns
  @@index([user_id, created_at])               // "pesanan saya" sorted by date
  @@index([payment_status])                    // cron job: find UNPAID orders nearing expiry
  @@index([status])                            // admin order management filter
  @@map("orders")
}

model OrderStatusHistory {
  id          String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  order_id    String   @db.Uuid
  from_status String
  to_status   String
  changed_by  String   @db.Uuid              // user_id of admin, or system user ID for automated changes
  note        String?                        // optional reason for status change
  created_at  DateTime @default(now())

  order  Order   @relation(fields: [order_id], references: [id], onDelete: Cascade)
  actor  Profile @relation(fields: [changed_by], references: [id])

  @@index([order_id, created_at])
  @@map("order_status_history")
}

model OrderItem {
  id         String @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  order_id   String @db.Uuid
  product_id String @db.Uuid
  quantity   Int
  unit_price BigInt                           // Price at time of purchase — never changes even if product price changes
  subtotal   BigInt

  order   Order   @relation(fields: [order_id], references: [id], onDelete: Cascade)
  product Product @relation(fields: [product_id], references: [id])
  // Note: Product uses soft delete — this relation will always resolve even after product is "deleted"

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

// Idempotency table — prevents duplicate orders from client retries
model IdempotencyKey {
  key           String   @id                  // X-Idempotency-Key header value (UUID from client)
  user_id       String   @db.Uuid
  endpoint      String                        // e.g. "POST /api/orders"
  response_code Int                           // HTTP status code of original response
  response_body Json                          // Cached response body
  created_at    DateTime @default(now())
  expires_at    DateTime                      // Typically: created_at + 24 hours

  @@index([user_id])
  @@index([expires_at])                       // for cleanup cron job
  @@map("idempotency_keys")
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
    │           ├──── (N) payment_proofs
    │           └──── (N) order_status_history ──── (1) profiles [admin/system]
    │
    └──── (N) cart_items ──── (1) products

idempotency_keys (standalone — no FK, keyed by client UUID)
```

### Database Functions

```sql
-- Auto-generate order number
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

-- Full-text search index for product search (name + SKU)
CREATE INDEX products_fts_idx ON products
  USING GIN (to_tsvector('english', name || ' ' || COALESCE(sku, '')));
```

---

## Express API Design

### Base URL

| Environment | URL                                                            |
| ----------- | -------------------------------------------------------------- |
| Development | `http://localhost:3000/api`                                 |
| Staging     | `https://otomasiku-api-staging.up.railway.app/api`          |
| Production  | `https://api.otomasiku.com/api` (custom domain via Railway) |

> **All routes MUST use the `/api/` prefix.** Example: `GET /api/products`, `POST /api/orders`.

### Standard Error Response Format

All error responses from Express MUST follow this structure. Never construct ad-hoc error shapes in routes.

```typescript
// utils/errors.ts
export class AppError extends Error {
  constructor(
    public readonly statusCode: number,
    public readonly code: string,        // machine-readable: INSUFFICIENT_STOCK, UNAUTHORIZED, etc.
    public readonly message: string | null = null,  // DEPRECATED — do not send to client. Flutter translates code.
    public readonly details?: Record<string, unknown>
  ) {
    super(message ?? code);
  }
}

// Error response shape (from error-handler.ts middleware):
// NOTE: 'message' field is intentionally omitted from the response.
// Flutter receives only 'code' and translates it via AppLocalizations.
{
  "error": {
    "code": "INSUFFICIENT_STOCK",
    "details": { "available": 2, "requested": 5 },
    "correlationId": "abc-123-def-456"
  }
}
```

### Health Check Endpoints

```typescript
// routes/health.routes.ts — Public, no auth required

// Liveness — Railway calls this to decide whether to restart the container
// MUST respond immediately without DB check
GET /health
→ 200 { "status": "ok", "timestamp": "2026-03-01T10:00:00Z" }

// Readiness — checks DB connectivity
// Railway uses this to decide whether to route traffic to this instance
GET /health/ready
→ 200 { "status": "ok", "db": "connected", "uptime": 3600 }
→ 503 { "status": "error", "db": "disconnected" }  // if DB unreachable
```

### Correlation ID Middleware

```typescript
// middleware/correlation.ts
import crypto from 'crypto';

export const correlationMiddleware = (req: Request, res: Response, next: NextFunction) => {
  req.correlationId = (req.headers['x-correlation-id'] as string) || crypto.randomUUID();
  res.setHeader('x-correlation-id', req.correlationId);
  next();
};

// Apply FIRST in app.ts, before all other middleware
app.use(correlationMiddleware);
```

### Authentication Middleware

```typescript
// middleware/auth.ts
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export const requireAuth = async (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({
    error: { code: 'MISSING_TOKEN', message: 'Token autentikasi diperlukan', correlationId: req.correlationId }
  });

  const { data: { user }, error } = await supabase.auth.getUser(token);
  if (error || !user) return res.status(401).json({
    error: { code: 'INVALID_TOKEN', message: 'Token tidak valid atau sudah kadaluarsa', correlationId: req.correlationId }
  });

  req.user = user;
  next();
};

export const requireAdmin = async (req: Request, res: Response, next: NextFunction) => {
  const profile = await prisma.profile.findUnique({ where: { id: req.user.id } });
  if (profile?.role !== 'admin') return res.status(403).json({
    error: { code: 'FORBIDDEN', message: 'Akses admin diperlukan', correlationId: req.correlationId }
  });
  next();
};
```

### Idempotency Middleware

```typescript
// middleware/idempotency.ts
// Apply to: POST /api/orders
// Client must send: X-Idempotency-Key: <uuid> header
// If same key arrives again within 24h → return cached response

export const idempotency = () => async (req: Request, res: Response, next: NextFunction) => {
  const key = req.headers['x-idempotency-key'] as string;
  if (!key) return res.status(400).json({
    error: { code: 'MISSING_IDEMPOTENCY_KEY', message: 'X-Idempotency-Key header diperlukan', correlationId: req.correlationId }
  });

  const existing = await prisma.idempotencyKey.findFirst({
    where: { key, user_id: req.user.id, expires_at: { gt: new Date() } }
  });

  if (existing) {
    // Return cached response — no duplicate processing
    return res.status(existing.response_code).json(existing.response_body);
  }

  // Intercept response to cache it
  const originalJson = res.json.bind(res);
  res.json = (body) => {
    prisma.idempotencyKey.create({
      data: {
        key,
        user_id: req.user.id,
        endpoint: `${req.method} ${req.path}`,
        response_code: res.statusCode,
        response_body: body,
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000),
      }
    }).catch(err => logger.warn({ err }, 'Failed to cache idempotency key'));
    return originalJson(body);
  };

  next();
};
```

### API Endpoints

#### Health Check (Public)

| Method | Endpoint          | Auth   | Description                                     |
| ------ | ----------------- | ------ | ----------------------------------------------- |
| GET    | `/health`         | Public | Liveness check — immediate 200, no DB query      |
| GET    | `/health/ready`   | Public | Readiness check — verifies DB connectivity       |

#### Products (Public Read, Admin Write)

| Method | Endpoint                  | Auth     | Description                          |
| ------ | ------------------------- | -------- | ------------------------------------ |
| GET    | `/products`               | Public   | List products (paginated, filterable) |
| GET    | `/products/:id`           | Public   | Get product detail by ID              |
| POST   | `/products`               | Admin    | Create new product                    |
| PUT    | `/products/:id`           | Admin    | Update product                        |
| DELETE | `/products/:id`           | Admin    | Soft-delete product (sets deleted_at) |
| PATCH  | `/products/:id/stock`     | Admin    | Update stock only (with optimistic lock) |
| POST   | `/products/:id/images`    | Admin    | Upload product images                 |

**Query parameters for `GET /products`:**
```
?search=valve&category=Inverter&brand=Mitsubishi&sort=price_asc&page=1&limit=20
```
> Default limit: 20. Max limit: 100. Always paginate — never return unbounded lists.

#### Cart (Authenticated)

| Method | Endpoint                  | Auth     | Description                          |
| ------ | ------------------------- | -------- | ------------------------------------ |
| GET    | `/cart`                   | Customer | Get user's cart items                 |
| POST   | `/cart`                   | Customer | Add item to cart                      |
| PATCH  | `/cart/:id`               | Customer | Update quantity                       |
| DELETE | `/cart/:id`               | Customer | Remove item from cart                 |
| DELETE | `/cart`                   | Customer | Clear entire cart                     |

#### Orders (Authenticated)

| Method | Endpoint                             | Auth     | Description                                         |
| ------ | ------------------------------------ | -------- | --------------------------------------------------- |
| POST   | `/orders`                            | Customer | Create order (requires X-Idempotency-Key header)    |
| GET    | `/orders`                            | Customer | List user's orders (paginated)                      |
| GET    | `/orders/:id`                        | Customer | Get order detail (ownership verified)               |
| GET    | `/admin/orders`                      | Admin    | List all orders (filterable, paginated)             |
| GET    | `/admin/orders/:id`                  | Admin    | Get any order detail                                |
| PATCH  | `/admin/orders/:id/status`           | Admin    | Update order status (logs to order_status_history)  |
| GET    | `/admin/orders/export`               | Admin    | Export orders to CSV                                |

#### Payment — BCA Virtual Account (Webhook)

| Method | Endpoint                             | Auth          | Description                          |
| ------ | ------------------------------------ | ------------- | ------------------------------------ |
| POST   | `/payments/bca/callback`             | BCA Signature | BCA payment callback webhook — validates HMAC signature, deduplicates, updates status, sends email |
| GET    | `/orders/:id/payment-status`         | Customer      | Check payment status for an order     |

#### Addresses (Authenticated)

| Method | Endpoint              | Auth     | Description                          |
| ------ | --------------------- | -------- | ------------------------------------ |
| GET    | `/addresses`          | Customer | List user's active addresses          |
| POST   | `/addresses`          | Customer | Add new address                       |
| PUT    | `/addresses/:id`      | Customer | Update address                        |
| DELETE | `/addresses/:id`      | Customer | Soft-delete address (sets deleted_at) |

#### Profile (Authenticated)

| Method | Endpoint              | Auth     | Description                          |
| ------ | --------------------- | -------- | ------------------------------------ |
| GET    | `/profile`            | Customer | Get own profile                       |
| PATCH  | `/profile`            | Customer | Update own profile                    |

#### Admin Dashboard (Admin only)

| Method | Endpoint                  | Auth     | Description                          |
| ------ | ------------------------- | -------- | ------------------------------------ |
| GET    | `/admin/dashboard`        | Admin    | Summary stats                        |

### Request Validation (Zod)

```typescript
// schemas/order.schema.ts
import { z } from 'zod';

export const createOrderSchema = z.object({
  address_id: z.string().uuid(),
  notes: z.string().max(500).optional(),
});

// schemas/payment.schema.ts
export const bcaCallbackSchema = z.object({
  transaction_id: z.string(),
  virtual_account: z.string(),
  customer_number: z.string(),
  payment_amount: z.string(),
  transaction_date: z.string(),
  paid_amount: z.string(),
});
```

### Critical Transaction: Order Creation (with Optimistic Locking)

```typescript
// services/order.service.ts
export const createOrder = async (userId: string, addressId: string, notes?: string) => {
  return await prisma.$transaction(async (tx) => {
    // 1. Get cart items with product details
    const cartItems = await tx.cartItem.findMany({
      where: { user_id: userId },
      include: { product: true },
    });

    if (cartItems.length === 0) throw new AppError(400, 'EMPTY_CART', 'Keranjang belanja kosong');

    // 2. Validate all items before any mutation
    for (const item of cartItems) {
      if (!item.product.is_published || item.product.deleted_at !== null) {
        throw new AppError(410, 'PRODUCT_UNAVAILABLE', `Produk ${item.product.name} tidak tersedia lagi`);
      }
      if (item.product.stock < item.quantity) {
        throw new AppError(409, 'INSUFFICIENT_STOCK', `Stok tidak mencukupi untuk ${item.product.name}`, {
          available: item.product.stock,
          requested: item.quantity,
        });
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
        subtotal,
        shipping_cost: BigInt(0),
        total_amount: subtotal,
        notes,
        order_items: {
          create: cartItems.map((item) => ({
            product_id: item.product_id,
            quantity: item.quantity,
            unit_price: item.product.price,       // snapshot price at time of purchase
            subtotal: item.product.price * BigInt(item.quantity),
          })),
        },
      },
    });

    // 5. Deduct stock with OPTIMISTIC LOCKING — atomic check-and-decrement
    for (const item of cartItems) {
      const updated = await tx.product.updateMany({
        where: {
          id: item.product_id,
          stock: { gte: item.quantity },     // condition checked at DB level
          version: item.product.version,     // reject if concurrent update happened
          deleted_at: null,
        },
        data: {
          stock: { decrement: item.quantity },
          version: { increment: 1 },
        },
      });

      if (updated.count === 0) {
        // Concurrent update detected — transaction will rollback automatically
        throw new AppError(
          409,
          'STOCK_CONFLICT',
          `Stok untuk ${item.product.name} habis atau diperbarui bersamaan. Silakan coba lagi.`
        );
      }
    }

    // 6. Clear cart
    await tx.cartItem.deleteMany({ where: { user_id: userId } });

    // 7. Log initial order status history
    await tx.orderStatusHistory.create({
      data: {
        order_id: order.id,
        from_status: '',
        to_status: 'pending',
        changed_by: userId,
        note: 'Order dibuat',
      },
    });

    return order;
  });
};
```

> **This is the single most important piece of code in the entire application.** The `$transaction` block ensures that if ANY step fails, EVERYTHING rolls back. The optimistic locking on step 5 ensures two concurrent buyers cannot both purchase the last unit.

---

## Security Architecture

### Defense in Depth — Two Layers

1. **Express middleware** — validates JWT, checks role, validates request body, enforces business rules
2. **Supabase RLS** — safety net at database level. Even if Express API has a bug, RLS prevents data leak

For operations via Express (using `service_role` key which bypasses RLS), security 100% depends on our middleware. Every endpoint MUST have auth middleware.

### Authentication Flow

```
┌──────────────┐     ┌──────────────────┐     ┌─────────────────┐
│ Flutter App   │     │ Supabase Auth     │     │ Express API      │
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
       │  4. API call + Bearer token + X-Idempotency-Key│
       │───────────────────────────────────────────────>│
       │                      │                         │
       │                      │  5. Verify token        │
       │                      │<────────────────────────│
       │                      │                         │
       │                      │  6. User data           │
       │                      │────────────────────────>│
       │                      │                         │
       │  7. Response + x-correlation-id header         │
       │<───────────────────────────────────────────────│
```

### Authorization Layers

| Layer                                     | Implementation                            | Scope                                            |
| ----------------------------------------- | ----------------------------------------- | ------------------------------------------------ |
| Supabase Auth                             | JWT token issuance & verification         | Identity: "who is this user?"                    |
| Express Middleware (`requireAuth`)        | Token verification via Supabase Admin SDK | Authentication: "is this user logged in?"        |
| Express Middleware (`requireAdmin`)       | Role check against `profiles` table       | Authorization: "can this user do this?"          |
| Express Business Logic                    | Ownership checks                          | Data access: "does this data belong to this user?"|
| Supabase RLS                             | Database-level policies                   | Safety net: prevents data leak on direct SDK access|

### Row-Level Security (RLS) Policies

> RLS protects data accessed **directly via Supabase SDK from Flutter**. Express API uses `service_role` which bypasses RLS — authorization for those paths is handled in Express middleware.

```sql
CREATE POLICY "Users view own orders" ON orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Public read published products" ON products
  FOR SELECT USING (is_published = true AND deleted_at IS NULL);

CREATE POLICY "Admins manage products" ON products
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Users manage own cart" ON cart_items
  FOR ALL USING (auth.uid() = user_id);
```

### Data Protection

| Concern            | Mitigation                                                                         |
| ------------------ | ---------------------------------------------------------------------------------- |
| SQL Injection      | Prisma parameterized queries; Supabase PostgREST — both safe by default            |
| Request Tampering  | Zod validation on every Express endpoint                                           |
| XSS                | Flutter renders natively, not WebView — not applicable for mobile                  |
| CSRF               | JWT-based auth, no cookies — not applicable                                        |
| File Upload Abuse  | Express validates MIME type + file size BEFORE uploading to Storage                 |
| Data Exposure      | Express ownership checks + Supabase RLS as safety net                              |
| Secrets Management | `.env` for all keys. `service_role` ONLY on Express server, NEVER in client        |
| Rate Limiting      | `express-rate-limit` on sensitive endpoints                                        |
| CORS               | Only Flutter app domain and admin panel origin allowed                              |
| Duplicate Orders   | Idempotency key enforcement on order creation endpoint                             |
| Race Conditions    | Optimistic locking on stock deduction — atomic check-and-decrement at DB level     |
| Historical Data    | Soft delete on Product and Address — order history always resolvable               |
| Log Privacy        | PII never logged — only identifiers (userId, orderId, correlationId)               |
| Input Injection    | sanitize-html strips HTML tags from all user-generated string inputs               |

### Payment Flow (BCA Virtual Account)

1. Customer places order → Express calls **BCA Developer API** to create a Virtual Account number for the order amount
2. Express stores the VA number + expiry time in the `orders` table, returns VA details to Flutter
3. Flutter displays: VA number, payment amount, countdown timer (24h deadline), transfer instructions
4. Customer transfers to the VA number via BCA Mobile/ATM/Internet Banking (outside our app)
5. BCA sends **HTTP POST callback** to `POST /api/payments/bca/callback` on our Express API
6. Express validates the `X-BCA-Signature` header (HMAC-SHA256 with BCA API secret), checks transaction ID not already processed
7. Express updates `payment_status` to `paid` + `order_status` to `confirmed` + inserts `OrderStatusHistory` in a single **Prisma transaction**
8. Express sends **email to company** (Otomasiku) via Nodemailer with full order details + customer shipping address
9. Company manually prepares and ships the order to the customer's address
10. Admin updates order status as it progresses (each change logged to `order_status_history`)

> **Security:** The BCA callback endpoint does NOT use `requireAuth`. Instead, it validates the BCA HMAC signature header AND checks for duplicate transaction IDs (replay attack prevention). Rate limiting is applied.

### Environment Variables (Express)

```env
# .env (NEVER committed to Git — see .env.example for template)
NODE_ENV=production
PORT=3000

# Supabase
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...  # DANGEROUS — full DB access, server-only
SUPABASE_ANON_KEY=eyJ...          # Safe — used for auth verification

# Database (Supabase PostgreSQL direct connection + connection pooling)
DATABASE_URL=postgresql://postgres:xxxxx@db.xxxx.supabase.co:5432/postgres?connection_limit=10&pool_timeout=20
# ↑ connection_limit: max connections per Railway instance
# ↑ pool_timeout: seconds to wait for a connection before failing

# BCA Developer API
BCA_API_KEY=xxxxx
BCA_API_SECRET=xxxxx              # NEVER expose to client
BCA_CLIENT_ID=xxxxx
BCA_CLIENT_SECRET=xxxxx
BCA_VA_PREFIX=xxxxx
BCA_API_BASE_URL=https://sandbox.bca.co.id  # sandbox for dev, https://api.bca.co.id for prod
BCA_CALLBACK_SECRET=xxxxx         # For HMAC-SHA256 BCA callback signature validation

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=xxxxx
SMTP_PASS=xxxxx
COMPANY_EMAIL=orders@otomasiku.com

# App

ALLOWED_ORIGINS=https://otomasiku.com,https://admin.otomasiku.com

# System user ID for automated status changes (e.g. payment expiry cron)
SYSTEM_USER_ID=00000000-0000-0000-0000-000000000000
```

> **Connection Pooling Note:** The `connection_limit` and `pool_timeout` parameters in `DATABASE_URL` are critical for Railway deployments. Without them, each Express instance may open too many connections to Supabase PostgreSQL, causing "too many connections" errors under load. If traffic grows significantly, consider adding **PgBouncer** (available as a Supabase add-on) as a dedicated connection pooler in front of PostgreSQL.

---

## Internationalization (i18n) Architecture

### Overview

Otomasiku supports **two locales**: Indonesian (`id`) as default, English (`en`) as secondary. The approach uses Flutter's official ARB-based i18n system — zero extra dependencies, compile-time key safety, and hot-reload support.

### Supported Locales

| Code | Language | Default? |
|------|----------|----------|
| `id` | Bahasa Indonesia | ✅ Yes |
| `en` | English | No |

### File Structure

```
lib/
└── l10n/
    ├── app_id.arb    ← Primary (Indonesian) — template file
    └── app_en.arb    ← English translation
```

`l10n.yaml` (root of Flutter project):
```yaml
arb-dir: lib/l10n
template-arb-file: app_id.arb
output-localization-file: app_localizations.dart
```

### ARB File Convention

```json
// app_id.arb — always define here first, then mirror to app_en.arb
{
  "@@locale": "id",

  // Screen titles
  "homeTitle": "Katalog Produk",
  "cartTitle": "Keranjang Belanja",
  "checkoutTitle": "Checkout",
  "profileTitle": "Profil Saya",

  // Actions
  "addToCart": "Tambah ke Keranjang",
  "buyNow": "Beli Sekarang",
  "continueToCheckout": "Lanjut ke Checkout",
  "saveChanges": "Simpan Perubahan",
  "logout": "Keluar",

  // Stock badges
  "stockReady": "Ready Stock",
  "stockLow": "Sisa {count} Unit",
  "@stockLow": {
    "placeholders": { "count": { "type": "int" } }
  },
  "stockEmpty": "Habis",

  // Error messages — keyed by backend error.code
  "errorGeneric": "Terjadi kesalahan. Silakan coba lagi.",
  "errorInsufficientStock": "Stok tidak mencukupi. Tersedia: {available} unit.",
  "@errorInsufficientStock": {
    "placeholders": { "available": { "type": "int" } }
  },
  "errorProductUnavailable": "Produk ini sudah tidak tersedia.",
  "errorEmptyCart": "Keranjang belanja kosong.",
  "errorStockConflict": "Stok habis saat checkout. Silakan perbarui keranjang.",
  "errorNetworkOffline": "Tidak ada koneksi internet. Periksa jaringan Anda.",
  "errorSessionExpired": "Sesi Anda telah berakhir. Silakan login kembali.",

  // Payment
  "paymentTitle": "Pembayaran BCA Virtual Account",
  "paymentExpiry": "Bayar sebelum {deadline}",
  "@paymentExpiry": {
    "placeholders": { "deadline": { "type": "String" } }
  },
  "paymentSuccess": "Pembayaran Berhasil",

  // Language switch (shown in Profile screen)
  "languageLabel": "Bahasa",
  "languageIndonesian": "Indonesia",
  "languageEnglish": "English"
}
```

### Locale Provider (Riverpod)

```dart
// providers/locale_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
const _localeKey = 'app_locale';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('id')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final saved = await _storage.read(key: _localeKey);
    if (saved != null) state = Locale(saved);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    await _storage.write(key: _localeKey, value: languageCode);
  }
}
```

### MaterialApp Setup

```dart
// app.dart
MaterialApp.router(
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('id'),
    Locale('en'),
  ],
  locale: ref.watch(localeProvider),  // controlled by Riverpod
  routerConfig: appRouter,
);
```

### What Gets Translated vs What Does Not

| Content | Translated? | Reason |
|---------|-------------|--------|
| UI labels, buttons, placeholders | ✅ Yes | All via ARB keys |
| Error messages | ✅ Yes | Mapped from backend `error.code` in Flutter |
| Product names / SKU / series | ❌ No | Technical identifiers — universal |
| Product descriptions | ✅ Yes | Stored as `description_id` + `description_en` columns in DB |
| Brand names (Mitsubishi, Danfoss) | ❌ No | Proper nouns |
| Prices / numbers | ✅ Partial | Always Rupiah (IDR) — but date formatting follows locale |

### Backend: Accept-Language Header

When Flutter sends API requests, Dio interceptor adds the `Accept-Language` header. Express uses this to return the correct product description field:

```typescript
// Flutter (dio_config.dart) — add to Dio interceptor
options.headers['Accept-Language'] = ref.read(localeProvider).languageCode; // 'id' or 'en'

// Express (product.service.ts) — return correct description
const lang = req.headers['accept-language'] === 'en' ? 'en' : 'id';
const description = lang === 'en'
  ? product.description_en ?? product.description_id  // fallback to ID if EN missing
  : product.description_id;
```

### Important Rule: Error Code — Not Error Text — from Backend

Express NEVER sends localized error text. It sends `error.code`. Flutter translates:

```
Express → { error: { code: "INSUFFICIENT_STOCK", details: { available: 2 } } }
Flutter → translateErrorCode('INSUFFICIENT_STOCK', l10n, details)
        → "Stok tidak mencukupi. Tersedia: 2 unit."  (if locale = id)
        → "Insufficient stock. Available: 2 units."  (if locale = en)
```

---

### Express API (`otomasiku-api/`)

```
otomasiku-api/
├── src/
│   ├── index.ts                     # Entry point
│   ├── app.ts                       # Express app setup (cors, middleware, routes)
│   ├── config/
│   │   ├── env.ts                   # Typed environment variables — never use raw process.env
│   │   ├── supabase.ts              # Supabase Admin client singleton
│   │   └── bca.ts                   # BCA Developer API config & client
│   ├── middleware/
│   │   ├── auth.ts                  # requireAuth, requireAdmin
│   │   ├── validate.ts              # Zod validation middleware
│   │   ├── error-handler.ts         # Centralized error handler — standardized error response shape
│   │   ├── rate-limit.ts            # Rate limiting config
│   │   ├── bca-signature.ts         # BCA callback HMAC-SHA256 signature verification
│   │   ├── correlation.ts           # Attach correlationId to every request + response header
│   │   ├── idempotency.ts           # Idempotency key enforcement for order/payment endpoints
│   │   └── response-time.ts         # Log slow requests (> 1000ms) as warn
│   ├── routes/
│   │   ├── health.routes.ts         # GET /health, GET /health/ready
│   │   ├── product.routes.ts
│   │   ├── cart.routes.ts
│   │   ├── order.routes.ts
│   │   ├── payment.routes.ts        # BCA VA callback webhook
│   │   ├── address.routes.ts
│   │   ├── profile.routes.ts
│   │   └── admin.routes.ts
│   ├── services/
│   │   ├── product.service.ts
│   │   ├── cart.service.ts
│   │   ├── order.service.ts         # Critical: transactional order creation with optimistic locking
│   │   ├── payment.service.ts       # BCA VA creation, callback handling, payment verification
│   │   ├── email.service.ts         # Order notification emails to company
│   │   └── export.service.ts        # CSV export
│   ├── schemas/
│   │   ├── product.schema.ts
│   │   ├── order.schema.ts
│   │   ├── cart.schema.ts
│   │   ├── address.schema.ts
│   │   └── payment.schema.ts        # BCA callback payload schema
│   ├── utils/
│   │   ├── logger.ts                # Pino logger setup — always include correlationId
│   │   ├── errors.ts                # AppError class with code, message, details
│   │   ├── storage.ts               # Supabase Storage upload helpers
│   │   └── sanitize.ts             # Input sanitization helpers using sanitize-html
│   └── types/
│       └── express.d.ts             # Extend Express Request with user, correlationId
├── prisma/
│   └── schema.prisma
├── .env                             # NEVER commit
├── .env.example                     # Committed — template with placeholder values
├── tsconfig.json
├── package.json
└── README.md
```

### Flutter App (`otomasiku-app/`)

```
otomasiku-app/
├── lib/
│   ├── main.dart                        # Entry point, ProviderScope
│   ├── app.dart                         # MaterialApp, GoRouter, localizationsDelegates setup
│   ├── l10n/
│   │   ├── app_id.arb                   # Indonesian strings — PRIMARY, define all keys here first
│   │   └── app_en.arb                   # English strings — must mirror every key in app_id.arb
│   ├── core/
│   │   ├── config/
│   │   │   ├── app_config.dart          # Environment config (dev/staging/prod)
│   │   │   ├── supabase_config.dart     # Supabase client initialization
│   │   │   └── dio_config.dart          # Dio instance with interceptors + correlationId header
│   │   ├── constants/
│   │   │   ├── api_endpoints.dart       # All Express API endpoint strings (all prefixed /api/)
│   │   │   ├── app_colors.dart          # mitsubishi red: #E7192D, etc.
│   │   │   ├── app_typography.dart      # Inter font styles
│   │   │   └── error_codes.dart         # Const strings matching backend AppError codes (INSUFFICIENT_STOCK, etc.)
│   │   │   # NOTE: app_strings.dart does NOT exist — all strings are in lib/l10n/app_id.arb + app_en.arb
│   │   ├── theme/
│   │   │   └── app_theme.dart           # ThemeData (light theme only for v1)
│   │   ├── router/
│   │   │   └── app_router.dart          # GoRouter with auth guards
│   │   ├── utils/
│   │   │   ├── currency_formatter.dart  # int → "Rp 19.800.000"
│   │   │   ├── date_formatter.dart      # DateTime → locale-aware format ("10 Maret 2026" / "March 10, 2026")
│   │   │   ├── validators.dart          # Form field validators
│   │   │   ├── error_handler.dart       # Maps backend error.code → AppLocalizations key via translateErrorCode()
│   │   │   └── connectivity_helper.dart # Offline detection using connectivity_plus
│   │   └── errors/
│   │       └── app_exceptions.dart      # Custom exception classes
│   ├── data/
│   │   ├── models/
│   │   │   ├── product_model.dart
│   │   │   ├── cart_item_model.dart
│   │   │   ├── order_model.dart
│   │   │   ├── address_model.dart
│   │   │   ├── profile_model.dart
│   │   │   └── payment_proof_model.dart
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart
│   │   │   ├── product_repository.dart
│   │   │   ├── cart_repository.dart
│   │   │   ├── order_repository.dart
│   │   │   ├── address_repository.dart
│   │   │   └── profile_repository.dart
│   │   └── datasources/
│   │       ├── express_api.dart         # Retrofit API client — adds X-Idempotency-Key + Accept-Language headers
│   │       └── supabase_datasource.dart
│   ├── providers/
│   │   └── locale_provider.dart         # StateNotifier<Locale> — persisted to flutter_secure_storage
│   ├── features/
│   │   ├── auth/ ...
│   │   ├── home/ ...
│   │   ├── product_detail/ ...
│   │   ├── cart/ ...
│   │   ├── checkout/ ...
│   │   ├── payment/ ...
│   │   ├── orders/ ...
│   │   ├── profile/ ...
│   │   ├── search/ ...
│   │   └── admin/ ...
│   └── shared/
│       └── widgets/
│           ├── product_card.dart
│           ├── loading_indicator.dart
│           ├── error_view.dart          # Friendly error + retry — never shows raw error strings
│           ├── empty_state.dart
│           ├── offline_banner.dart      # Shown when connectivity_plus detects no network
│           ├── price_text.dart
│           ├── stock_badge.dart
│           └── bottom_nav_bar.dart
├── assets/
│   ├── images/
│   │   ├── logo.png
│   │   ├── placeholder_product.png
│   │   └── products/
│   │       ├── mitsubishi/
│   │       │   ├── inverter/
│   │       │   ├── plc/
│   │       │   ├── hmi/
│   │       │   └── servo/
│   │       └── danfoss/
│   │           └── inverter/
│   └── fonts/
│       └── Inter/
├── test/
│   ├── unit/
│   │   ├── utils/
│   │   │   └── currency_formatter_test.dart
│   │   └── services/
│   │       └── order_idempotency_test.dart  # Tests idempotency key behavior
│   └── widget/
│       ├── product_card_test.dart
│       └── error_view_test.dart
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## Milestones & Delivery Summary

| Milestone   | Deliverables                                                                | Target Date |
| ----------- | --------------------------------------------------------------------------- | ----------- |
| Milestone 1 | Project setup, design system, Figma final                                   | 16 Mar 2026 |
| Milestone 2 | UI slicing (10 dummy products), navigable on device, payment sandbox demo   | 10 Apr 2026 |
| Milestone 3 | Backend integration, admin dashboard, full QA, production-ready build       | 24 Apr 2026 |
| Milestone 4 | Play Store release, monitoring active, PITR backup verified, handover       | 8 Mei 2026  |

> **Supporting Documents:**
> - `PLAN_MILESTONE_2.md` — Flutter UI-only milestone execution plan (15 screens, 10 phases)
> - `DUMMY_PRODUCT_MAPPING_PLAN.md` — 10-product dummy catalog with image-to-product mapping
> - `AI_RULES.md` — All code conventions, security rules, and mandatory patterns