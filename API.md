# API Endpoint Documentation

> Last updated: 2026-06-16

This file documents the HTTP contracts currently present in this repository.

Scope:
- The active Express API mounted in `src/index.ts`
- The Supabase Edge Functions under `supabase/functions/*`, documented separately because they are not mounted under `/api`

## Conventions

- Express base URL: `http(s)://<host>`
- Express API prefix: `/api`
- Supabase Edge Functions base URL: `http(s)://<supabase-project>/functions/v1`
- Unless noted otherwise, Express success responses are JSON in the form `{ "success": true, "data": ... }`
- `GET /health`, `GET /health/ready`, `204 No Content` endpoints, CSV exports, and `{ "success": true }` endpoints are exceptions to the default success envelope shape
- Express error responses use:

```json
{
  "success": false,
  "error": {
    "code": "STRING",
    "details": {},
    "correlationId": "uuid"
  }
}
```

- Edge Function error responses use:

```json
{
  "success": false,
  "error": {
    "code": "STRING",
    "message": "STRING",
    "details": {}
  }
}
```

- `bigint` values in the Express app are serialized as decimal strings
- `Date` values serialize as ISO 8601 strings
- Protected Express routes require `Authorization: Bearer <Supabase JWT>`
- Admin Express routes additionally require the authenticated user role to be `admin` and may also be restricted by the admin email allowlist
- `POST /api/cart` and `POST /api/orders` require an `X-Idempotency-Key` header
- Reusing an idempotency key within 24 hours returns `409 IDEMPOTENCY_KEY_EXISTS` with the cached response under `error.details.cachedResponse`
- UUID route params return `400 INVALID_ID` when malformed
- Integer route params (products, brands, categories, images, documents) return `400 INVALID_ID` when non-numeric or out of range

## Common Types

