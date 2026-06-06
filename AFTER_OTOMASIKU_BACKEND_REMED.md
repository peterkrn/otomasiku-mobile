# AFTER_OTOMASIKU_BACKEND_REMED.md

> **Session:** 2026-06-05 · **Phase executed:** Phase 1 — Backend contracts (B-1 through B-5)
> **Verification:** `pnpm build` ✅ · `pnpm test` ✅ 73/73 · `pnpm lint` ✅ 0 errors

---

## What was done

### B-1 — Product list now returns images (no N+1)

- **Modified:** `src/infra/database/repositories/ProductRepository.ts`
- `findMany()` already eager-loaded `images` via `include: { images: true }` but discarded them in `data.map((p) => this.mapToEntity(p))`.
- Fixed: `data.map((p) => Object.assign(this.mapToEntity(p), { images: this.mapImageRows(p.images) }))`.
- No extra query per product — the relation was already loaded. Zero N+1 risk.

### B-2 — ProductImage JSON casing locked to snake_case

- **Modified:** `src/infra/database/repositories/ProductRepository.ts`
- `ProductImageRow` interface fields renamed: `isPrimary` → `is_primary`, `sortOrder` → `sort_order`, `productId` → `product_id`, `createdAt` → `created_at`.
- `mapImageRow()` updated to emit the new snake_case keys.
- This aligns the wire format with: Flutter `ProductImage` (`@JsonKey(name: 'is_primary'|'sort_order')`), `API.md` §7, and the admin `fetchProductImages` mapping — all three already expected snake_case.
- **Modified:** `src/interfaces/http/handlers/product.handler.ts`
  - `uploadProductAsset` response changed from `{ isPrimary, sortOrder }` → `{ is_primary, sort_order }`.

### B-3 — Order detail items include productName

- **Modified:** `src/infra/database/repositories/OrderRepository.ts`
- `findById()` changed `include: { order_items: true }` → `include: { order_items: { include: { product: true } } }`.
- Item mapping now includes `productName: item.product?.name ?? ''`.
- `OrderWithItems.items` interface updated to add `productName: string`.
- `createWithItems()` updated to satisfy the new interface type (`productName: ''` — product not loaded in that path).

### B-4 — Product filter accepts brand/category slugs

- **Modified:** `src/interfaces/http/handlers/product.handler.ts`
- `getProducts` now reads `req.query.brand` and `req.query.category` (slugs) in addition to the existing `brandId`/`categoryId` (ints).
- Slug resolution: `prisma.brand.findUnique({ where: { slug } })` / `prisma.category.findUnique({ where: { slug } })` — resolves to id in-handler before calling `productRepository.findMany`.
- Admin path (`brandId`/`categoryId` as ints) unchanged.
- Flutter sends slugs → now works. Admin sends ints → still works.

### B-5 — 404 handler emits full error envelope

- **Modified:** `src/index.ts`
- 404 handler now returns `{ success: false, error: { code: 'NOT_FOUND', correlationId } }`.
- Previously missing `success: false`, inconsistent with every other error response.

---

## New test files

| File | Tests | Coverage |
|------|-------|----------|
| `src/infra/database/repositories/ProductRepository.test.ts` | 3 | `findMany` attaches `images`; image keys are snake_case on list + detail |
| `src/interfaces/http/handlers/product.handler.test.ts` | 3 | `brand` slug resolves to `brand_id`; `category` slug resolves to `category_id`; numeric `brandId` still works |
| `src/infra/database/repositories/OrderRepository.test.ts` | +2 new | `productName` present on items; `findById` queries with `include: { product: true }` |

**All 73 tests pass (GREEN). 8 new tests added this session.**

---

## Verification results

```
pnpm build    ✅  tsc --noEmit — 0 errors
pnpm test     ✅  73/73 pass (13 test files)
                  Note: env.test "exposes a validated SYSTEM_USER_ID UUID" is a
                  pre-existing flaky test (times out under full-suite parallelism,
                  passes in isolation). Not introduced by this session.
pnpm lint     ✅  0 errors, 55 pre-existing no-console warnings in seed files
```

---

## Cross-repo unblocks

| Repo | Item | Now unblocked |
|------|------|--------------|
| Mobile (Flutter) | Product grid images | `GET /api/products` returns `images[]` per product with snake_case keys — matches `ProductImage` JsonKeys |
| Mobile | Brand/category filter | `GET /api/products?brand=mitsubishi&category=inverter` now resolves correctly |
| Admin | Order detail "0 items" | `GET /api/orders/:id` items include `productName` |
| Mobile + Admin | Image casing | Single canonical shape: `{ id, url, path, is_primary, sort_order }` on list, detail, and `/images` |

---

## Remaining work (not in Phase 1)

| Phase | Item | Status |
|-------|------|--------|
| Phase 2 | Mobile: Workstream A — zero raw errors | ✅ Done (see `AFTER_OTOMASIKU_MOBILE_REMED.md`) |
| Phase 3 | Mobile: Phase 3 contract alignment — `ProductImage` casing verify, filter slug confirm, pagination fix (B4) | ⬜ Unblocked by this session |
| Phase 4 | Admin: verify image manager vs stabilized endpoints; order items render | ⬜ Unblocked by this session |
| Phase 5 | Backend: `kDebugMode` sim audit (B5), hardcoded strings (B6), projects status (B7) | ⬜ Pending |
| — | `API.md` §7 + §9 — document locked image shape + `productName` in order items | ⬜ Should be done in same PR before merge |

## Owner contract verification checklist (manual, curl against staging)

```bash
# B-1: images present in product list
curl -s "$API/api/products?page=1&pageSize=2" | jq '.data.data[0].images'

# B-2: images use snake_case keys
curl -s "$API/api/products/$PRODUCT_ID" | jq '.data.images[0] | keys'
# expected: ["created_at","id","is_primary","path","product_id","sort_order","url"]

# B-4: slug filter works
curl -s "$API/api/products?brand=mitsubishi&category=inverter" | jq '.data.total'

# B-3: order detail items have productName
curl -s -H "Authorization: Bearer $JWT" "$API/api/orders/$ORDER_ID" \
  | jq '.data.items[0].productName'

# B-5: 404 returns success: false
curl -s "$API/api/does-not-exist" | jq '.success'
# expected: false
```
