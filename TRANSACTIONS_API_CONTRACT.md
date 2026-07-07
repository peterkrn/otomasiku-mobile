# TRANSACTIONS_API_CONTRACT.md

> **Mobile copy** — see `otomasiku-backend/TRANSACTIONS_API_CONTRACT.md` for authoritative copy.  
> Covers the full transaction happy-path: Cart → Create Order → Payment (BCA VA) → Status transitions → Order Detail.

---

## Type conventions

| Field type | Wire format | Example |
|-----------|------------|---------|
| UUID (Order, Address, CartItem, Profile) | `string` (lowercase uuid v4) | `"5ce3ae29-5548-437a-9964-1a136efb812e"` |
| Integer ID (Product, Brand, Category) | `number` | `42` |
| BigInt (price, amount) | `string` (numeric string) | `"1500000"` |
| OrderStatus enum | `string` | `"pending"` \| `"processing"` \| `"shipped"` \| `"done"` \| `"cancelled"` |
| PaymentStatus enum | `string` | `"unpaid"` \| `"paid"` \| `"expired"` |
| Timestamp | ISO 8601 string | `"2026-06-06T17:00:00.000Z"` |
| Auth | `Authorization: Bearer <supabase_jwt>` | — |

---

## Success envelope

All successful responses:
```json
{ "success": true, "data": { ... } }
```

## Error envelope

All error responses:
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "details": { ... },
    "correlationId": "uuid"
  }
}
```

---

## 1. Cart

### `GET /api/cart`
**Auth:** customer  
**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "userId": "uuid",
        "productId": 42,
        "quantity": 2,
        "productSnapshot": {
          "price": "1500000",
          "name": "FR-D720S-0.4K-CHT",
          "imageUrl": "https://..."
        },
        "createdAt": "2026-06-06T10:00:00.000Z",
        "updatedAt": "2026-06-06T10:00:00.000Z"
      }
    ],
    "totalItems": 2
  }
}
```

### `POST /api/cart`
**Auth:** customer  
**Idempotency-Key:** required header  
**Request:**
```json
{ "productId": 42, "quantity": 2 }
```
**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "userId": "uuid",
    "productId": 42,
    "quantity": 2,
    "productSnapshot": { "price": "1500000", "name": "...", "imageUrl": "..." },
    "createdAt": "...",
    "updatedAt": "..."
  }
}
```
**Error codes:**
- `PRODUCT_NOT_FOUND` 404
- `PRODUCT_UNAVAILABLE` 400
- `INSUFFICIENT_STOCK` 400 `{ available: N, requested: M }`

### `PUT /api/cart/:id`
**Auth:** customer  
**Param:** `:id` — CartItem UUID  
**Request:** `{ "quantity": 3 }`  
**Response 200:** same shape as POST 201  
**Error codes:** `CART_ITEM_NOT_FOUND` 404, `INSUFFICIENT_STOCK` 400, `INVALID_ID` 400

### `DELETE /api/cart/:id`
**Auth:** customer  
**Response 204:** no body

### `DELETE /api/cart`
**Auth:** customer  
**Response 204:** no body (clears all items)

---

## 2. Create Order

### `POST /api/orders`
**Auth:** customer  
**Idempotency-Key:** required header (UUID)  
**Request:**
```json
{
  "addressId": "uuid",
  "notes": "Please pack carefully"
}
```
**Response 201:**
```json
{
  "success": true,
  "data": {
    "orderId": "uuid",
    "orderNumber": "OMA-20260606-0001",
    "totalAmount": "3000000"
  }
}
```
**Error codes:**
- `CART_EMPTY` 400
- `ADDRESS_NOT_FOUND` 400 `{ addressId }`
- `PRODUCT_NOT_FOUND` 400 `{ productId }`
- `PRODUCT_UNAVAILABLE` 400 `{ productId, productName }`
- `INSUFFICIENT_STOCK` 400 `{ available, requested }`
- `STOCK_CONFLICT` 409 — concurrent order, retry
- `INVALID_ID` 400 — malformed addressId

---

## 3. Order Detail

### `GET /api/orders/:id`
**Auth:** customer (own order) or admin  
**Param:** `:id` — Order UUID  
**Response 200:**
```json
{
  "success": true,
  "data": {
    "order": {
      "id": "uuid",
      "orderNumber": "OMA-20260606-0001",
      "userId": "uuid",
      "addressId": "uuid",
      "subtotal": "3000000",
      "shippingCost": "0",
      "totalAmount": "3000000",
      "status": "pending",
      "paymentStatus": "unpaid",
      "vaNumber": "1234567890",
      "vaExpiresAt": "2026-06-07T10:00:00.000Z",
      "resiNumber": null,
      "shippedAt": null,
      "deliveredAt": null,
      "notes": "Please pack carefully",
      "adminNotes": null,
      "createdAt": "2026-06-06T10:00:00.000Z",
      "updatedAt": "2026-06-06T10:00:00.000Z"
    },
    "items": [
      {
        "id": "uuid",
        "productId": 42,
        "productName": "FR-D720S-0.4K-CHT",
        "quantity": 2,
        "unitPrice": "1500000",
        "subtotal": "3000000"
      }
    ]
  }
}
```
**Error codes:** `ORDER_NOT_FOUND` 404, `INVALID_ID` 400

### `GET /api/orders`
**Auth:** customer  
**Query:** `page` (default 1), `pageSize` (default 20, max 100)  
**Response 200:**
```json
{
  "success": true,
  "data": {
    "data": [ { /* order object, same shape as above */ } ],
    "total": 5,
    "page": 1,
    "pageSize": 20,
    "totalPages": 1
  }
}
```

### `GET /api/orders/:id/status-history`
**Auth:** customer (own order) or admin  
**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "orderId": "uuid",
      "from_status": "none",
      "to_status": "pending",
      "changed_by": "uuid",
      "note": "Order created",
      "created_at": "2026-06-06T10:00:00.000Z"
    }
  ]
}
```