```ts
type UUID = string;
type ISODateTime = string;
type MoneyString = string; // Express bigint JSON serialization
type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

type OrderStatus = 'pending' | 'processing' | 'shipped' | 'done' | 'cancelled';
type PaymentStatus = 'unpaid' | 'paid' | 'expired';
type VerificationStatus = 'pending' | 'approved' | 'rejected';

type Pagination<T> = {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
};

type SessionData = {
  accessToken: string;
  refreshToken: string;
  expiresAt: number | null;
  user: {
    id: UUID;
    email?: string;
  };
};

type Profile = {
  id: UUID;
  roleId: string;
  email: string;
  fullName: string;
  phone: string | null;
  companyName: string | null;
  avatarUrl: string | null;
  customerType: string | null;
  createdAt: ISODateTime;
  updatedAt: ISODateTime;
};

type MePayload = {
  id: UUID;
  email: string;
  role: 'customer' | 'admin';
  profile: Profile;
};

type Address = {
  id: UUID;
  userId: UUID;
  label: string;
  recipient: string;
  phone: string;
  street: string;
  city: string;
  province: string;
  postalCode: string;
  isDefault: boolean;
  deletedAt: ISODateTime | null;
  createdAt: ISODateTime;
};

type Brand = {
  id: number;
  name: string;
  description: string | null;
  logoUrl: string | null;
  createdAt: ISODateTime;
};

type Category = {
  id: number;
  name: string;
  slug: string;
  createdAt: ISODateTime;
};

type ProductImage = {
  id: number;
  product_id: number;
  url: string;
  path: string | null;
  is_primary: boolean;
  sort_order: number;
  created_at: ISODateTime;
};

type ProductDocument = {
  id: number;
  productId: number;
  name: string;
  type: string;
  url: string;
  path: string | null;
  sizeKb: number;
  createdAt: ISODateTime;
};

type Product = {
  id: number;
  brandId: number;
  categoryId: number;
  name: string;
  slug: string;
  sku: string | null;
  descriptionId: string | null;
  descriptionEn: string | null;
  series: string | null;
  subSeries: string | null;
  variant: string | null;
  price: MoneyString;
  originalPrice: MoneyString | null;
  stock: number;
  version: number;
  unit: string;
  minOrder: number;
  isPublished: boolean;
  deletedAt: ISODateTime | null;
  createdAt: ISODateTime;
  updatedAt: ISODateTime;
};

type ProductSummary = Product & {
  images: ProductImage[];
};

type ProductDetail = Product & {
  images: ProductImage[];
  documents: ProductDocument[];
};

type CartItem = {
  id: UUID;
  userId: UUID;
  productId: number;
  quantity: number;
  productSnapshot: {
    price: MoneyString;
    name: string;
    imageUrl: string | null;
  };
  createdAt: ISODateTime;
  updatedAt: ISODateTime;
};

type CartListItem = CartItem & {
  isAvailable: boolean;
};

type Order = {
  id: UUID;
  orderNumber: string;
  userId: UUID;
  addressId: UUID;
  subtotal: MoneyString;
  shippingCost: MoneyString;
  totalAmount: MoneyString;
  status: OrderStatus;
  paymentStatus: PaymentStatus;
  vaNumber: string | null;
  vaExpiresAt: ISODateTime | null;
  resiNumber: string | null;
  shippedAt: ISODateTime | null;
  deliveredAt: ISODateTime | null;
  notes: string | null;
  adminNotes: string | null;
  createdAt: ISODateTime;
  updatedAt: ISODateTime;
};

type PaymentProof = {
  id: UUID;
  orderId: UUID;
  imageUrl: string;
  bankName: string;
  accountName: string;
  amount: MoneyString;
  status: VerificationStatus;
  rejectReason: string | null;
  uploadedAt: ISODateTime;
  verifiedAt: ISODateTime | null;
  verifiedBy: UUID | null;
};

type OrderDetail = {
  order: Order;
  items: Array<{
    id: UUID;
    productId: number;
    productName: string;
    quantity: number;
    unitPrice: MoneyString;
    subtotal: MoneyString;
  }>;
  customer: {
    fullName: string;
    email: string;
    phone: string | null;
    companyName: string | null;
  } | null;
  paymentProof: PaymentProof | null;
};

type OrderStatusHistoryItem = {
  id: UUID;
  order_id: UUID;
  from_status: string;
  to_status: string;
  changed_by: UUID;
  note: string | null;
  created_at: ISODateTime;
  user: {
    full_name: string;
    email: string;
  };
};

type NotificationListItem = {
  id: UUID;
  type: string;
  title: string;
  body: string;
  data: Json;
  readAt: ISODateTime | null;
  unread: boolean;
  createdAt: ISODateTime;
};

type NotificationPage = Pagination<NotificationListItem> & {
  unreadCount: number;
};

type AdminUserSummary = {
  id: UUID;
  email: string;
  fullName: string;
  phone: string | null;
  companyName: string | null;
  role: string;
  customerType: string | null;
  createdAt: ISODateTime;
};

type DashboardStats = {
  totalOrders: number;
  ordersByStatus: Array<{ status: OrderStatus; count: number }>;
  todayRevenue: MoneyString;
  pendingOrders: number;
  recentOrders: Array<{
    order: Order;
    customer: {
      full_name: string;
      email: string;
    };
  }>;
  paymentStatusBreakdown: Array<{ status: PaymentStatus; count: number }>;
};

type EmailLog = {
  id: number;
  to_email: string;
  subject: string;
  body_html: string | null;
  status: string;
  error_msg: string | null;
  provider: string;
  provider_id: string | null;
  order_id: string | null;
  event: string | null;
  sent_at: ISODateTime;
};

type AuditLogEntry = {
  id: UUID;
  adminUserId: UUID;
  adminFullName: string;
  adminEmail: string;
  action: string;
  resourceType: string;
  resourceId: string | null;
  beforeStatus: string | null;
  afterStatus: string | null;
  metadata: Json;
  createdAt: ISODateTime;
};

type WhatsappContact = {
  name: string;
  whatsappNumber: string;
};
```

Notes:
- The API currently mixes `camelCase` and `snake_case` depending on whether a handler returns mapped entities or raw Prisma rows.
- Product image objects use `snake_case`; product document objects use `camelCase`.
- Order status history and email log responses use `snake_case` because they are returned from Prisma without remapping.

---

## 1. Health

These two endpoints do not use the `{ "success": true }` envelope.

