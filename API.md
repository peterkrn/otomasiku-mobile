# API Endpoint Documentation

All endpoints are prefixed with the base URL. Authentication uses a Supabase JWT passed as `Authorization: Bearer <token>`.

**Error response format (all endpoints):**
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

---

## 1. Health

| Method | Endpoint | Auth | Input | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/health` | Public | None | `200 { "status": "ok", "timestamp": "ISO8601" }` |
| `GET` | `/health/ready` | Public | None | `200 { "status": "ok", "timestamp": "ISO8601" }` or `503 { "status": "unhealthy" }` |

---

## 2. Auth

| Method | Endpoint | Auth | Input (Body) | Response |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/auth/signup` | Public | `{ "email": "string", "password": "string (min 8)", "fullName": "string (optional)" }` | `201 { "success": true, "data": { "accessToken", "refreshToken", "expiresAt", "user": { "id", "email" } } }` — or `201 { "data": { "message": "check email" } }` if email confirmation enabled |
| `POST` | `/api/auth/login` | Public | `{ "email": "string", "password": "string" }` | `200 { "success": true, "data": { "accessToken", "refreshToken", "expiresAt", "user": { "id", "email" } } }` |
| `POST` | `/api/auth/logout` | Customer/Admin | None | `200 { "success": true }` |
| `POST` | `/api/auth/refresh` | Public | `{ "refreshToken": "string" }` | `200 { "success": true, "data": { "accessToken", "refreshToken", "expiresAt", "user": { "id", "email" } } }` |

---

## 3. Me / Profile

| Method | Endpoint | Auth | Input | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/me` | Customer/Admin | None | `200 { "success": true, "data": { "id", "email", "role", "profile": {...} } }` |
| `POST` | `/api/me/bootstrap` | Public (token in header) | None | `201 { "success": true, "data": { "id", "email", "role", "profile": {...} } }` |
| `PATCH` | `/api/me` | Customer/Admin | Body: `{ "fullName"?, "phone"?, "companyName"?, "customerType"? }` | `200 { "success": true, "data": { ...updatedProfile } }` |
| `POST` | `/api/me/avatar` | Customer/Admin | `multipart/form-data` — field: image file (jpeg/png/webp, max 2MB) | `200 { "success": true, "data": { "avatarUrl": "string" } }` |

---

## 4. Addresses

| Method | Endpoint | Auth | Input | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/addresses` | Customer/Admin | Query: `includeDeleted=true\|false` | `200 { "success": true, "data": [ { "id", ... } ] }` |
| `GET` | `/api/addresses/:id` | Customer/Admin | None | `200 { "success": true, "data": { "id", ... } }` |
| `POST` | `/api/addresses` | Customer/Admin | Body: `{ "label", "recipient", "phone", "street", "city", "province", "postalCode", "isDefault"? }` | `200 { "success": true, "data": { "id", ... } }` |
| `PUT` | `/api/addresses/:id` | Customer/Admin | Body: all fields optional | `200 { "success": true, "data": { "id", ... } }` |
| `DELETE` | `/api/addresses/:id` | Customer/Admin | None | `204 No Content` |

---

## 5. Brands

| Method | Endpoint | Auth | Input | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/brands` | Public | None | `200 { "success": true, "data": [ { "id", "name", "slug", ... } ] }` |
| `GET` | `/api/brands/:id` | Public | None | `200 { "success": true, "data": { "id", "name", "slug", ... } }` |
| `POST` | `/api/brands` | Admin | Body: `{ "name", "slug", "description"?, "logoUrl"?, "isPublished"? }` | `200 { "success": true, "data": { ... } }` |
| `PUT` | `/api/brands/:id` | Admin | Body: all fields optional | `200 { "success": true, "data": { ... } }` |
| `DELETE` | `/api/brands/:id` | Admin | None | `204 No Content` |

---

## 6. Categories

| Method | Endpoint | Auth | Input | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/categories` | Public | None | `200 { "success": true, "data": [ { "id", "name", "slug", ... } ] }` |
| `GET` | `/api/categories/:id` | Public | None | `200 { "success": true, "data": { ... } }` |
| `GET` | `/api/categories/slug/:slug` | Public | None | `200 { "success": true, "data": { ... } }` |
| `POST` | `/api/categories` | Admin | Body: `{ "name", "slug", "description"?, "iconUrl"?, "sortOrder"?, "isPublished"? }` | `200 { "success": true, "data": { ... } }` |
| `PUT` | `/api/categories/:id` | Admin | Body: all fields optional | `200 { "success": true, "data": { ... } }` |
| `DELETE` | `/api/categories/:id` | Admin | None | `204 No Content` |

