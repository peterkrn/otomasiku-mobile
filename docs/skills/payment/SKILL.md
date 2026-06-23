# Skill: BCA Virtual Account Payment Integration
# Otomasiku Marketplace Mobile App

> **When to use:** Implementing or modifying anything related to the BCA Developer API, Virtual Account generation, payment callback handling, or payment status management.

---

## Pre-Flight Checklist

Before any payment work:

1. ✅ Read `docs/PRD.md` § Payment Flow — the complete BCA VA lifecycle
2. ✅ Read `docs/ARCHITECTURE.md` § Payment State Machine — status transitions, BCA integration
3. ✅ Read `docs/AI_RULES.md` § Security Rules — BCA credential handling, signature verification, idempotency
4. ✅ Review `docs/PLAN_MILESTONE_2.md` § Phase M2-BCA for Milestone 2 BCA Sandbox mini backend (2 endpoints only)

---

## Payment Flow Overview

```
Customer places order
  → Express calls BCA Developer API → generates VA number
  → Flutter shows VA number + amount + 24h countdown
  → Customer pays via BCA Mobile/ATM/Internet Banking
  → BCA sends callback (webhook) to Express
  → Express validates HMAC-SHA256 signature
  → Express updates order: payment_status = 'paid'
  → Express sends email to company (Otomasiku)
  → Company manually ships the order
```

### Key Principle
**Fully automated** — no manual payment verification. BCA callback is the single source of truth.

---

## Payment State Machine

```
UNPAID ──→ PAID     (BCA callback confirms payment)
UNPAID ──→ EXPIRED  (24h timeout, stock restored)
```

| Status | Meaning | Triggered By |
|--------|---------|--------------|
| `unpaid` | VA generated, awaiting payment | Order creation |
| `paid` | BCA confirmed payment received | BCA callback webhook |
| `expired` | 24h passed without payment | Cron job / scheduled check |

---

## BCA Developer API Integration

### Configuration (Server-only)

```
# .env (Express — NEVER in Flutter)
BCA_API_KEY=...
BCA_API_SECRET=...
BCA_CLIENT_ID=...
BCA_CLIENT_SECRET=...
BCA_CALLBACK_SECRET=...    # For HMAC-SHA256 signature verification
BCA_API_BASE_URL=https://sandbox.bca.co.id   # or production URL
```

> ⚠️ **ALL BCA credentials are server-only.** Flutter NEVER communicates with BCA directly.

### OAuth Token Management

```typescript
// config/bca.ts
// BCA requires OAuth2 token for API calls
// Token MUST be cached and refreshed before expiry
// NEVER request a new token on every API call

let cachedToken: { token: string; expiresAt: Date } | null = null;

export async function getBcaToken(): Promise<string> {
  if (cachedToken && cachedToken.expiresAt > new Date()) {
    return cachedToken.token;
  }
  // Request new token from BCA OAuth endpoint
  // Cache it with expiry
}
```

### VA Number Generation

```typescript
// services/payment.service.ts
export async function createVirtualAccount(orderId: string, amount: bigint) {
  const token = await getBcaToken();
  // Call BCA API to create VA number
  // Store VA number and expiry on the order
  // VA expires 24 hours from creation
}
```

---

## Callback Webhook — CRITICAL

### Endpoint

```typescript
// routes/payment.routes.ts
// This endpoint is PUBLIC (no JWT) but protected by HMAC signature
router.post('/payments/bca/callback', bcaSignatureVerify, paymentController.handleCallback);
```

### Signature Verification

```typescript
// middleware/bca-signature.ts
// ALWAYS validate the HMAC-SHA256 signature before processing
export function bcaSignatureVerify(req: Request, res: Response, next: NextFunction) {
  const signature = req.headers['x-bca-signature'];
  if (!signature) {
    return res.status(401).json({ error: 'Missing signature' });
  }

  const expectedSignature = crypto
    .createHmac('sha256', process.env.BCA_CALLBACK_SECRET!)
    .update(JSON.stringify(req.body))
    .digest('hex');

  if (signature !== expectedSignature) {
    logger.warn({ signature }, 'Invalid BCA callback signature — rejecting');
    return res.status(401).json({ error: 'Invalid signature' });
  }

  next();
}
```

### Callback Handler

```typescript
// services/payment.service.ts
export async function handleBcaCallback(payload: BcaCallbackPayload) {
  // 1. Find order by VA number
  // 2. Verify amount matches
  // 3. Update payment_status to 'paid'
  // 4. Record payment timestamp
  // 5. Send email notification to company
  logger.info({ orderId, vaNumber }, 'Payment confirmed via BCA callback');
}
```

---

## Payment Expiry

```typescript
// Cron job: check every 15 minutes
// Mark unpaid orders as 'expired' after 24 hours
// CRITICAL: Restore stock for expired orders

export async function expireUnpaidOrders() {
  const expiredOrders = await prisma.order.findMany({
    where: {
      payment_status: 'unpaid',
      created_at: { lt: new Date(Date.now() - 24 * 60 * 60 * 1000) },
    },
  });

  for (const order of expiredOrders) {
    await prisma.$transaction(async (tx) => {
      // 1. Set payment_status = 'expired'
      // 2. Restore stock for each order item
    });
  }
}
```

---

## Flutter Side

### Payment Screen (after order creation)

```dart
// Show BCA VA number, total amount, 24h countdown
// Poll payment status every 10 seconds
// On status change to 'paid' → navigate to PaymentSuccessScreen
// Reference: ui-otomasiku-marketplace/payment.html
```

### Status Polling

```dart
// providers/payment_provider.dart
// Poll GET /orders/:id/payment-status every 10 seconds
// Auto-navigate on 'paid' status
// Show countdown timer based on expiry timestamp
```

---

## Security Rules — NON-NEGOTIABLE

1. **NEVER** store BCA credentials in Flutter client code
2. **NEVER** trust callback payloads without HMAC-SHA256 signature verification
3. **NEVER** skip amount verification on callback (callback amount must match order total)
4. **ALWAYS** validate `X-BCA-Signature` header before any processing
5. **ALWAYS** cache BCA OAuth tokens — never request a new token per API call
6. **ALWAYS** log callback processing (success and failure) for audit trail
7. **ALWAYS** use `prisma.$transaction` when updating payment status + restoring stock

---

## Testing Requirements

| Test | Expected |
|------|----------|
| Valid BCA callback + valid signature | → 200, order marked 'paid' |
| Callback with invalid signature | → 401, order unchanged |
| Callback with missing signature | → 401, order unchanged |
| Callback with tampered payload | → 401, order unchanged |
| Order unpaid after 24h | → status 'expired', stock restored |
| Amount mismatch in callback | → reject, order unchanged |