| Method | Endpoint | Auth | Request | Success response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/health` | Public | None | `200 { "status": "ok", "timestamp": ISODateTime }` |
| `GET` | `/health/ready` | Public | None | `200 { "status": "ok", "timestamp": ISODateTime }` or `503 { "status": "unhealthy", "timestamp": ISODateTime }` |

---

## 2. Auth

| Method | Endpoint | Auth | Request | Success response |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/auth/signup` | Public | Body `{ email: string, password: string (min 8), fullName?: string }` | `201 data = SessionData` or `201 data = { message: string }` when Supabase email confirmation is enabled |
| `POST` | `/api/auth/login` | Public | Body `{ email: string, password: string }` | `200 data = SessionData` |
| `POST` | `/api/auth/logout` | Authenticated | None | `200 { "success": true }` |
| `POST` | `/api/auth/refresh` | Public | Body `{ refreshToken: string }` | `200 data = SessionData` |

Notes:
- `signup.fullName` is validated but not currently used by the handler.
- `logout` requires a valid `Authorization: Bearer <token>` header and signs out the specific Supabase session represented by that token.

---

## 3. Me / Profile / Notifications

| Method | Endpoint | Auth | Request | Success response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/me` | Authenticated | None | `200 data = MePayload` |
| `PATCH` | `/api/me` | Authenticated | Body `{ fullName?: string, phone?: string \| null, companyName?: string \| null, customerType?: string \| null }` | `200 data = Profile` |
| `POST` | `/api/me/bootstrap` | Bearer token required, route is not behind `requireAuth` | None | `201 data = MePayload` |
| `POST` | `/api/me/avatar` | Authenticated | `multipart/form-data`; one image file part; MIME `image/jpeg`, `image/png`, or `image/webp`; max size = `MAX_FILE_SIZE` env (default `5242880`, 5 MB) | `200 data = { avatarUrl: string }` |
| `GET` | `/api/me/notifications` | Authenticated | Query `page?: number`, `pageSize?: number` | `200 data = NotificationPage` |
| `PATCH` | `/api/me/notifications/read-all` | Authenticated | None | `200 data = { updatedCount: number }` |
| `PATCH` | `/api/me/notifications/:id/read` | Authenticated | None | `200 data = { id: UUID, readAt: ISODateTime \| null }` |

Notes:
- `POST /api/me/bootstrap` still requires `Authorization: Bearer <Supabase JWT>`; it just verifies the token inside the handler instead of via middleware.
- `POST /api/me/avatar` does not validate the multipart field name, only the uploaded file count, MIME type, and size.

---

## 4. Addresses

| Method | Endpoint | Auth | Request | Success response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/addresses` | Authenticated | Query `includeDeleted?: "true" \| "false"` | `200 data = Address[]` |
| `GET` | `/api/addresses/:id` | Authenticated | None | `200 data = Address` |
| `POST` | `/api/addresses` | Authenticated | Body `{ label: string, recipient: string, phone: string, street: string, city: string, province: string, postalCode: string, isDefault?: boolean }` | `201 data = Address` |
| `PUT` | `/api/addresses/:id` | Authenticated | Body `{ label?: string, recipient?: string, phone?: string, street?: string, city?: string, province?: string, postalCode?: string, isDefault?: boolean }` | `200 data = Address` |
| `DELETE` | `/api/addresses/:id` | Authenticated | None | `204 No Content` |

Notes:
- `DELETE /api/addresses/:id` is a soft delete; deleted addresses can still be included via `includeDeleted=true`.
- The first created address is forced to `isDefault=true` even if the request omits or sets `isDefault=false`.

---

## 5. Brands

