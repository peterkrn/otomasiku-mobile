# Skill: Express API Endpoints
# Otomasiku Marketplace Mobile App

> **When to use:** Creating or modifying Express.js API endpoints, middleware, services, or controllers.

---

## Pre-Flight Checklist

Before creating any endpoint:

1. ✅ Read `docs/ARCHITECTURE.md` § API Design — endpoint conventions, error handling, BCA integration
2. ✅ Read `docs/AI_RULES.md` § Absolute Rules — auth, validation, security, i18n, idempotency, optimistic locking
3. ✅ Check `docs/PLAN.md` for the relevant phase's tasks and exit criteria
4. ✅ Review `docs/PLAN_MILESTONE_2.md` § Phase M2-BCA for BCA Sandbox mini backend scope (Milestone 2 only)

---

## Project Structure

```
otomasiku-api/
├── src/
│   ├── index.ts                    # App entry point
│   ├── config/
│   │   ├── env.ts                  # Typed environment config
│   │   ├── supabase.ts             # Supabase Admin SDK client
│   │   └── bca.ts                  # BCA API client + OAuth token
│   ├── middleware/
│   │   ├── require-auth.ts         # JWT verification via Supabase
│   │   ├── require-admin.ts        # Role check (admin only)
│   │   ├── error-handler.ts        # Centralized error handling
│   │   ├── validate.ts             # Zod schema validation
│   │   └── bca-signature.ts        # BCA callback HMAC verification
│   ├── routes/
│   │   ├── product.routes.ts
│   │   ├── cart.routes.ts
│   │   ├── order.routes.ts
│   │   ├── profile.routes.ts
│   │   ├── address.routes.ts
│   │   ├── payment.routes.ts
│   │   └── admin.routes.ts
│   ├── controllers/                # Thin — only req/res handling
│   ├── services/                   # Business logic lives HERE
│   ├── schemas/                    # Zod validation schemas
│   └── utils/
│       ├── app-error.ts            # Custom error class
│       └── logger.ts               # Pino structured logger
├── prisma/
│   ├── schema.prisma
│   └── seed.ts
├── .env.example
├── tsconfig.json
└── package.json
```

---

## Endpoint Pattern

### Route → Controller → Service → Prisma

```typescript
// routes/order.routes.ts
router.post('/orders', requireAuth, validate(createOrderSchema), orderController.create);

// controllers/order.controller.ts — THIN, only req/res
export const create = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const order = await orderService.createOrder(req.user.id, req.body);
    res.status(201).json({ data: order });
  } catch (err) {
    next(err);
  }
};

// services/order.service.ts — ALL business logic HERE
export const createOrder = async (userId: string, input: CreateOrderInput) => {
  return prisma.$transaction(async (tx) => {
    // validate stock, create order, deduct stock, clear cart
  });
};
```

### ❌ NEVER put logic in route handlers

```typescript
// WRONG — business logic in route
router.post('/orders', async (req, res) => {
  const order = await prisma.order.create(...);
  res.json(order);
});
```

---

## Authentication Middleware

```typescript
// Every endpoint MUST have auth (unless explicitly public)
router.get('/profile', requireAuth, profileController.get);          // Customer
router.get('/admin/orders', requireAuth, requireAdmin, ...);          // Admin
router.post('/payments/bca/callback', bcaSignatureVerify, ...);       // Public (BCA webhook)
```

### Auth Rules
- Default: `requireAuth` on everything
- Admin: `requireAuth` + `requireAdmin`
- Public (rare): Only health check + BCA callback — BCA callback uses HMAC signature instead of JWT

---

## Validation with Zod

```typescript
// schemas/order.schema.ts
import { z } from 'zod';

export const createOrderSchema = z.object({
  body: z.object({
    address_id: z.string().uuid(),
    notes: z.string().max(500).optional(),
  }),
});

// middleware/validate.ts
export const validate = (schema: AnyZodObject) => (req, res, next) => {
  schema.parse({ body: req.body, query: req.query, params: req.params });
  next();
};
```

### ❌ NEVER access req.body without Zod validation

```typescript
// WRONG
const { address_id } = req.body;  // No validation!
```

---

## Error Handling

```typescript
// utils/app-error.ts
export class AppError extends Error {
  constructor(public statusCode: number, message: string) {
    super(message);
  }
}

// ✅ ALWAYS: Use AppError for known errors
throw new AppError(409, 'Insufficient stock');
throw new AppError(404, 'Product not found');
throw new AppError(403, 'Not authorized');

// ❌ NEVER: Throw plain Error or ad-hoc responses
throw new Error('something went wrong');  // WRONG
```

---

## Logging

```typescript
// ✅ ALWAYS: Structured logging with Pino
logger.info({ orderId: order.id, userId }, 'Order created');
logger.warn({ productId, available: stock, requested: qty }, 'Stock insufficient');
logger.error({ err, orderId }, 'BCA callback processing failed');

// ❌ NEVER: console.log in production
console.log('order created');  // WRONG
```

---

## API Response Format

```typescript
// Success
res.status(200).json({ data: product });
res.status(201).json({ data: order });
res.status(200).json({ data: products, meta: { page, limit, total } });

// Error (via centralized error handler)
res.status(404).json({ error: { message: 'Product not found', code: 'NOT_FOUND' } });
res.status(409).json({ error: { message: 'Insufficient stock', code: 'CONFLICT' } });
```

---

## TypeScript Rules

- **Strict mode** enabled in `tsconfig.json`
- **NEVER use `any`** — use proper types, generics, or union types
- **NEVER use `console.log`** — use Pino logger
- **ALWAYS** type request bodies via Zod inference: `z.infer<typeof createOrderSchema>`

---

## Key Endpoints Summary

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/health` | Public | Health check |
| GET | `/products` | Public | List products (paginated, filterable) |
| GET | `/products/:id` | Public | Product detail |
| GET | `/profile` | Customer | Own profile |
| PATCH | `/profile` | Customer | Update profile |
| GET/POST/PATCH/DELETE | `/cart` | Customer | Cart CRUD |
| GET/POST | `/orders` | Customer | List / create orders |
| GET | `/orders/:id` | Customer | Order detail (ownership) |
| POST | `/payments/bca/callback` | BCA Signature | Payment webhook |
| GET/POST/PUT/DELETE | `/admin/*` | Admin | Admin operations |