---

## 4. Payment (BCA Virtual Account)

### BCA VA Flow

1. VA number is included in the create-order response (`vaNumber` field on the order).
2. Customer pays via BCA VA banking.
3. BCA calls `POST /api/payment/bca/callback` (server-to-server).
4. On acceptance, order status transitions `pending → processing` and `paymentStatus → paid`.

### `POST /api/payment/bca/callback`
**Auth:** BCA Bearer token (not Supabase JWT) + IP allowlist + HMAC signature  
**Request (from BCA):**
```json
{
  "transactionId": "BCA-TXN-12345",
  "vaNumber": "1234567890",
  "paymentStatus": "00",
  "paidAmount": "3000000",
  "signature": "hmac-sha256-hex"
}
```
**Response 200:** `{ "success": true }`  
**Error codes:** `INVALID_CALLBACK_TOKEN` 401, `INVALID_CALLBACK_SIGNATURE` 401, `ORDER_NOT_FOUND` 404, `PAYMENT_AMOUNT_MISMATCH` 400

---

## 5. Admin: Order Status Transitions

### `PATCH /api/admin/orders/:id/status`
**Auth:** admin  
**Param:** `:id` — Order UUID  
**Valid transitions:**

```text
pending → cancelled
pending → processing   (payment callback only — cannot be set manually)
processing → shipped
shipped → done
```

**Request (ship):**
```json
{
  "status": "shipped",
  "resiNumber": "JNE123456789",
  "adminNotes": "Shipped via JNE",
  "notifyUser": true,
  "whatsappNumber": "628123456789"
}
```
**Request (cancel/done):**
```json
{ "status": "cancelled", "adminNotes": "Out of stock" }
```
**Response 200:** `{ "success": true, "data": { /* full order + items */ } }`

**Error codes:**
- `ORDER_NOT_FOUND` 404
- `INVALID_STATUS_TRANSITION` 400 `{ from, to, validTransitions }`
- `RESI_NUMBER_REQUIRED` 400 — when status=shipped without resiNumber
- `INVALID_ID` 400 — malformed order UUID

---

## 6. Status State Machine

```text
                    ┌── cancelled
                    │
  pending ──────────┤── processing (payment callback only)
                    │       │
                    │       ▼
                    │    shipped
                    │       │
                    │       ▼
                    │      done
                    │
  (no transitions from done or cancelled)
```

PaymentStatus transitions:
```text
unpaid ──(BCA callback)──▶ paid
unpaid ──(VA expired)────▶ expired
```

---

## 7. Idempotency

`POST /api/cart` and `POST /api/orders` require `Idempotency-Key: <uuid>` header.

Duplicate requests with the same key return the cached response with the original status code.

If an idempotency key was already consumed by a different endpoint, the server rejects the request with `409 IDEMPOTENCY_KEY_EXISTS`.

---

## 8. Malformed ID guard

All UUID route params (`:id` on orders, addresses, cart items, admin user) are validated with `parseUuid`. Malformed UUIDs return:
```json
{ "success": false, "error": { "code": "INVALID_ID", "correlationId": "..." } }
```
HTTP status: `400`

---

## Cross-reference

- Backend schema: `otomasiku-backend/prisma/schema.prisma`
- Error codes: `otomasiku-backend/src/constants/error-codes.ts`
- Order policy: `otomasiku-backend/src/domain/policies/OrderPolicy.ts`
- Backend copy (authoritative): `otomasiku-backend/TRANSACTIONS_API_CONTRACT.md`