| Method | Endpoint | Auth | Request | Success response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/brands` | Public | None | `200 data = Brand[]` |
| `GET` | `/api/brands/:id` | Public | None | `200 data = Brand` |
| `POST` | `/api/brands` | Admin | Body `{ name: string, slug: string, description?: string \| null, logoUrl?: string \| null, isPublished?: boolean }` | `201 data = Brand` |
| `PUT` | `/api/brands/:id` | Admin | Body `{ name?: string, slug?: string, description?: string \| null, logoUrl?: string \| null, isPublished?: boolean }` | `200 data = Brand` |
| `DELETE` | `/api/brands/:id` | Admin | None | `204 No Content` |

Notes:
- The request schema accepts `isPublished`, but the current handler/repository ignores it.
- Brand responses do not expose `slug` or `isPublished`, even though `slug` is accepted and stored.

---

## 6. Categories

| Method | Endpoint | Auth | Request | Success response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/categories` | Public | None | `200 data = Category[]` |
| `GET` | `/api/categories/slug/:slug` | Public | None | `200 data = Category` |
| `GET` | `/api/categories/:id` | Public | None | `200 data = Category` |
| `POST` | `/api/categories` | Admin | Body `{ name: string, slug: string, description?: string \| null, iconUrl?: string \| null, sortOrder?: number, isPublished?: boolean }` | `201 data = Category` |
| `PUT` | `/api/categories/:id` | Admin | Body `{ name?: string, slug?: string, description?: string \| null, iconUrl?: string \| null, sortOrder?: number, isPublished?: boolean }` | `200 data = Category` |
| `DELETE` | `/api/categories/:id` | Admin | None | `204 No Content` |

Notes:
- The request schema accepts `description`, `iconUrl`, `sortOrder`, and `isPublished`, but the current handler only persists `name` and `slug`.
- Category responses expose only `id`, `name`, `slug`, and `createdAt`.

---

## 7. Products

| Method | Endpoint | Auth | Request | Success response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/products` | Public | Query `brand?: string`, `category?: string`, `brandId?: number`, `categoryId?: number`, `search?: string`, `page?: number`, `pageSize?: number`, `isPublished?: "false" \| "all" \| "true"` | `200 data = Pagination<ProductSummary>` |
| `GET` | `/api/products/slug/:slug` | Public | None | `200 data = ProductDetail` |
| `GET` | `/api/products/:id` | Public | None | `200 data = ProductDetail` |
| `POST` | `/api/products` | Admin | Body `{ name: string, slug: string, brandId: number, categoryId: number, price: bigint-like value, originalPrice?: bigint-like value \| null, stock: number, sku?: string \| null, descriptionId?: string \| null, descriptionEn?: string \| null, series?: string \| null, subSeries?: string \| null, variant?: string \| null, unit?: string, minOrder?: number, isPublished?: boolean }` | `201 data = Product` |
| `PUT` | `/api/products/:id` | Admin | Same fields as create, all optional | `200 data = Product` |
| `DELETE` | `/api/products/:id` | Admin | None | `200 data = Product` |
| `POST` | `/api/products/:id/assets` | Admin | `multipart/form-data`; file field must be `file`; file MIME `image/jpeg`, `image/png`, `image/webp`, or `application/pdf`; optional form fields `is_primary`, `sort_order`, `type`; max size = `MAX_FILE_SIZE` env (default 5 MB) | `201 data = ProductImage upload object` or `201 data = ProductDocument upload object` |
| `GET` | `/api/products/:id/images` | Admin | None | `200 data = ProductImage[]` |
| `PATCH` | `/api/products/:id/images/reorder` | Admin | Body `{ order: number[] }` containing the complete image ID set in the desired order | `200 data = ProductImage[]` |
| `PATCH` | `/api/products/:id/images/:imageId/primary` | Admin | None | `200 data = ProductImage` |
| `DELETE` | `/api/products/:id/images/:imageId` | Admin | None | `204 No Content` |
| `GET` | `/api/products/:id/documents` | Admin | None | `200 data = ProductDocument[]` |
| `DELETE` | `/api/products/:id/documents/:documentId` | Admin | None | `204 No Content` |

Asset upload response shapes:

```ts
type ProductImageUploadResponse = {
  id: number;
  url: string;
  path: string | null;
  mime: string;
  is_primary: boolean;
  sort_order: number;
};