---

## 7. Products

### Canonical image object shape

All product image objects — in the list response, detail response, and `/images` endpoint — use the same snake_case shape:

```json
{
  "id": 1,
  "product_id": 1,
  "url": "https://…/img.jpg",
  "path": "products/1/images/…",
  "is_primary": true,
  "sort_order": 0,
  "created_at": "2024-01-01T00:00:00.000Z"
}
```

### Endpoints

| Method | Endpoint | Auth | Input | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/products` | Public | Query: `brand` (slug), `category` (slug), `search`, `page`, `pageSize`.<br>Admin may also pass `brandId` (int) / `categoryId` (int) instead of slugs. | `200 { "success": true, "data": { "data": [ { ...product, "images": [ {image object} ] } ], "total", "page", "pageSize", "totalPages" } }` |
| `GET` | `/api/products/:id` | Public | None | `200 { "success": true, "data": { ...product, "images": [ {image object} ], "documents": [...] } }` |
| `GET` | `/api/products/slug/:slug` | Public | None | `200 { "success": true, "data": { ...product, "images": [ {image object} ], "documents": [...] } }` |
| `POST` | `/api/products` | Admin | Body: `{ "name", "slug", "brandId", "categoryId", "price", "stock", "sku"?, "originalPrice"?, "descriptionId"?, "descriptionEn"?, "series"?, "subSeries"?, "variant"?, "unit"?, "minOrder"?, "isPublished"? }` | `200 { "success": true, "data": { ... } }` |
| `PUT` | `/api/products/:id` | Admin | Body: all fields optional | `200 { "success": true, "data": { ... } }` |
| `DELETE` | `/api/products/:id` | Admin | None | `204 No Content` |
| `POST` | `/api/products/:id/assets` | Admin | `multipart/form-data` — field: image (jpeg/png/webp, max 8 per product) or PDF. Optional fields: `is_primary` ("true"/"false"), `sort_order` (int), `type` (string, for PDF) | `201` — Image: `{ "success": true, "data": { "id", "url", "path", "mime", "is_primary", "sort_order" } }` — Document: `{ "success": true, "data": { "id", "name", "type", "url", "path", "sizeKb" } }` |
| `GET` | `/api/products/:id/images` | Admin | None | `200 { "success": true, "data": [ {image object} ] }` |
| `DELETE` | `/api/products/:id/images/:imageId` | Admin | None | `204 No Content` |
| `PATCH` | `/api/products/:id/images/reorder` | Admin | Body: `{ "order": [imageId, …] }` (all image IDs in desired order) | `200 { "success": true, "data": [ {image object} ] }` |
| `PATCH` | `/api/products/:id/images/:imageId/primary` | Admin | None | `200 { "success": true, "data": {image object} }` |
| `GET` | `/api/products/:id/documents` | Admin | None | `200 { "success": true, "data": [ { "id", "name", "type", "url", "path", "sizeKb", "createdAt" } ] }` |
| `DELETE` | `/api/products/:id/documents/:documentId` | Admin | None | `204 No Content` |

---

## 8. Cart

> `POST /api/cart` requires an `X-Idempotency-Key` header to prevent duplicate items on retry.

| Method | Endpoint | Auth | Input | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/cart` | Customer/Admin | None | `200 { "success": true, "data": { "items": [...], "totalItems": 0 } }` |
| `POST` | `/api/cart` | Customer/Admin | Header: `X-Idempotency-Key` <br> Body: `{ "productId": number, "quantity": number (min 1) }` | `200 { "success": true, "data": { ... } }` |
| `PUT` | `/api/cart/:id` | Customer/Admin | Body: `{ "quantity": number (min 1) }` | `200 { "success": true, "data": { ... } }` |
| `DELETE` | `/api/cart/:id` | Customer/Admin | None | `204 No Content` |
| `DELETE` | `/api/cart` | Customer/Admin | None | `204 No Content` |

