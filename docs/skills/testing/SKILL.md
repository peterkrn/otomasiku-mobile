# Skill: Testing Strategies & Patterns
# Otomasiku Marketplace Mobile App

> **When to use:** Writing tests for Flutter widgets, Express endpoints, Prisma transactions, payment flows, or performing QA verification.

---

## Pre-Flight Checklist

Before writing any test:

1. ✅ Read `docs/AI_RULES.md` § Testing Rules — mandatory test requirements, i18n testing
2. ✅ Read `docs/PLAN.md` § Phase 8 — QA checklist and edge cases
3. ✅ Check the relevant phase's exit criteria — tests must prove these pass
4. ✅ Review `docs/PLAN_MILESTONE_2.md` for Milestone 2 scope (dummy data + BCA Sandbox)
5. ✅ Read `docs/ARCHITECTURE.md` § BCA Integration — callback signature verification tests

---

## Testing Layers

| Layer | Tool | What to Test |
|-------|------|-------------|
| Flutter Widgets | `flutter_test` | UI rendering, currency formatting, state transitions |
| Flutter Integration | `integration_test` | Full screen flows on device/emulator |
| Express Unit | Jest / Vitest | Services, utilities, schema validation |
| Express Integration | Supertest | API endpoints, auth middleware, error responses |
| Database | Prisma + test DB | Transactions, constraints, triggers |
| E2E | Manual + scripted | Full customer flow, full admin flow |

---

## Mandatory Tests (from AI_RULES.md)

### 1. Prisma Transactions
Every `prisma.$transaction` (especially order creation + BCA VA) MUST have tests:

```typescript
describe('Order Creation Transaction', () => {
  it('should create order, deduct stock, clear cart atomically', async () => {
    // Arrange: user with cart items
    // Act: call orderService.createOrder()
    // Assert: order exists, stock reduced, cart empty
  });

  it('should rollback on insufficient stock', async () => {
    // Arrange: product with stock = 1, cart qty = 5
    // Act: call orderService.createOrder()
    // Assert: throws AppError(409), stock unchanged, no order created
  });
});
```

### 2. Zod Schema Validation
Every Zod schema MUST have tests for valid AND invalid inputs:

```typescript
describe('createOrderSchema', () => {
  it('should accept valid input', () => {
    expect(() => createOrderSchema.parse({
      body: { address_id: 'valid-uuid', notes: 'test' }
    })).not.toThrow();
  });

  it('should reject missing address_id', () => {
    expect(() => createOrderSchema.parse({
      body: { notes: 'test' }
    })).toThrow();
  });
});
```

### 3. Currency Formatting
```dart
group('CurrencyFormatter', () {
  test('formats standard price', () {
    expect(CurrencyFormatter.format(19800000), 'Rp 19.800.000');
  });

  test('formats zero', () {
    expect(CurrencyFormatter.format(0), 'Rp 0');
  });

  test('formats large number', () {
    expect(CurrencyFormatter.format(999999999), 'Rp 999.999.999');
  });
});
```

### 4. API Error Responses
```typescript
describe('Auth Middleware', () => {
  it('returns 401 for missing token', async () => {
    await request(app).get('/api/v1/profile').expect(401);
  });

  it('returns 401 for expired token', async () => {
    await request(app)
      .get('/api/v1/profile')
      .set('Authorization', 'Bearer expired-token')
      .expect(401);
  });

  it('returns 403 for non-admin on admin route', async () => {
    await request(app)
      .get('/api/v1/admin/orders')
      .set('Authorization', `Bearer ${customerToken}`)
      .expect(403);
  });
});
```

### 5. Widget Tests (Money Display)
```dart
testWidgets('PriceText displays formatted price', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: PriceText(price: 19800000)),
  );
  expect(find.text('Rp 19.800.000'), findsOneWidget);
});
```

### 6. BCA Callback Signature
```typescript
describe('BCA Callback', () => {
  it('accepts valid signature', async () => {
    const payload = { va_number: '123', amount: 19800000 };
    const signature = crypto
      .createHmac('sha256', BCA_CALLBACK_SECRET)
      .update(JSON.stringify(payload))
      .digest('hex');

    await request(app)
      .post('/api/v1/payments/bca/callback')
      .set('X-BCA-Signature', signature)
      .send(payload)
      .expect(200);
  });

  it('rejects invalid signature', async () => {
    await request(app)
      .post('/api/v1/payments/bca/callback')
      .set('X-BCA-Signature', 'invalid')
      .send({ va_number: '123' })
      .expect(401);
  });

  it('rejects missing signature', async () => {
    await request(app)
      .post('/api/v1/payments/bca/callback')
      .send({ va_number: '123' })
      .expect(401);
  });
});
```

### 7. Payment Expiry
```typescript
describe('Payment Expiry', () => {
  it('marks unpaid orders as expired after 24h', async () => {
    // Arrange: create order with created_at = 25 hours ago
    // Act: run expireUnpaidOrders()
    // Assert: payment_status = 'expired'
  });

  it('restores stock on expiry', async () => {
    // Arrange: order with 2x ProductA (stock was 10, now 8)
    // Act: run expireUnpaidOrders()
    // Assert: ProductA stock = 10 again
  });
});
```

---

## Edge Cases to Cover (Phase 8)

| Scenario | Expected Behavior |
|----------|------------------|
| Empty cart → checkout | Error: "Keranjang kosong" |
| Concurrent purchase → stock = 0 | Second order fails: "Stok tidak cukup" |
| Invalid file upload (wrong MIME) | Error: "Format file tidak didukung" |
| File too large (>5MB) | Error: "Ukuran file terlalu besar" |
| Expired auth token | Auto-redirect to login |
| Network offline | Graceful error message |
| 125 products → scroll performance | No jank, smooth 60fps |
| Fake BCA callback (no signature) | 401 rejected |
| Tampered BCA callback payload | 401 rejected |
| Access other user's order via API | 403/404 |
| Customer accesses admin endpoints | 403 |

---

## Security Tests

```typescript
describe('Authorization', () => {
  it('user A cannot read user B orders', async () => {
    await request(app)
      .get(`/api/v1/orders/${userBOrderId}`)
      .set('Authorization', `Bearer ${userAToken}`)
      .expect(404); // 404, not 403 (don't leak existence)
  });

  it('customer cannot access admin routes', async () => {
    await request(app)
      .get('/api/v1/admin/orders')
      .set('Authorization', `Bearer ${customerToken}`)
      .expect(403);
  });
});
```

---

## Test File Naming

- **Flutter:** `test/{feature}/{feature}_test.dart` (mirrors `lib/` structure)
- **Express:** `src/__tests__/{module}.test.ts` or `src/services/__tests__/order.service.test.ts`

---

## QA Checklist (Phase 8 — Full E2E)

### Customer Flow
- [ ] Register → profile created
- [ ] Login → JWT stored → home screen
- [ ] Browse 125 products → filter by category/brand → search
- [ ] Product detail → image gallery → specs → stock badge
- [ ] Add to cart → cart badge updates → cart screen
- [ ] Checkout → select address → place order
- [ ] BCA VA displayed → pay → auto-verify → payment success
- [ ] Order list → order detail → status timeline

### Admin Flow
- [ ] Admin login → dashboard stats
- [ ] View all orders → filter by status
- [ ] See auto-verified payments (via BCA callback)
- [ ] Update order status: processing → shipped → completed
- [ ] Manage products → CRUD with image upload
- [ ] Export orders → CSV download