type ProductDocumentUploadResponse = {
  id: number;
  name: string;
  type: string;
  url: string;
  path: string | null;
  sizeKb: number;
};
```

Notes:
- `price` and `originalPrice` are validated with `z.coerce.bigint()`, so the server accepts bigint-like input and always returns money fields as strings.
- `GET /api/products` is public and still accepts `brandId`, `categoryId`, and `isPublished=false|all`; this is current behavior.
- `DELETE /api/products/:id` soft-deletes the product and returns the updated product object instead of `204`.
- The first uploaded image for a product is automatically promoted to primary.

---

## 8. Cart

| Method | Endpoint | Auth | Request | Success response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/cart` | Authenticated | None | `200 data = { items: CartListItem[], totalItems: number }` |
| `POST` | `/api/cart` | Authenticated | Header `X-Idempotency-Key`; body `{ productId: number, quantity: number (min 1) }` | `200 data = CartItem` or `204 No Content` when the product exists but has no price set |
| `PUT` | `/api/cart/:id` | Authenticated | Body `{ quantity: number (min 1) }` | `200 data = CartItem` |
| `DELETE` | `/api/cart/:id` | Authenticated | None | `204 No Content` |
| `DELETE` | `/api/cart` | Authenticated | None | `204 No Content` |

Notes:
- `POST /api/cart` upserts by `(userId, productId)` and replaces the existing quantity instead of incrementing it.
- `GET /api/cart` enriches each returned cart item with `isAvailable`.
- `POST /api/cart` returns `204` instead of a JSON body when the product is published but currently has no price.

---

## 9. Orders

| Method | Endpoint | Auth | Request | Success response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/orders` | Authenticated | Query `page?: number`, `pageSize?: number` | `200 data = Pagination<Order>` |
| `GET` | `/api/orders/:id` | Authenticated | None | `200 data = OrderDetail` |
| `GET` | `/api/orders/:id/status-history` | Authenticated | None | `200 data = OrderStatusHistoryItem[]` |
| `PATCH` | `/api/orders/:id/confirm-received` | Authenticated | None | `200 data = OrderDetail` |
| `POST` | `/api/orders` | Authenticated | Header `X-Idempotency-Key`; body `{ addressId: UUID, cartItemIds: UUID[], notes?: string \| null }` | `201 data = { orderId: UUID, orderNumber: string, totalAmount: MoneyString, vaNumber: string \| null }` |
| `POST` | `/api/orders/:id/payment-proof` | Authenticated | `multipart/form-data`; file field must be `image`; text fields `bankName`, `accountName`, `amount`; image MIME `image/jpeg`, `image/png`, or `image/webp`; max 5 MB | `201 data = PaymentProof` |
| `GET` | `/api/orders/:id/payment-proof` | Authenticated | None | `200 data = PaymentProof` |

Notes:
- `POST /api/orders` requires at least one `cartItemId`; the handler does not support creating an order from the entire cart implicitly.
- `GET /api/orders/:id` always includes `paymentProof`; it is `null` when no proof exists.
- `GET /api/orders/:id/status-history` returns raw Prisma-style `snake_case` keys.

---

## 10. Admin Orders and Payment Proof Verification

| Method | Endpoint | Auth | Request | Success response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/admin/orders` | Admin | Query `status?: OrderStatus`, `paymentStatus?: PaymentStatus`, `page?: number`, `pageSize?: number` | `200 data = Pagination<Order>` |
| `GET` | `/api/admin/orders/export` | Admin | Query `startDate: string`, `endDate: string`, `status?: OrderStatus`, `paymentStatus?: PaymentStatus` | `200 text/csv` attachment |
| `PATCH` | `/api/admin/orders/:id/status` | Admin | Body `{ status: OrderStatus, resiNumber?: string \| null, adminNotes?: string \| null, notifyUser?: boolean, whatsappNumber?: string }` | `200 data = OrderDetail` |
| `GET` | `/api/admin/orders/:id/payment-proof` | Admin | None | `200 data = PaymentProof` |
| `PATCH` | `/api/admin/orders/:id/payment-proof` | Admin | Body `{ action: "approve" \| "reject", reason?: string }` | `200 data = { proofId: UUID, orderId: UUID, action: "approve" \| "reject", newPaymentStatus: PaymentStatus, newOrderStatus: OrderStatus }` |
| `GET` | `/api/orders/admin/all` | Admin | Same query as `/api/admin/orders` | `200 data = Pagination<Order>` |
| `PATCH` | `/api/orders/admin/:id/status` | Admin | Same body as `/api/admin/orders/:id/status` | `200 data = OrderDetail` |