---

## 9. Orders

> `POST /api/orders` requires an `X-Idempotency-Key` header to prevent duplicate orders on retry.

| Method | Endpoint | Auth | Input | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/orders` | Customer/Admin | Query: `page`, `pageSize` | `200 { "success": true, "data": { "data": [...], "total", "page", "pageSize" } }` |
| `GET` | `/api/orders/:id` | Customer/Admin | None | `200 { "success": true, "data": { "order": { ...orderFields }, "items": [ { "id", "productId", "productName", "quantity", "unitPrice", "subtotal" } ] } }` |
| `GET` | `/api/orders/:id/status-history` | Customer/Admin | None | `200 { "success": true, "data": [ { "status", "changedAt", "changedBy", "notes" } ] }` |
| `POST` | `/api/orders` | Customer/Admin | Header: `X-Idempotency-Key` <br> Body: `{ "addressId": "uuid", "notes"?: "string (max 500)" }` | `201 { "success": true, "data": { "orderId", "orderNumber", "totalAmount" } }` |

---

## 10. Admin — Orders

| Method | Endpoint | Auth | Input | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/admin/orders` | Admin | Query: `status`, `paymentStatus`, `page`, `pageSize` | `200 { "success": true, "data": { "data": [...], "total", "page", "pageSize" } }` |
| `GET` | `/api/admin/orders/export` | Admin | Query: `startDate` (required), `endDate` (required), `status`?, `paymentStatus`? | `200 text/csv` attachment |
| `PATCH` | `/api/admin/orders/:id/status` | Admin | Body: `{ "status": "pending\|processing\|shipped\|done\|cancelled", "resiNumber"? (required if shipped), "adminNotes"?, "notifyUser"? (default true), "whatsappNumber"? (format: 62xxxxxxxxx) }` | `200 { "success": true, "data": { ...updatedOrder } }` |

---

## 11. Admin — Users

| Method | Endpoint | Auth | Input | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/admin/users` | Admin | Query: `page`, `pageSize` | `200 { "success": true, "data": { "data": [...], "total", "page", "pageSize", "totalPages" } }` |
| `PATCH` | `/api/admin/users/:id/role` | Admin | Body: `{ "role": "customer\|admin" }` | `200 { "success": true, "data": { "id", "email", "role" } }` |

---

## 12. Admin — Dashboard & Logs

| Method | Endpoint | Auth | Input | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/admin/stats` | Admin | None | `200 { "success": true, "data": { "totalOrders", "ordersByStatus", "todayRevenue", "pendingOrders", "recentOrders", "paymentStatusBreakdown" } }` |
| `GET` | `/api/admin/email-logs` | Admin | Query: `page`, `pageSize`, `status`?, `startDate`?, `endDate`? | `200 { "success": true, "data": { "data": [...], "total", "page", "pageSize" } }` |
| `GET` | `/api/admin/audit-logs` | Admin | Query: `page`, `pageSize`, `action`? | `200 { "success": true, "data": { "data": [...], "total", "page", "pageSize" } }` |

---

## 13. Admin — WhatsApp

| Method | Endpoint | Auth | Input | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/admin/whatsapp-contacts` | Admin | None | `200 { "success": true, "data": [ { "adminId", "whatsappNumber", ... } ] }` |
| `PATCH` | `/api/admin/profile/whatsapp` | Admin | Body: `{ "whatsappNumber": "string (format: 62xxxxxxxxx)" }` | `200 { "success": true, "data": { "whatsappNumber" } }` |

---

## 14. Payment

| Method | Endpoint | Auth | Input (Body) | Response |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/payment/bca/callback` | Public (BCA HMAC signature) | `{ "transactionId", "vaNumber", "paymentStatus", "paidAmount"?, "signature" }` | `200 { "success": true }` |
