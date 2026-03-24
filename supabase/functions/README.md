# Otomasiku Backend — Supabase Edge Functions

Backend foundation for Otomasiku Marketplace using Supabase Edge Functions (Deno runtime, TypeScript).

## Architecture

```
supabase/functions/
├── _shared/                    # Shared utilities and types
│   ├── types.ts                # Domain types (Order, Product, etc.)
│   ├── errors.ts               # Custom error class hierarchy
│   ├── response.ts             # JSON response helpers
│   ├── db.ts                   # Supabase client factory
│   └── config.ts               # Environment configuration
├── _lib/payment/               # Payment gateway abstraction
│   ├── payment_gateway.ts      # Interface all gateways must implement
│   ├── payment_factory.ts      # Factory to get gateway by method
│   └── bca/                    # BCA Virtual Account implementation
│       ├── bca_types.ts        # BCA API request/response types
│       ├── bca_auth.ts         # OAuth2 token management + HMAC signatures
│       ├── bca_client.ts       # Raw HTTP client for BCA API
│       └── bca_va_service.ts   # Business logic implementing PaymentGateway
├── create-bca-va/              # Edge Function: Create VA for an order
│   └── index.ts
├── check-bca-va/               # Edge Function: Check VA payment status
│   └── index.ts
└── README.md                   # This file
```

## Required Environment Variables

Set these in your Supabase Dashboard → Edge Functions → Settings:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# BCA Developer API (Sandbox)
BCA_CLIENT_ID=your-bca-client-id
BCA_CLIENT_SECRET=your-bca-client-secret
BCA_API_BASE_URL=https://sandbox.bca.co.id
BCA_VA_COMPANY_CODE=12345678
BCA_CALLBACK_TOKEN=your-callback-token
```

### Getting BCA Sandbox Credentials

1. Register at [BCA Developer Portal](https://developer.bca.co.id/)
2. Create a new application
3. Subscribe to **Virtual Account** API
4. Copy the credentials to your environment variables
5. `BCA_VA_COMPANY_CODE` is the 8-digit company code assigned by BCA

## Running Locally

### Prerequisites

- [Supabase CLI](https://supabase.com/docs/guides/local-development) installed
- Deno installed (comes with Supabase CLI)

### Steps

```bash
# Start local Supabase (includes database, auth, storage)
supabase start

# Set environment variables
supabase secrets set --env-file .env.local

# Serve Edge Functions locally
supabase functions serve

# Functions will be available at:
# http://localhost:54321/functions/v1/create-bca-va
# http://localhost:54321/functions/v1/check-bca-va
```

### Testing Locally

```bash
# Create VA for an order
curl -X POST http://localhost:54321/functions/v1/create-bca-va \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"orderId": "your-order-uuid"}'

# Check VA status
curl -X POST http://localhost:54321/functions/v1/check-bca-va \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"orderId": "your-order-uuid"}'
```

## Deploying

```bash
# Deploy all functions
supabase functions deploy

# Deploy specific function
supabase functions deploy create-bca-va
supabase functions deploy check-bca-va

# Set secrets in production
supabase secrets set SUPABASE_URL=xxx SUPABASE_ANON_KEY=xxx ...
```

## API Reference

### POST /create-bca-va

Creates a new BCA Virtual Account for an order.

**Request:**
```json
{
  "orderId": "uuid"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "vaNumber": "1234567810012024001",
    "expiryDate": "2024-01-02T12:00:00.000Z",
    "amount": 19800000,
    "status": "ACTIVE",
    "existing": false
  }
}
```

**Response (Existing VA):**
```json
{
  "success": true,
  "data": {
    "vaNumber": "1234567810012024001",
    "expiryDate": "2024-01-02T12:00:00.000Z",
    "amount": 19800000,
    "status": "ACTIVE",
    "existing": true
  }
}
```

**Errors:**
- `400` - Invalid request body
- `401` - Missing/invalid JWT
- `404` - Order not found
- `409` - Order not in pending status
- `402` - VA creation failed

### POST /check-bca-va

Checks the payment status of a Virtual Account.

**Request:**
```json
{
  "orderId": "uuid"
}
```

**Response (Active):**
```json
{
  "success": true,
  "data": {
    "vaNumber": "1234567810012024001",
    "status": "ACTIVE",
    "amount": 19800000,
    "expiryDate": "2024-01-02T12:00:00.000Z",
    "cached": false
  }
}
```

**Response (Paid):**
```json
{
  "success": true,
  "data": {
    "vaNumber": "1234567810012024001",
    "status": "PAID",
    "amount": 19800000,
    "paidAt": "2024-01-01T14:30:00.000Z",
    "expiryDate": "2024-01-02T12:00:00.000Z",
    "cached": false
  }
}
```

**Response (Cached):**
```json
{
  "success": true,
  "data": {
    "vaNumber": "1234567810012024001",
    "status": "PAID",
    "amount": 19800000,
    "expiryDate": "2024-01-02T12:00:00.000Z",
    "updatedAt": "2024-01-01T14:30:00.000Z",
    "cached": true
  }
}
```

## BCA API Integration Notes

### Virtual Account Format

BCA VA Number = Company Code (8 digits) + Customer Number (10 digits) = 18 digits total

Example: `12345678` + `10012024001` = `1234567810012024001`

### OAuth2 Authentication

BCA uses OAuth2 client credentials flow:
1. Exchange client_id + client_secret for access_token
2. Token valid for 1 hour (cache in memory)
3. Include token in `Authorization: Bearer <token>` header

### Request Signature

All BCA API calls require HMAC-SHA256 signature:

```
StringToSign = METHOD:RelativeURL:AccessToken:BodySHA256:Timestamp
Signature = HMAC-SHA256(StringToSign, ClientSecret)
```

Headers required:
- `X-BCA-Key`: Client ID
- `X-BCA-Timestamp`: ISO 8601 timestamp
- `X-BCA-Signature`: HMAC signature

### VA Lifecycle

1. **Creation**: VA created with 24-hour expiry (configurable)
2. **Active**: Customer can pay at BCA ATM, KlikBCA, or m-BCA
3. **Paid**: BCA sends callback, status updated to PAID
4. **Expired**: If not paid within validity period

### Callback Handler

> **TODO:** Not implemented yet. Will be added in future milestone.

BCA will POST to a callback URL when payment is received. The callback must:
1. Validate the callback token
2. Verify HMAC signature
3. Update order status
4. Return success response

## Development Guidelines

### Adding New Payment Methods

1. Create new folder in `_lib/payment/<method>/`
2. Implement `PaymentGateway` interface
3. Add to `payment_factory.ts` switch statement
4. Create corresponding Edge Functions

### Error Handling

All errors use the `AppError` hierarchy:
- `ValidationError` (400) - Invalid input
- `AuthError` (401) - Authentication failed
- `ForbiddenError` (403) - No permission
- `NotFoundError` (404) - Resource not found
- `ConflictError` (409) - State conflict
- `PaymentError` (402) - Payment gateway error
- `ExternalApiError` (502) - Third-party API error

### Code Conventions

- **No `any` types** - Use `unknown` and narrow explicitly
- **Named exports only** - No default exports
- **JSDoc comments** - Document all public functions
- **Monetary values as `number`** - Integer IDR, never float/string

## Future Work

- [ ] BCA payment callback handler
- [ ] VA cancellation support (if BCA adds API)
- [ ] Midtrans payment integration
- [ ] Order checkout flow endpoints
- [ ] Product catalog endpoints
- [ ] Admin dashboard endpoints

## License

Proprietary - Otomasiku Team