Notes:
- `GET /api/orders/admin/all` and `PATCH /api/orders/admin/:id/status` are backward-compatibility aliases for the admin order handlers.
- `PATCH /api/admin/orders/:id/status` requires `resiNumber` when `status` is `shipped`.
- `notifyUser` defaults to `true`.
- `whatsappNumber` must match `^62\\d{9,13}$`.
- Export requests require both `startDate` and `endDate`; the current implementation also enforces a max date range and row limit from env (`ADMIN_EXPORT_MAX_DAYS`, `ADMIN_EXPORT_MAX_ROWS`).

---

## 11. Admin Users, Dashboard, Logs, and WhatsApp

| Method | Endpoint | Auth | Request | Success response |
| :--- | :--- | :--- | :--- | :--- |
| `PATCH` | `/api/admin/users/:id/role` | Admin | Body `{ role: "customer" \| "admin" }` | `200 data = { id: UUID, email: string, role: string }` |
| `GET` | `/api/admin/users` | Admin | Query `page?: number`, `pageSize?: number` | `200 data = Pagination<AdminUserSummary>` |
| `GET` | `/api/admin/stats` | Admin | None | `200 data = DashboardStats` |
| `GET` | `/api/admin/email-logs` | Admin | Query `page?: number`, `pageSize?: number`, `status?: string`, `startDate?: string`, `endDate?: string` | `200 data = Pagination<EmailLog>` |
| `GET` | `/api/admin/audit-logs` | Admin | Query `page?: number`, `pageSize?: number`, `action?: string` | `200 data = Pagination<AuditLogEntry>` |
| `GET` | `/api/admin/whatsapp-contacts` | Admin | None | `200 data = WhatsappContact[]` |
| `PATCH` | `/api/admin/profile/whatsapp` | Admin | Body `{ whatsappNumber: string }` | `200 data = { whatsappNumber: string }` |

Notes:
- `PATCH /api/admin/users/:id/role` blocks self-role changes.
- `GET /api/admin/email-logs` returns raw Prisma-style `snake_case` email log rows.
- `GET /api/admin/whatsapp-contacts` returns `{ name, whatsappNumber }`; it does not return `adminId`.
- `PATCH /api/admin/profile/whatsapp` requires the number to match `^62\\d{9,13}$`.

---

## 12. Payment Callback

| Method | Endpoint | Auth | Request | Success response |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/payment/bca/callback` | Public route protected by optional IP allowlist, `Authorization: Bearer <BCA_CALLBACK_TOKEN>`, and callback signature validation | Body `{ transactionId: string, vaNumber: string, paymentStatus: string, paidAmount?: string, signature: string }` | `200 { "success": true }` |

Notes:
- The current implementation reads `signature` from the JSON body, not from an `X-Signature` header.
- In non-mock mode the handler verifies the HMAC of the raw request body using the callback token.

---

## 13. Supabase Edge Functions

These functions are separate deployments under `supabase/functions/*`; they are not mounted by the Express app.

Current implementation note:
- The function code still references legacy schema/table names and fields such as `user_profiles`, `orders.total`, and `payment_deadline`.
- Because of that drift, treat these as repository-local legacy endpoints, not part of the supported Express contract above.

| Method | Endpoint | Auth | Request | Success response |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/functions/v1/create-bca-va` | Bearer Supabase JWT | Body `{ orderId: UUID }` | `200 data = { vaNumber: string, expiryDate: ISODateTime, amount: number, status: "ACTIVE", existing: boolean }` |
| `POST` | `/functions/v1/check-bca-va` | Bearer Supabase JWT | Body `{ orderId: UUID }` | `200 data = { vaNumber: string, status: "ACTIVE" \| "PAID" \| "EXPIRED", amount: number, expiryDate: ISODateTime, paidAt?: ISODateTime, updatedAt?: ISODateTime, cached: boolean }` |

Notes:
- Both functions also answer `OPTIONS` with CORS preflight responses.
- Edge Function success responses use `{ "success": true, "data": ... }`.
- Edge Function error responses include `error.message`, unlike the Express API.
